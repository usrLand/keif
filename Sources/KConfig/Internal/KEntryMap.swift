/*
 * map/dict/list config node entry.
 */
internal struct KEntry {
    private var _value: [UInt8]
    /*
     * Must the entry be written back to disk?
     */
    private var _dirty: Bool
    /*
     * Entry should be written to the global config file
     */
    private var _global: Bool
    /*
     * Entry can not be modified.
     */
    private var _immutable: Bool
    /*
     * Entry has been deleted.
     */
    private var _deleted: Bool
    /*
     * Whether to apply dollar expansion or not.
     */
    private var _expand: Bool
    /*
     * Entry has been reverted to its default value (from a more global file).
     */
    private var _reverted: Bool
    /*
     * Entry is for a localized key. If false the value references just language e.g. "de",
     * if true the value references language and country, e.g. "de_DE".
     **/
    private var _localizedCountry: Bool

    private var _notify: Bool

    public var deleted: Bool {
        _deleted
    }

    /*
     * Entry will need to be written on a non global file even if it matches default value
     */
    private var _overridesGlobal: Bool

    internal init() {
        _value = []
        _dirty = false
        _global = false
        _immutable = false
        _deleted = false
        _expand = false
        _reverted = false
        _localizedCountry = false
        _notify = false
        _overridesGlobal = false
    }

    // These operators are used to check whether an entry which is about
    // to be written equals the previous value. As such, this intentionally
    // omits the dirty/notify flag from the comparison.
    internal static func == (_ k1: KEntry, _ k2: KEntry) -> Bool
    {
        /* clang-format off */
        return k1._global == k2._global
            && k1._immutable == k2._immutable
            && k1._deleted == k2._deleted
            && k1._expand == k2._expand
            && k1._value == k2._value
        /* clang-format on */
    }

    internal static func != (_ k1: KEntry, _ k2: KEntry) -> Bool
    {
        return !(k1 == k2)
    }
}

// Q_DECLARE_TYPEINFO(KEntry, Q_RELOCATABLE_TYPE);



/*
 * key structure holding both the actual key and the group
 * to which it belongs.
 *
 */
struct KEntryKey: Hashable {
    /*
     * The "group" to which this EntryKey belongs
     */
    private var _group: String
    /*
     * The _actual_ key of the entry in question
     */
    private var _key: [UInt8]
    /*
     * Entry is localised or not
     */
    private var _local: Bool
    /*
     * Entry indicates if this is a default value.
     */
    private var _default: Bool
    /*
     * Key is a raw unprocessed key.
     * Warning: this should only be set during merging, never for normal use.
     */
    private var _raw: Bool

    public var group: String {
        _group
    }

    public var key: [UInt8] {
        _key
    }

    internal init(
        _ group: String = "",
        _ key: [UInt8] = [],
        _ isLocalized: Bool = false,
        _ isDefault: Bool = false
    ) {
        _group = group
        _key = key
        _local = isLocalized
        _default = isDefault
        _raw = false
    }

    internal init(_ group: String) {
        self.init(group, [], false, false)
    }

    /*
    * Compares two KEntryKeys (needed for std::map). The order is localized, localized-default,
    * non-localized, non-localized-default
    *
    */
    internal static func < (_ k1: KEntryKey, _ k2: KEntryKey) -> Bool {
        if k1._group != k2._group {
            return k1._group < k2._group
        }

        if k1._key != k2._key {
            return k1._key.lexicographicallyPrecedes(k2._key)
        }

        if k1._local != k2._local {
            return k1._local
        }
        return !k1._default && k2._default
    }
}

// Q_DECLARE_TYPEINFO(KEntryKey, Q_RELOCATABLE_TYPE);


/*
 * Light-weight view variant of KEntryKey.
 * Used for look-up in the map.
 *
 */
/*
struct KEntryKeyView {
    KEntryKeyView(QStringView _group, QAnyStringView _key, bool isLocalized = false, bool isDefault = false)
        : mGroup(_group)
        , mKey(_key)
        , bLocal(isLocalized)
        , bDefault(isDefault)
    {
    }
    /*
     * The "group" to which this EntryKey belongs
     */
    const QStringView mGroup;
    /*
     * The _actual_ key of the entry in question
     */
    const QAnyStringView mKey;
    /*
     * Entry is localised or not
     */
    bool bLocal : 1;
    /*
     * Entry indicates if this is a default value.
     */
    bool bDefault : 1;


    inline bool operator<(const KEntryKeyView &k1, const KEntryKey &k2)
    {
        return compareEntryKeyViews(k1, k2);
    }

    inline bool operator<(const KEntryKey &k1, const KEntryKeyView &k2)
    {
        return compareEntryKeyViews(k1, k2);
    }
};

template<typename TEntryKey1, typename TEntryKey2>
bool compareEntryKeyViews(const TEntryKey1 &k1, const TEntryKey2 &k2)
{
    int result = k1.mGroup.compare(k2.mGroup);
    if (result != 0) {
        return result < 0;
    }

    result = QAnyStringView::compare(k1.mKey, k2.mKey);
    if (result != 0) {
        return result < 0;
    }

    if (k1.bLocal != k2.bLocal) {
        return k1.bLocal;
    }
    return (!k1.bDefault && k2.bDefault);
}
*/


/*
 * Struct to use as Compare type with std::map.
 * To enable usage of KEntryKeyView for look-up in the map
 * via the template find() overloads.
 *
 */
struct KEntryKeyCompare {
    // using is_transparent = void;

