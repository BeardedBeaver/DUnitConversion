module dunitconversion.conversionfamily;

import dunitconversion.linearfunction;
import dunitconversion.conversionrule;
import dunitconversion.tools;

/**
 * The ConversionFamily class is an internal class that provides
 * a conversion by holding all of the conversion rules for a single family
 */
class ConversionFamily {

    /**
      * Constructs a family with empty base unit and family name
      */
    this() {

    }

    /**
    * Constructs a family with the given base unit and family name
    */
    this(string baseUnit, string family) {
        m_baseUnit = baseUnit;
        m_family = family;
    }

    /**
     * Adds a conversion rule to convertor
     * Params: rule = rule to add
     */
    void addConversionRule(ConversionRule rule) {
        if (m_rules is null)
        {
            m_family = rule.family;
            m_baseUnit = rule.baseUnit;
        }
        else
        {
            if (m_family != rule.family || m_baseUnit != rule.baseUnit)
                throw new Exception("Incorrect rule added to family");
        }
        m_rules[rule.unit] = rule;
    }

    /**
     * Converts from in unit to out unit
     * Params:
     *      inUnit = unit to convert from
     *      outUnit = unit to convert to
     * Returns: LinearFunction object containing conversion from in to out unit
     */
    LinearFunction convert(string inUnit, string outUnit) const {
        if (m_rules is null)
            throw new Exception("No conversion rules known for " ~ m_family ~ " family");

        if (inUnit == m_baseUnit && outUnit in m_rules)  // conversion from base unit to unit
            return m_rules[outUnit].convertFunction;
        if (inUnit in m_rules && outUnit == m_baseUnit)  // conversion from unit to base unit
            return m_rules[inUnit].convertFunction.inversed();
        
        // conversion from one unit to another through the base unit if possible
        if (inUnit !in m_rules || outUnit !in m_rules)  // one of the conversions is not present
            throw new Exception("Conversion from " ~ inUnit ~ " to " ~ outUnit ~ " not found");
        LinearFunction inToBase = m_rules[inUnit].convertFunction.inversed();
        LinearFunction baseToOut = m_rules[outUnit].convertFunction;

        return combined(inToBase, baseToOut);
    }

    /**
     * Converts a given value from in unit to out unit
     * Params:
     *      value = value to convert
     *      inUnit = unit to convert from
     *      outUnit = unit to convert to
     * Returns: value converted to
     */
    double convert(double value, string inUnit, string outUnit) const {
        auto f = convert(inUnit, outUnit);
        if (f.isValid())
            return f.y(value);
        return double.nan;
    }

protected:
    ConversionRule [string] m_rules;    /// Key is a unit, it's assumed that all rules have the same base unit
    string m_baseUnit;     /// Base unit for this family
    string m_family;       /// Family name
}