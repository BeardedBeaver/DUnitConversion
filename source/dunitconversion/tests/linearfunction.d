module dunitconversion.tests.linearfunction;

import dunitconversion.linearfunction;

import std.math;

/// Basic construction tests
unittest {
    auto f = LinearFunction(0, 0);
    assert(!f.isValid);
    assert(f.k == 0);
    assert(f.b == 0);

    f = LinearFunction(1, 0);
    assert(f.isValid);
    assert(f.k == 1);
    assert(f.b == 0);

    f = LinearFunction(-15, 8);
    assert(f.isValid);
    assert(f.k == -15);
    assert(f.b == 8);
}

/// Value test
unittest {
    auto f = LinearFunction(5.5, 3);
    assert(f.isValid());
    assert(approxEqual(f.y(0), 3));
    assert(approxEqual(f.y(-5), -24.5));
    assert(approxEqual(f.y(1), 8.5));
    assert(approxEqual(f.y(0.7659), 7.21245));
    assert(approxEqual(f.y(35.6), 198.8));
}

/// Inversed test
unittest {
    auto f = LinearFunction(3, -2);
    f = f.inversed();
    assert(approxEqual(f.k, 1.0 / 3));
    assert(approxEqual(f.b, 2.0 / 3));

    f.k = -2;
    f.b = -16;
    f = f.inversed();
    assert(approxEqual(f.k, -0.5));
    assert(approxEqual(f.b, -8));
}