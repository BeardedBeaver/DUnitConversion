module dunitconversion.aliasdictionary;

import std.container;
import std.json;

/**
 * The AliasDictionary class provides an alias dictionary to allow quick on-the-fly
 * conversion of unit name aliases such as km/h -> kmph, kmh etc.
 */
class AliasDictionary {

    /**
      * Default constructor as it is
      */  
    this() {
        m_names = new RedBlackTree!string;
    }

    /**
     * Gets name by alias
     * Params: aliasName = alias to get name
     * Returns: string containing name corresponding to the given alias
     */
    string name(string aliasName) const {
        if (aliasName in m_names)
            return aliasName;
        if (aliasName !in m_aliases)
            throw new Exception("Alias not found");
        return m_aliases[aliasName];
    }

    /**
     * Gets a list of aliases for a given name
     * Params: name = name to get aliases
     * Returns: array of strings containing aliases for a given name
     */
    string[] aliases(string name) const {
        string [] result;
        foreach(item; m_aliases.byKeyValue()) {
            if (item.value == name) {
                result ~= item.key;
            }
        }
        return result;
    }

    /**
     * Checks if this dictionary is empty
     * Returns: true if empty, false otherwise
     */
    bool isEmpty() const {
        return m_aliases is null;
    }

    /**
     * Adds an alias to the dictionary
     * Params:
     *      name = name which will be returned if an alias requested
     *      alias = alias for the given name
     */
    void addAlias(string name, string aliasName) {
        m_aliases[aliasName] = name;
        m_names.insert(name);
    }

    /**
     * Checks if a dictionary contains name for the given alias
     * Params: alias =  alias to check existence
     * Returns: true if a dictionary contains name for the given alias, false otherwise
     */
    bool opBinaryRight(string op)(string aliasName) const 
    if (op == "in") {
        if (aliasName in m_aliases || aliasName in m_names)
            return true;
        return false;
    }

    /**
     * Loads alias rules from JSON
     * Params: json = containing serialized dictionary
     */
    void loadFromJson(JSONValue json) {
        auto rules = json["aliases"].array;
        foreach (r; rules)
        {
            auto rule = r.object;
            auto name = rule["name"].str;
            if (name is null)
                continue;
            auto aliases = rule["aliases"].array;
            foreach (a; aliases)
                addAlias(name, a.str);
        }
    }

    /**
     * Removes all alias-name from dictionary
     */
    void clear() {
        m_aliases = null;
        m_names.clear();
    }

protected:
    string [string] m_aliases;  /// AA containing names associated with each alias
    RedBlackTree!string m_names;    /// Full list of names
}