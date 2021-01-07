module dunitconversion.tests.convertor;

import dunitconversion.convertor;
import dunitconversion.linearfunction;
import dunitconversion.conversionfamily;
import dunitconversion.conversionrule;
import dunitconversion.aliasdictionary;

import std.exception;
import std.math;
import std.algorithm;
import std.file;
import std.json;

unittest {
    auto convertor = new UnitConvertor;

    convertor.addConversionRule(ConversionRule("length", "m", "km", LinearFunction(0.001, 0)));

    assert("length" in convertor.m_families);
    assert("length" in convertor.m_baseUnitsByFamilies);
    assert("m" in convertor.m_familiesByUnit);
    assert("km" in convertor.m_familiesByUnit);
    assert(convertor.m_familiesByUnit.length == 2);
    assert(convertor.m_families.length == 1);
    assert(convertor.m_baseUnitsByFamilies.length == 1);

    convertor.addConversionRule(ConversionRule("length", "m", "cm", LinearFunction(100, 0)));
    assert("m" in convertor.m_familiesByUnit);
    assert("km" in convertor.m_familiesByUnit);
    assert("cm" in convertor.m_familiesByUnit);
    assert(convertor.m_familiesByUnit.length == 3);
    assert(convertor.m_families.length == 1);
    assert(convertor.m_baseUnitsByFamilies.length == 1);

    convertor.addConversionRule(ConversionRule("length", "m", "mm", LinearFunction(1000, 0)));
    assert("m" in convertor.m_familiesByUnit);
    assert("km" in convertor.m_familiesByUnit);
    assert("cm" in convertor.m_familiesByUnit);
    assert("mm" in convertor.m_familiesByUnit);
    assert(convertor.m_familiesByUnit.length == 4);
    assert(convertor.m_families.length == 1);
    assert(convertor.m_baseUnitsByFamilies.length == 1);

    // assert("length" in convertor.m_families());

    // passing existing family with a differnt base unit
    assertThrown!Exception(
        convertor.addConversionRule(ConversionRule("length", "km", "m", LinearFunction(1000, 0))));

    // passing a different family with an existing base unit
    assertThrown!Exception(
        convertor.addConversionRule(ConversionRule("notlength", "m", "km", LinearFunction(0.001, 0))));

    // passing the same conversion once again should work
    convertor.addConversionRule(ConversionRule("length", "m", "mm", LinearFunction(1000, 0)));

    // let's make sure that none of containers did change
    assert(convertor.m_familiesByUnit.length == 4);
    assert(convertor.m_families.length == 1);
    assert(convertor.m_baseUnitsByFamilies.length == 1);

    // note "min" here, since we have to make sure that all unit names are different
    // we need to differ minutes from meters
    convertor.addConversionRule(ConversionRule("time", "s", "min", LinearFunction(double(1) / 60, 0)));
    assert("length" in convertor.m_families);
    assert("time" in convertor.m_families);
    assert(convertor.m_families.length == 2);
    assert("m" in convertor.m_familiesByUnit);
    assert("km" in convertor.m_familiesByUnit);
    assert("cm" in convertor.m_familiesByUnit);
    assert("mm" in convertor.m_familiesByUnit);
    assert("s" in convertor.m_familiesByUnit);
    assert("min" in convertor.m_familiesByUnit);
    assert("length" in convertor.m_baseUnitsByFamilies);
    assert("time" in convertor.m_baseUnitsByFamilies);
    assert(convertor.m_baseUnitsByFamilies["length"] == "m");
    assert(convertor.m_baseUnitsByFamilies["time"] == "s");

    auto families = convertor.families();
    assert(families.canFind("length"));
    assert(families.canFind("time"));

    auto units = convertor.units("length");
    assert(units.length == 4);
    assert(units.canFind("m"));
    assert(units.canFind("km"));
    assert(units.canFind("cm"));
    assert(units.canFind("mm"));

    assert(approxEqual(convertor.convert(0, "m", "km"), 0));
    assert(approxEqual(convertor.convert(50, "m", "km"), 0.05));
    assert(approxEqual(convertor.convert(50, "km", "m"), 50_000));
    assert(approxEqual(convertor.convert(500, "cm", "m"), 5));
    assert(approxEqual(convertor.convert(500, "cm", "km"), 0.005));
    assert(approxEqual(convertor.convert(500, "m", "m"), 500));

    auto conversions = convertor.conversions("m");
    assert(conversions.canFind("m"));
    assert(conversions.canFind("km"));
    assert(conversions.canFind("cm"));
    assert(conversions.canFind("mm"));
    assert(conversions.length == 4);

    conversions = convertor.conversions("mm");
    assert(conversions.canFind("m"));
    assert(conversions.canFind("km"));
    assert(conversions.canFind("cm"));
    assert(conversions.canFind("mm"));
    assert(conversions.length == 4);

    conversions = convertor.conversions("mmmm");
    assert(conversions is null);

    assert(convertor.family("m") == "length");
    assert(convertor.family("km") == "length");
    assertThrown!Exception(convertor.family("mmmmm"));
}

unittest {
    auto convertor = new UnitConvertor;

    convertor.loadFromJson(parseJSON(readText("./test/conversion_rules.json")));
    convertor.loadAliasesFromJson(parseJSON(readText("./test/aliases.json")));

    // conversion to an actual unit
    assert(approxEqual(convertor.convert(0, "m", "km"), 0));
    assert(approxEqual(convertor.convert(50, "m", "km"), 0.05));
    assert(approxEqual(convertor.convert(50, "km", "m"), 50_000));
    assert(approxEqual(convertor.convert(500, "cm", "m"), 5));
    assert(approxEqual(convertor.convert(500, "cm", "km"), 0.005));

    assert(approxEqual(convertor.convert(50, "m/s", "km/h"), 180));
    assert(approxEqual(convertor.convert(50, "m/s", "kmph"), 180));
    assert(approxEqual(convertor.convert(50, "m/s", "kmh"), 180));
    assert(approxEqual(convertor.convert(50, "mps", "km/h"), 180));
    assert(approxEqual(convertor.convert(50, "mps", "kmph"), 180));
    assert(approxEqual(convertor.convert(50, "mps", "kmh"), 180));

    assert(approxEqual(convertor.convert(0, "meter", "km"), 0));
    assert(approxEqual(convertor.convert(50, "meters", "km"), 0.05));

    assert(approxEqual(convertor.convert(100, "C", "K"), 373.15));

    assert(approxEqual(convertor.convert(-40, "C", "F"), -40));
    
    assert(convertor.family("m") == "length");
    assert(convertor.family("km") == "length");

    // should retrieve correct family for unit aliases as well
    assert(convertor.family("meter") == "length");
    assert(convertor.family("meters") == "length");
    
    assertThrown!Exception(convertor.family("mmmmm"));
}
