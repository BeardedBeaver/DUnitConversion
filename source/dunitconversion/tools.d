module dunitconversion.tools;

import dunitconversion.linearfunction;

/**
  * Combines two linear functions
  * Returns: an object of type LinearFunction containing combined function
  */
LinearFunction combined(LinearFunction first, LinearFunction second) {
    return LinearFunction(first.k * second.k, second.k * first.b + second.b);
}