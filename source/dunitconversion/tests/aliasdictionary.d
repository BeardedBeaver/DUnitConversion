module dunitconversion.tests.aliasdictionary;

import dunitconversion.aliasdictionary;

import std.exception;
import std.algorithm;
import std.json;
import std.file;

unittest {
    auto dictionary = new AliasDictionary;
    assert(dictionary.isEmpty);
    dictionary.addAlias("m", "meter");
    dictionary.addAlias("m", "meters");
    assert(!dictionary.isEmpty);


    assert("m" in dictionary);
    assert("meter" in dictionary);
    assert("meters" in dictionary);
    assert("bzz" !in dictionary);

    assert(dictionary.name("meter") == "m");
    assert(dictionary.name("meters") == "m");
    assertThrown!Exception(dictionary.name("caboo!"));

    auto aliases = dictionary.aliases("m");
    assert(aliases.length == 2);
    assert(aliases.canFind("meter"));
    assert(aliases.canFind("meters"));

    dictionary.clear();
    assert(dictionary.isEmpty);
    assert("m" !in dictionary);
    assert("meter" !in dictionary);
    assert("meters" !in dictionary);
    assert("bzz" !in dictionary);
}

unittest {
    auto dictionary = new AliasDictionary;
    dictionary.loadFromJson(parseJSON(readText("./test/aliases.json")));
    assert(!dictionary.isEmpty);
    assert("m" in dictionary);
    assert("meter" in dictionary);
    assert("meters" in dictionary);
    assert("bzz" !in dictionary);

    auto aliases = dictionary.aliases("m");
    assert(aliases.length == 2);
    assert(aliases.canFind("meter"));
    assert(aliases.canFind("meters"));

    aliases = dictionary.aliases("m/s");
    assert(aliases.length == 1);
    assert(aliases.canFind("mps"));
    assert(!aliases.canFind("meters"));

}