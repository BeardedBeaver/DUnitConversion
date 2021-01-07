module dunitconversion.linearfunction;

import std.math;

/**
 * The LinearFunction class describes a linear function
 * with a format of Y = k*X + b
 */
struct LinearFunction {

    @disable this();

    /**
     * Constructor
     * Params:
     *      k = K factor value
     *      b = bias value
     */
    this (double k, double b) {
        this.k = k;
        this.b = b;
    }

    /**
     * Checks if linear function is valid, i.e. if k != 0
     * Returns: `true` if function is valid, `false` otherwise
     */
    bool isValid() const nothrow {
        return !approxEqual(k, 0);
    }

    /**
     * Reverses current linear function so X = k*Y + b
     * Returns: an object of type QLinearFunction containing inversed function
     * Details: This function doesn't perform validity check so applying it to
     * invalid function will cause division by zero
     */
    LinearFunction inversed() const {
        if (!isValid())
            throw new Exception("Can't inverse non-valid function");
        return LinearFunction(1. / k, -b / k);
    }

    /**
     * Function value
     * Params: x = function argument
     * Returns: value of a function with an argument `x`
     */
    double y(double x) const {
        return k * x + b;
    }

    double k;   /// Function scale factor K
    double b;   /// Function bias b
}