module dunitconversion.tests.tools;

import dunitconversion.linearfunction;
import dunitconversion.tools;

import std.math;

/// Combined function test with testing conversion from
/// celsius to farenheights through kelvins
unittest {
    auto cToK = LinearFunction(1, 273.15);
    auto KToF = LinearFunction(1.8, -459.67);
    auto combined = combined(cToK, KToF);

    assert(approxEqual(combined.y(-273.15), -459.67));
    assert(approxEqual(combined.y(-45.56), -50.008));
    assert(approxEqual(combined.y(-40), -40));
    assert(approxEqual(combined.y(-34.44), -29.992));
    assert(approxEqual(combined.y(-28.89), -20.002));
    assert(approxEqual(combined.y(-23.33), -9.994));
    assert(approxEqual(combined.y(-12.22), 10.004));
    assert(approxEqual(combined.y(-6.67), 19.994));
    assert(approxEqual(combined.y(-1.11), 30.002));
    assert(approxEqual(combined.y(0), 32));
    assert(approxEqual(combined.y(4.44), 39.992));
    assert(approxEqual(combined.y(10), 50));
    assert(approxEqual(combined.y(60), 140));
    assert(approxEqual(combined.y(65.56), 150.008));
    assert(approxEqual(combined.y(100), 212));
    assert(approxEqual(combined.y(260), 500));
    assert(approxEqual(combined.y(537.78), 1000.004));
}