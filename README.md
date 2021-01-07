# DUnitConversion

Library for D programming language that provides tools for runtime unit conversion. 
-----------

![Build](https://github.com/BeardedBeaver/DUnitConversion/workflows/Build/badge.svg) ![Unittest](https://github.com/BeardedBeaver/DUnitConversion/workflows/Unittest/badge.svg)

This is a port of my Qt-based library QUnitConversion which is available [here](https://github.com/BeardedBeaver/QUnitConversion) 

`DUnitConversion` stores units as strings grouped by "family" (for example length or temperature). Each family has its own base unit, conversion inside a family is performed by converting through base unit
providing conversion from any unit to any other unit in a family. Conversion rules can be added dynamically
and/or loaded from JSON-formatted string so you can add your own conversions if needed. An example of 
an input JSON file is provided in `/test/conversion_rules.json`.

Note that each unit should have a unique name, as long as conversion is unit name-based.

`DUnitConversion` supports aliases for unit names, see aliases example below.

## Information

Documentation is available [here](https://dunitconversion.dpldocs.info/dunitconversion.html) 

Author: Dmitriy Linev

License: MIT

## Features

  - Load unit conversion rules from JSON files
  - Support for unit aliases
  - Convert values directly
  - Bulk convert is supported with linear convert functions (see examples)

## Examples

### Basic usage:

```D
auto convertor = new UnitConvertor;

// fill the convertor instance with rules
convertor.addConversionRule(ConversionRule("length", "m", "km", LinearFunction(0.001, 0)));
convertor.addConversionRule(ConversionRule("length", "m", "cm", LinearFunction(100, 0)));

// you can convert a single value
double km = convertor.convert(50, "km", "m");   // returns value of a 50 km converted to meters

// or get a linear function that holds conversion from one unit to another
// to apply this conversion to many numbers without finding a conversion each time 
LinearFunction convertFunction = convertor.convert("m", "km");
double [] meters;
// meters is filled here...
double [] kilometers;
foreach (m; meters)
    kilometers ~= convertFunction.y(m);
```

### Aliases:

```D
auto convertor = new UnitConvertor;
 
// load conversion rules from JSON
convertor.loadFromJson(parseJSON(readText("conversion_rules.json")));

// load aliases for unit names from JSON
convertor.loadAliasesFromJson(parseJSON(readText("aliases.json")));

double km;
km = convertor.convert(50, "km", "m");   // returns value of a 50 km converted to meters
km = convertor.convert(50, "km", "meter");  // "meter" is an alias for "m" written in loaded json
km = convertor.convert(50, "km", "meters"); // and "meters" a as well
```
## Package content

| Directory       | Contents                       |
|-----------------|--------------------------------|
| `./source`      | Source code.                   |
| `./source/tests`| Tests source code.             |
| `./test`        | Unittest data.                 |

## Installation

dunitconversion is available in dub. If you're using dub run `dub add dunitconversion` in your project folder and dub will add dependency and fetch the latest version.
