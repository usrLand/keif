/*
    This file is part of the KDE libraries
    SPDX-FileCopyrightText: 2006, 2007 Thomas Braxton <kde.braxton@gmail.com>
    SPDX-FileCopyrightText: 2001 Waldo Bastian <bastian@kde.org>
    SPDX-FileCopyrightText: 1999 Preston Brown <pbrown@kde.org>
    SPDX-FileCopyrightText: 1997 Matthias Kalle Dalheimer <kalle@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

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
public struct WriteConfigFlags: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let persistent = WriteConfigFlags(rawValue: 0x01)
    public static let global = WriteConfigFlags(rawValue: 0x02)
    public static let localized = WriteConfigFlags(rawValue: 0x04)
    public static let notify = WriteConfigFlags(rawValue: 0x08 | Self.persistent.rawValue)
    public static let normal = WriteConfigFlags(rawValue: Self.persistent.rawValue)
}
// Q_DECLARE_FLAGS(WriteConfigFlags, WriteConfigFlag)


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

public protocol KConfigBase {
// public:
    /*!
     * Returns a list of groups that are known about.
     **/
    func groupList() -> [String] // = 0;

    /*!
     * Returns \c true if the specified group is known about.
     *
     * \a group name of group to search for
     */
    func hasGroup(_ group: String) -> Bool

    /*!
     * Returns an object for the named subgroup.
     *
     * \a group the group to open. Pass an empty string here to the KConfig
     *   object to obtain a handle on the root group.
     * Returns config group object for the given group name.
     */
    func group(_ group: String) -> KConfigGroup

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
    func deleteGroup(_ group: String, _ flags: WriteConfigFlags)

    /*!
     * Syncs the configuration object that this group belongs to.
     *
     * Unrelated concurrent changes to the same file are merged and thus
     * not overwritten. Note however, that this object is not automatically
     * updated with those changes.
     */
    func sync() -> Bool // = 0

    /*!
     * Reset the dirty flags of all entries in the entry map, so the
     * values will not be written to disk on a later call to sync().
     */
    func markAsClean() // = 0;

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
    func accessMode() -> AccessMode // = 0;

    /*!
     * Checks whether this configuration object can be modified.
     */
    func isImmutable() -> Bool // = 0;

    /*!
     * Can changes be made to the entries in \a group?
     *
     * \a group The group to check for immutability.
     *
     * Returns \c false if the entries in \a group can be modified, otherwise \c true
     */
    func isGroupImmutable(_ group: String) -> Bool

// protected:

    /*
    /* internal */ func hasGroupImpl(_ groupName: String) -> Bool // = 0;
    /* internal */ func groupImpl(_ groupName: String) -> KConfigGroup // = 0;
    /* internal */ func deleteGroupImpl(_ groupName: String, _ flags: WriteConfigFlags) // = 0;
    /* internal */ func isGroupImmutableImpl(_ groupName: String) -> Bool // = 0;
    */

    /*
     * Virtual hook, used to add new "virtual" functions while maintaining
     * binary compatibility. Unused in this class.
     */
    /* internal */ // func virtual_hook(_ id: Int, _ data: UnsafeMutablePointer<UInt8>?)
}

/*
public extension KConfigBase {
    func deleteGroup(_ group: String, _ flags: WriteConfigFlags) {
        deleteGroupImpl(group, flags)
    }

    func hasGroup(_ group: String) -> Bool {
        hasGroupImpl(group)
    }

    func group(_ group: String) -> KConfigGroup {
        groupImpl(group)
    }

    func isGroupImmutable(_ group: String) -> Bool {
        isGroupImmutableImpl(group)
    }

    init() {}
}
*/

internal protocol KConfigBasePrivate {
    func hasGroupImpl(_ groupName: String) -> Bool // = 0;
    func groupImpl(_ groupName: String) -> KConfigGroup // = 0;
    func deleteGroupImpl(_ groupName: String, _ flags: WriteConfigFlags) // = 0;
    func isGroupImmutableImpl(_ groupName: String) -> Bool // = 0;
}
