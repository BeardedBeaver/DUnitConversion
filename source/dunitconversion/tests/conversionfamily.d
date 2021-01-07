module dunitconversion.tests.conversionfamily;

import dunitconversion.conversionfamily;
import dunitconversion.conversionrule;
import dunitconversion.linearfunction;

import std.exception;

unittest {
    auto family = new ConversionFamily;
    family.addConversionRule(ConversionRule("length", "m", "km", LinearFunction(0.001, 0)));
    auto f = family.convert("m", "km");
    assert(f.k == 0.001);
    assert(f.b == 0);
    
    f = family.convert("km", "m");
    assert(f.k == 1000);
    assert(f.b == 0);

    assertThrown!Exception(family.convert("km", "ft"));
}