    // internal static func () (const KEntryKey &k1, const KEntryKey &k2) -> Bool
    // {
    //     return (k1 < k2)
    // }

    /*
    bool operator()(const KEntryKeyView &k1, const KEntryKey &k2) const
    {
        return (k1 < k2);
    }

    bool operator()(const KEntryKey &k1, const KEntryKeyView &k2) const
    {
        return (k1 < k2);
    }
    */
}

/*
 * Returns the minimum key that has mGroup == group.
 *
 * Note: The returned "minimum key" is consistent with KEntryKey's operator<().
 *       The return value of this function can be passed to KEntryMap::lowerBound().
 */
/*
inline KEntryKeyView minimumGroupKeyView(const QString &group)
{
    return KEntryKeyView(group, QAnyStringView{}, true, false);
}

QDebug operator<<(QDebug dbg, const KEntryKey &key);
QDebug operator<<(QDebug dbg, const KEntry &entry);
*/

/*
 * \relates KEntry
 * type specifying a map of entries (key,value pairs).
 * The keys are actually a key in a particular config file group together
 * with the group name.
 *
 */
class KEntryMap { // : public std::map<KEntryKey, KEntry, KEntryKeyCompare> {
    typealias Iterator = (key: KEntryKey, value: KEntry)

    private var _value: [KEntryKey:KEntry] = [:]

// public:
    public struct SearchFlags: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let searchDefaults  = SearchFlags(rawValue: 1)
        public static let searchLocalized = SearchFlags(rawValue: 2)
    }

    public struct EntryOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let entryDirty = EntryOptions(rawValue: 1)
        public static let entryGlobal = EntryOptions(rawValue: 2)
        public static let entryImmutable = EntryOptions(rawValue: 4)
        public static let entryDeleted = EntryOptions(rawValue: 8)
        public static let entryExpansion = EntryOptions(rawValue: 16)
        public static let entryRawKey = EntryOptions(rawValue: 32)
        public static let entryLocalizedCountry = EntryOptions(rawValue: 64)
        public static let entryNotify = EntryOptions(rawValue: 128)
        public static let entryDefault = EntryOptions(
            rawValue: SearchFlags.searchDefaults.rawValue << 16
        )
        public static let entryLocalized = EntryOptions(
            rawValue: SearchFlags.searchLocalized.rawValue << 16
        )
    }

    /*
    iterator findExactEntry(const QString &group, QAnyStringView key = QAnyStringView(), SearchFlags flags = SearchFlags());

    iterator findEntry(const QString &group, QAnyStringView key = QAnyStringView(), SearchFlags flags = SearchFlags());

    const_iterator findEntry(const QString &group, QAnyStringView key = QAnyStringView(), SearchFlags flags = SearchFlags()) const
    {
        return constFindEntry(group, key, flags);
    }

    const_iterator constFindEntry(const QString &group, QAnyStringView key = QAnyStringView(), SearchFlags flags = SearchFlags()) const;

    /*
     * Returns true if the entry gets dirtied or false in other case
     */
    bool setEntry(const QString &group, const QByteArray &key, const QByteArray &value, EntryOptions options);

    void setEntry(const QString &group, const QByteArray &key, const QString &value, EntryOptions options)
    {
        setEntry(group, key, value.toUtf8(), options);
    }

    QString getEntry(const QString &group,
                     QAnyStringView key,
                     const QString &defaultValue = QString(),
                     SearchFlags flags = SearchFlags(),
                     bool *expand = nullptr) const;

    bool hasEntry(const QString &group, QAnyStringView key = QAnyStringView(), SearchFlags flags = SearchFlags()) const;

    bool getEntryOption(const const_iterator &it, EntryOption option) const;
    bool getEntryOption(const QString &group, QAnyStringView key, SearchFlags flags, EntryOption option) const
    {
        return getEntryOption(findEntry(group, key, flags), option);
    }

    void setEntryOption(iterator it, EntryOption option, bool bf);
    void setEntryOption(const QString &group, QAnyStringView key, SearchFlags flags, EntryOption option, bool bf)
    {
        setEntryOption(findEntry(group, key, flags), option, bf);
    }

    bool revertEntry(const QString &group, QAnyStringView key, EntryOptions options, SearchFlags flags = SearchFlags());

    template<typename ConstIteratorUser>
    void forEachEntryWhoseGroupStartsWith(const QString &groupPrefix, ConstIteratorUser callback) const
    {
        for (auto it = lower_bound(minimumGroupKeyView(groupPrefix)), end = cend(); it != end && it->first.mGroup.startsWith(groupPrefix); ++it) {
            callback(it);
        }
    }
    */

    // template<typename ConstIteratorPredicate>
    public func anyEntryWhoseGroupStartsWith(
        _ groupPrefix: String, _ predicate: ((KEntryMap.Iterator) -> Bool)
    ) -> Bool {
        for v in _value {
            if predicate(v) {
                return true
            }
        }

        /*
        for (auto it = lower_bound(KEntryKey(groupPrefix)), end = cend(); it != end && it->first.mGroup.startsWith(groupPrefix); ++it) {
            if (predicate(it)) {
                return true
            }
        }
        */
        return false
    }

    /*
    template<typename ConstIteratorUser>
    void forEachEntryOfGroup(const QString &theGroup, ConstIteratorUser callback) const
    {
        const auto theEnd = cend();
        auto it = constFindEntry(theGroup);
        if (it != theEnd) {
            ++it; // advance past the special group entry marker

            for (; (it != theEnd) && (it->first.mGroup == theGroup); ++it) {
                callback(it);
            }
        }
    }
    */
}
