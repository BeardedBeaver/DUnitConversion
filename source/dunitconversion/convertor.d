module dunitconversion.convertor;

import dunitconversion.linearfunction;
import dunitconversion.conversionfamily;
import dunitconversion.conversionrule;
import dunitconversion.aliasdictionary;

import std.json;
import std.file;
import std.math;
import std.conv;

/**
 * The UnitConvertor class provides tool for converting units stored
 * in a string form. It uses "base" unit for each "family" (length, speed etc)
 * and perform conversions inside a family through conversion to and from base unit.
 */
class UnitConvertor {

    /// Default constructor, creates an empty convertor
    this () {
        m_aliases = new AliasDictionary;
    }

    /**
     * Checks if unit conversion from in unit to out unit is possible
     * Params:
     *      inUnit = unit to convert from
     *      outUnit = unit to convert to
     * Returns:
     *      true if conversion is possible, false otherwise
     */
    bool canConvert(string inUnit, string outUnit) const {
        return convert(inUnit, outUnit).isValid();
    }

    /**
     * Converts from in unit to out unit
     * Params:
     *      inUnit = unit to convert from
     *      outUnit = unit to convert to
     * Returns:
     *      LinearFunction object containing conversion from in to out unit
     */
    LinearFunction convert(string inUnit, string outUnit) const {
        if (inUnit == outUnit)
            return LinearFunction(1, 0);
        string actualIn, actualOut;
        if (inUnit in m_aliases)
            actualIn = m_aliases.name(inUnit);
        else
            actualIn = inUnit;
        if (outUnit in m_aliases)
            actualOut = m_aliases.name(outUnit);
        else
            actualOut = outUnit;

        string inFamily, outFamily;
        try {
            inFamily = m_familiesByUnit[actualIn];
            outFamily = m_familiesByUnit[actualOut];
        }
        catch (Exception e) {
            throw new Exception("Conversion from " ~ inUnit ~ " to " ~ outUnit ~ " not found");
        }
            
        return m_families[inFamily].convert(actualIn, actualOut);
    }

    /**
     * Converts a given value from in unit to out unit
     * Params:
     *      value = value to convert
     *      inUnit = unit to convert from
     *      outUnit = unit to convert to
     *      defaultValue = value to return if conversion fails
     * Returns:
     *      value converted to out unit
     * Details: Supports aliases for unit names, see AliasDictionary
     */
    double convert(double value, string inUnit, string outUnit, double defaultValue = double.nan) const {
        try {
            LinearFunction f = convert(inUnit, outUnit);
            return f.y(value);
        }
        catch (Exception e) {
            return defaultValue;
        }
    }

    /**
     * Deserializes unit conversion rules from JSON
     * Params:
     *      json = JSON object for deserialization
     *
     * Details: Note that this function does not clear the existing
     * conversion allowing you to override or augment conversion rules
     * from a number of different files, let's say, built-in conversions
     * and user conversions`
     */
    void loadFromJson(JSONValue json) {
        auto rules = json["rules"].array;
        foreach (r; rules) {
            auto rule = r.object;
            auto baseUnit = rule["base"].str;
            auto familyName = rule["family"].str;
            auto conversions = rule["conversions"].array;
            foreach (c; conversions) {
                auto conversion = c.object;
                auto unit = conversion["unit"].str;
                immutable double k = conversion.get("k", JSONValue(1)).toString().to!double;
                immutable double b = conversion.get("b", JSONValue(0)).toString().to!double;
                if (unit is null || approxEqual(k, 0))
                    continue;
                addConversionRule(ConversionRule(familyName,
                                                    baseUnit,
                                                    unit,LinearFunction(k, b)
                                                    ));
            }
        }
    }

    /**
     * Serializes current unit conversion rules to JSON
     * Returns: JsonObject containing serialized rules
     * Details: Not implemented yet
     */
    JSONValue toJson() const {
        assert(false, "toJson method not implemented");
    }

