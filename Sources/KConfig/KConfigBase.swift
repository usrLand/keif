public protocol KConfigBase {
// public:
    /*!
     * Flags to control write entry
     *
     * \value Persistent
     *        Save this entry when saving the config object.
     * \value Global
     *        Save the entry to the global KDE config file instead of the application specific config file.
     * \value Localized
     *        Add the locale tag to the key when writing it.
     * \value[since 5.51] Notify
     *        Notifies remote KConfigWatchers of changes (requires DBus support). Implies Persistent.
     * \value Normal
     *        Save the entry to the application specific config file without a locale tag. This is the default.
     * \sa KConfigGroup
     * \sa KConfigWatcher
     * \sa KConfigSkeletonItem::setWriteFlags()
     */
    public enum WriteConfigFlag: Int {
        case persistent = 0x01
        case global = 0x02
        case localized = 0x04

        static let notify = 0x08 | .persistent
        static let normal = .persistent
    }
    // Q_DECLARE_FLAGS(WriteConfigFlags, WriteConfigFlag)

    /*!
     * Returns a list of groups that are known about.
     **/
    public func groupList() -> [String] // = 0;

    /*!
     * Returns \c true if the specified group is known about.
     *
     * \a group name of group to search for
     */
    public func hasGroup(_ group: String) -> Bool

    /*!
     * Returns an object for the named subgroup.
     *
     * \a group the group to open. Pass an empty string here to the KConfig
     *   object to obtain a handle on the root group.
     * Returns config group object for the given group name.
     */
    public func group(_ group: String) -> KConfigGroup

    /*!
     * Const overload for group(const QString&)
     * \overload
     */
    // const KConfigGroup group(const QString &group) const;

    /*!
     * Delete \a group.
     *
     * This marks \a group as deleted in the config object. This effectively
     * removes any cascaded values from config files earlier in the stack.
     */
    public func deleteGroup(_ group: String, _ flags: WriteConfigFlags = .normal)

    /*!
     * Syncs the configuration object that this group belongs to.
     *
     * Unrelated concurrent changes to the same file are merged and thus
     * not overwritten. Note however, that this object is not automatically
     * updated with those changes.
     */
    public func sync() -> Bool // = 0

    /*!
     * Reset the dirty flags of all entries in the entry map, so the
     * values will not be written to disk on a later call to sync().
     */
    public func markAsClean() // = 0;

    /*!
     * Possible return values for accessMode().
     * \value NoAccess
     * \value ReadOnly
     * \value ReadWrite
     */
    public enum AccessMode {
        case noAccess
        case readOnly
        case readWrite
    }

    /*!
     * Returns the access mode of the app-config object.
     *
     * Possible return values
     * are NoAccess (the application-specific config file could not be
     * opened neither read-write nor read-only), ReadOnly (the
     * application-specific config file is opened read-only, but not
     * read-write) and ReadWrite (the application-specific config
     * file is opened read-write).
     */
    public func accessMode() -> AccessMode // = 0;

    /*!
     * Checks whether this configuration object can be modified.
     */
    public func isImmutable() -> Bool // = 0;

    /*!
     * Can changes be made to the entries in \a group?
     *
     * \a group The group to check for immutability.
     *
     * Returns \c false if the entries in \a group can be modified, otherwise \c true
     */
    public func isGroupImmutable(_ group: String) -> Bool

// protected:
    internal init() {
    }

    internal func hasGroupImpl(_ groupName: String) -> Bool // = 0;
    internal func groupImpl(_ groupName: String) -> KConfigGroup // = 0;
    internal func deleteGroupImpl(_ groupName: String, _ flags: WriteConfigFlags = .normal) // = 0;
    internal func isGroupImmutableImpl(_ groupName: String) -> Bool // = 0;

    /*
     * Virtual hook, used to add new "virtual" functions while maintaining
     * binary compatibility. Unused in this class.
     */
    internal func virtual_hook(_ id: Int, _ data: UnsafeMutablePointer<UInt8>?)
}
