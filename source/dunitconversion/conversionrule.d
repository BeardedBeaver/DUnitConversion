module dunitconversion.conversionrule;

import dunitconversion.linearfunction;

/**
 * The ConversionRule struct represents a unit conversion rule from
 * base unit to second unit within the specified family. Note that in UnitConvertor
 * class each family can be represented with the single base unit. In other words you
 * can't have two unit conversion rules with the same family but different base units
 */
struct ConversionRule {

    @disable this();

    /**
      * Constructs a rule
      */
    this(string family, string baseUnit, string unit, LinearFunction convertFunction) {
        this.family = family;
        this.baseUnit = baseUnit;
        this.unit = unit;
        this.convertFunction = convertFunction;
    }

    string family;   /// Family name for this pair of units, like length, speed
    string baseUnit; /// Base unit for this family
    string unit;     /// Unit to convert to
    LinearFunction convertFunction;  /// Linear function to perform conversion from base unit to unit
}