    /**
     * Adds a conversion rule to convertor
     * Params:
     *      rule = rule to add
     * Details: This function doesn't convert an alas for a unit to an actual unit name, so make sure to
     * pass here an actual unit name
     * Throws: Exception if a passed rule has existing family with different base unit,
     * existing unit with different family or existing unit with a different family or base unit
     */
    void addConversionRule(ConversionRule rule) {
        if (rule.family in m_baseUnitsByFamilies && m_baseUnitsByFamilies[rule.family] != rule.baseUnit)
            throw new Exception("Incorrect rule added: incorrect family base unit");
        if (rule.baseUnit in m_familiesByUnit && m_familiesByUnit[rule.baseUnit] != rule.family)
            throw new Exception("Incorrect rule added: incorrect base unit family");
        if (rule.unit in m_familiesByUnit && m_familiesByUnit[rule.unit] != rule.family)
            throw new Exception("Incorrect rule added: incorrect unit family");
        if (rule.family !in m_families)
        {
            auto family = new ConversionFamily;
            family.addConversionRule(rule);
            m_families[rule.family] = family;
            m_baseUnitsByFamilies[rule.family] = rule.baseUnit;
            m_familiesByUnit[rule.baseUnit] = rule.family;
        }
        else
        {
            m_families[rule.family].addConversionRule(rule);
        }
        m_familiesByUnit[rule.unit] = rule.family;
    }

    /**
     * Clears unit convertor removing all unit conversion rules
     */
    void clear() {
        m_families.clear();
        m_familiesByUnit.clear();
        m_baseUnitsByFamilies.clear();
        m_aliases.clear();
    }

    /**
     * Method provides access to a list of families of units in this convertor
     * Returns: An array of strings containing all unit families
     */
    string[] families() const {
        return m_families.keys();   
    }

    /**
     * Gets a family for a given unit
     * Params: unit = unit to return a family
     * Returns a family name
     */
    string family(string unit) const {
        string actualUnit;
        if (unit in m_aliases)
            actualUnit = m_aliases.name(unit);
        else
            actualUnit = unit;
        if (actualUnit in m_familiesByUnit) 
            return m_familiesByUnit[actualUnit];
        throw new Exception("Family name is not known for unit " ~ unit);
    }

    /**
     * Gets a list of units with a possible connection to/from a given unit
     * Params: unit = unit to get a list of conversions
     * Returns String list with units with possible conversion to a given unit, including a given unit. If
     * conversion to/from a given unit is unknown returns an empty list
     */
    string[] conversions(string unit) const {
        try {
            return units(family(unit));
        }
        catch (Exception e) {
            return null;
        }
    }

    /**
     * Method provides access to a list of units in this convertor within a given
     * family, effectively providing a list of unit with a possible conversion from
     * any unit of this list to any other
     * Params:
     *   family = family to return unit list
     * Returns: string[] containing a list of units known by this unit convertor
     */
    string[] units(string family) const {
        string [] result;
        foreach(item; m_familiesByUnit.byKeyValue()) {
            if (item.value == family) {
                result ~= item.key;
            }
        }
        return result;
    }

    /**
     * Loads unit aliases from json serialized object
     * Params:
     *      object = json-serialized aliases
     */
    void loadAliasesFromJson(JSONValue object) {
        m_aliases.loadFromJson(object);
    }

    /**
     * Removes all alias rules
     */
    void clearAliases() {
        m_aliases.clear();
    }

    /**
     * Gets unit name by alias using internal alias dictionary
     * Params:
     *      alias = unit alias to get unit name
     * Returns: unit name or an empty string if a specified alias is not found
     */
    string unitName(string aliasName) const {
        return m_aliases.name(aliasName);
    }

package:
    string[string] m_familiesByUnit;   /// Key is a unit, Value is a corresponding family. Base units are also put here
    string[string] m_baseUnitsByFamilies;  /// Key is a family name, Value is a corresponding base unit
    ConversionFamily[string] m_families;   /// Key is a family name, Value is a family
    AliasDictionary m_aliases;      /// Alias dictionary
}