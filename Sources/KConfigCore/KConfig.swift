/*
    This file is part of the KDE libraries
    SPDX-FileCopyrightText: 2006, 2007 Thomas Braxton <kde.braxton@gmail.com>
    SPDX-FileCopyrightText: 2001 Waldo Bastian <bastian@kde.org>
    SPDX-FileCopyrightText: 1999 Preston Brown <pbrown@kde.org>
    SPDX-FileCopyrightText: 1997 Matthias Kalle Dalheimer <kalle@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import KQt

/*!
 * \class KConfig
 * \inmodule KConfigCore
 *
 * \brief The central class of the KDE configuration data system.
 *
 * In general it is recommended to use KSharedConfig instead of
 * creating multiple instances of KConfig to avoid the overhead of
 * separate objects or concerns about synchronizing writes to disk
 * even if the configuration object is updated from multiple code paths.
 * KSharedConfig provides a set of open methods as counterparts for the
 * KConfig constructors.
 *
 * Load a specific configuration file:
 * \code
 * KConfig config("/etc/kderc");
 * \endcode
 *
 * Load the configuration for an application stored in \c ~/.config/appname/appnamerc:
 * \code
 * KConfig config("appnamerc", KConfig::SimpleConfig, QStandardPaths::AppConfigLocation);
 * \endcode
 * The \c appname should match the name set via QCoreApplication::setApplicationName or the component argument of KAboutData::KAboutData.
 *
 * Load the configuration for an application \c ~/.config/appnamerc:
 * \code
 * KConfig config("appnamerc");
 * \endcode
 *
 * Load the user-specific data files for an application in \c ~/.local/share/appname/appnamerc:
 * \code
 * KConfig config("appnamerc", KConfig::NoGlobals, QStandardPaths::AppDataLocation);
 * \endcode
 *
 * \sa KSharedConfig, KConfigGroup, {https://develop.kde.org/docs/features/configuration/introduction/}{Introduction to KConfig}
 */
public class KConfig: KConfigBase {
// public:
    /*!
     * Determines how the system-wide and user's global settings will affect
     * the reading of the configuration.
     *
     * If CascadeConfig is selected, system-wide configuration sources are used
     * to provide defaults for the settings accessed through this object, or
     * possibly to override those settings in certain cases.
     *
     * If IncludeGlobals is selected, the kdeglobals configuration is used
     * as additional configuration sources to provide defaults. Additionally
     * selecting CascadeConfig will result in the system-wide kdeglobals sources
     * also getting included.
     *
     * Note that the main configuration source overrides the cascaded sources,
     * which override those provided to addConfigSources(), which override the
     * global sources.  The exception is that if a key or group is marked as
     * being immutable, it will not be overridden.
     *
     * Note that all values other than IncludeGlobals and CascadeConfig are
     * convenience definitions for the basic mode.
     * Do not combine them with anything.
     *
     * \value IncludeGlobals Blend kdeglobals into the config object.
     * \value CascadeConfig Cascade to system-wide config files.
     * \value SimpleConfig Just a single config file.
     * \value NoCascade Include user's globals, but omit system settings.
     * \value NoGlobals Cascade to system settings, but omit user's globals.
     * \value FullConfig Fully-fledged config, including globals and cascading to system settings.
     */
    public struct OpenFlags: OptionSet, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let includeGlobals = OpenFlags(rawValue: 0x01)
        public static let cascadeConfig = OpenFlags(rawValue: 0x02)
        public static let simpleConfig = OpenFlags([]) // OpenFlags(rawValue: 0x00)
        public static let noCascade = Self.includeGlobals
        public static let noGlobals = Self.cascadeConfig
        public static let fullConfig = OpenFlags(
            rawValue: Self.includeGlobals.rawValue | Self.cascadeConfig.rawValue
        )
    }

    //=====================
    // Private Variables
    //=====================
    private var _openFlags: OpenFlags
    private var _resourceType: KQStandardPaths.StandardLocation!

    private var _bDirty: Bool
    private var _bReadDefaults: Bool
    private var _bFileImmutable: Bool
    private var _bForceGlobal: Bool
    private var _bSuppressGlobal: Bool

    nonisolated(unsafe) static private var _mappingsRegistered: Bool = false

    private var _entryMap: KEntryMap
    private var _backendType: String
    private var _extraFiles: [String] /* QStack<QString> */

    private var _locale: String
    private var _fileName: String
    private var _etc_kderc: String
    private var _configState: AccessMode

    internal var _backend: KConfigINIBackend

    internal init(
        _ flags: KConfig.OpenFlags,
        _ resourceType: KQStandardPaths.StandardLocation,
        _ backend: KConfigINIBackend? // TODO
    ) {
        _openFlags = flags
        _resourceType = resourceType
        _backend = backend!
        _bDirty = false
        _bReadDefaults = false
        _bFileImmutable = false
        _bForceGlobal = false
        _bSuppressGlobal = false
        _configState = .noAccess
/*
        const bool isTestMode = QStandardPaths::isTestModeEnabled();
        // If sGlobalFileName was initialised and testMode has been toggled,
        // sGlobalFileName may need to be updated to point to the correct kdeglobals file
        if (sGlobalFileName.exists() && s_wasTestModeEnabled != isTestMode) {
            s_wasTestModeEnabled = isTestMode;
            *sGlobalFileName = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation) + QLatin1String("/kdeglobals");
        }

        static QBasicAtomicInt use_etc_kderc = Q_BASIC_ATOMIC_INITIALIZER(-1);
        if (use_etc_kderc.loadRelaxed() < 0) {
            use_etc_kderc.storeRelaxed(!qEnvironmentVariableIsSet("KDE_SKIP_KDERC")); // for unit tests
        }
        if (use_etc_kderc.loadRelaxed()) {
            etc_kderc =
    #ifdef Q_OS_WIN
                QFile::decodeName(qgetenv("WINDIR") + "/kde5rc");
    #else
                QStringLiteral("/etc/kde5rc");
    #endif
            if (!QFileInfo(etc_kderc).isReadable()) {
                use_etc_kderc.storeRelaxed(false);
                etc_kderc.clear();
            }
        }

        setLocale(getDefaultLocaleName());
*/
    }

    /*!
     * Creates a KConfig object to manipulate a configuration file for the
     * current application.
     *
     * If an absolute path is specified for \a file, that file will be used
     * as the store for the configuration settings.  If a non-absolute path
     * is provided, the file will be looked for in the standard directory
     * specified by type.  If no path is provided, a default
     * configuration file will be used based on the name of the main
     * application component.
     *
     * The \a mode determines whether the user or global settings will be allowed
     * to influence the values returned by this object.
     *
     * \note You probably want to use KSharedConfig::openConfig() instead.
     *
     * If an empty string is passed to the \a file and SimpleConfig is passed
     * for the OpenFlags, then an in-memory KConfig object is created
     * that will not write out to file or require any file in the filesystem at all.
     *
     * \sa KConfig::OpenFlags, KSharedConfig::openConfig()
     */
    public init(
        _ file: String = "",
        _ mode: OpenFlags = .fullConfig,
        _ type: KQStandardPaths.StandardLocation = .genericConfigLocation
    ) {
        _openFlags = mode
        _resourceType = type
        self.changeFileName(file) // set the local file name

        // read initial information off disk
        self.reparseConfiguration()
    }

    /*!
     * Creates a KConfig object to manipulate a configuration stored in \a device.
     *
     * The \a device storing the configuration must already be opened and have the required
     * QIODeviceBase::OpenMode.
     *
     * The \a mode determines whether the user or global settings will be allowed
     * to influence the values returned by this object.
     * Defaults to SimpleConfig contrary to the other constructor.
     *
     * \since 6.23
     */
    // KConfig(const std::shared_ptr<QIODevice> &device, OpenFlags mode = SimpleConfig);

    deinit {
        if _bDirty {
            let _ = self.sync()
        }
    }

    //==========================
    // Private Static Methods
    //==========================
    private static func isGroupOrSubGroupMatch(
        _ entryMapIt: KEntryMap.Iterator,
        _ group: String
    ) -> Bool {
        let entryGroup: String = entryMapIt.key.group
        let index = entryGroup.index(entryGroup.startIndex, offsetBy: group.count)
        // Q_ASSERT_X(entryGroup.startsWith(group), Q_FUNC_INFO, "Precondition");
        // return entryGroup.size() == group.size() || entryGroup[group.size()] == '\x1d'
        return entryGroup.count == group.count || entryGroup[index] == "\u{001D}"
    }

    private static func isNonDeletedKey(_ entryMapIt: KEntryMap.Iterator) -> Bool {
        return !entryMapIt.key.key.isEmpty && !entryMapIt.value.deleted
    }

    //=====================
    // Private Methods
    //=====================
    private func hasNonDeletedEntries(_ group: String) -> Bool {
        /*
        return _entryMap.anyEntryWhoseGroupStartsWith(group, [&group](KEntryMapConstIterator entryMapIt) {
            return isGroupOrSubGroupMatch(entryMapIt, group) && isNonDeletedKey(entryMapIt)
        })
        */
        return _entryMap.anyEntryWhoseGroupStartsWith(group) {
            return Self.isGroupOrSubGroupMatch($0, group) && Self.isNonDeletedKey($0)
        }
    }

    private func wantGlobals() -> Bool
    {
        return openFlags.contains(.includeGlobals) && !_bSuppressGlobal
    }
    private func wantDefaults() -> Bool
    {
        return openFlags.contains(.cascadeConfig)
    }
    private func isSimple() -> Bool
    {
        return openFlags == .simpleConfig
    }
    private func isReadOnly() -> Bool
    {
        return _configState == .readOnly
    }

    private func getGlobalFiles() -> [String] {
        // TODO!
        []
    }
    private func parseGlobalFiles() {}

    private func parseConfigFiles() {}
    private func initCustomized(_: KConfig) {}
    private func lockLocal() -> Bool {
        // TODO!
        false
    }

    private func changeFileName(_ name: String) {
        // TODO!
    }

    internal func groupList(_ groupName: String) -> [String] {
        let theGroup = groupName + "\u{001D}"
        return []
        /*
        QSet<QStringView> groups;

        entryMap.forEachEntryWhoseGroupStartsWith(theGroup, [&theGroup, &groups](KEntryMapConstIterator entryMapIt) {
            if (isNonDeletedKey(entryMapIt)) {
                const QString &entryGroup = entryMapIt->first.mGroup;
                const auto subgroupStartPos = theGroup.size();
                const auto subgroupEndPos = findFirstGroupEndPos(entryGroup, subgroupStartPos);
                groups.insert(QStringView(entryGroup).mid(subgroupStartPos, subgroupEndPos - subgroupStartPos));
            }
        });

        return stringListFromStringViewCollection(groups)
        */
    }


    /*!
     * Returns the standard location enum passed to the constructor.
     *
     * Used by KSharedConfig.
     * \since 5.0
     */
    public var locationType: KQStandardPaths.StandardLocation {
        _resourceType
    }

    /*!
     * Returns the filename used to store the configuration.
     */
    public var name: String {
        _fileName
    }

    /*!
     * Returns the flags this object was opened with.
     * \since 5.3
     */
    public var openFlags: OpenFlags {
        _openFlags
    }

    public func sync() -> Bool {
        // TODO!
        false
    }

    /*!
     * Returns \c true if sync has any changes to write out.
     * \since 4.12
     */
    public func isDirty() -> Bool {
        // TODO!
        false
    }

    public func markAsClean() {
        // TODO!
    }

    public func accessMode() -> AccessMode {
        // TODO!
        .noAccess
    }

    /*!
     * Returns whether the configuration can be written to.
     *
     * If \a warnUser is true and the configuration cannot be
     * written to (this method returns \c false), a warning
     * message box will be shown to the user telling them to
     * contact their system administrator to get the problem fixed.
     *
     * The most likely cause for this method returning \c false
     * is that the user does not have write permission for the
     * configuration file.
     */
    public func isConfigWritable(_ warnUser: Bool) -> Bool {
        // TODO!
        false
    }

    /*!
     * Copies all entries form this config object to \a file.
     *
     * If \a config is set, copies the data of this object to \a config.
     *
     * If \a config is not set, creates a new KConfig object.
     *
     * The configuration will not actually be saved to \a file
     * until the returned object is destroyed, or sync() is called
     * on it.
     *
     * \code
     * KConfig *newConfig = config.copyTo("newconfrc");
     * newConfig->sync();
     * \endcode
     *
     * \note Do not forget to delete the returned KConfig object if \a config was nullptr.
     */
    public func copyTo(_ file: String, _ config: KConfig? = nil) -> KConfig? {
        // TODO!
        nil
    }

    /*!
     * Copies all entries from the passed \a config object to this
     * config.
     * \since 6.23
     */
    public func copyFrom(_ config: KConfig) {
        // TODO!
    }

    /*!
     * Ensures that the configuration file contains a certain update.
     *
     * If the configuration file does not contain the update \a id
     * as contained in \a updateFile, kconf_update is run to update
     * the configuration file.
     *
     * If you install config update files with critical fixes
     * you may wish to use this method to verify that a critical
     * update has indeed been performed to catch the case where
     * a user restores an old config file from backup that has
     * not been updated yet.
     */
    public func checkUpdate(_ id: String, _ updateFile: String) {
        // TODO!
    }

    /*!
     * Updates the state of this object to match the persistent storage.
     * Note that if this object has pending changes, this method will
     * call sync() first so as not to lose those changes.
     */
    public func reparseConfiguration() {
        // TODO!
    }

    /*!
     * Adds the list of configuration \a sources to the merge stack.
     *
     * Currently only files are accepted as configuration \a sources.
     *
     * The first entry in \a sources is treated as the most general and will
     * be overridden by the second entry.  The settings in the final entry
     * in \a sources will override all the other sources provided in the list.
     *
     * The settings in \a sources will also be overridden by the sources
     * provided by any previous calls to addConfigSources().
     *
     * The settings in the global configuration sources will be overridden by
     * the sources provided to this method (see IncludeGlobals).
     *
     * All the sources provided to any call to this method will be overridden
     * by any files that cascade from the source provided to the constructor
     * (see CascadeConfig), which will in turn be
     * overridden by the source provided to the constructor.
     *
     * Note that only the most specific file, namely the file provided to the
     * constructor, will be written to by this object.
     *
     * The state is automatically updated by this method, so there is no need to call
     * reparseConfiguration().
     * \sa KConfig::OpenFlags
     */
    public func addConfigSources(_ sources: [String]) {
        for file in sources {
            _extraFiles.append(file)
        }

        if !sources.isEmpty {
            self.reparseConfiguration()
        }
    }

    /*!
     * Returns a list of the additional configuration sources used in this object.
     */
    public func additionalConfigSources() -> [String] {
        // TODO!
        []
    }

    /*!
     * Returns the current locale.
     */
    public func locale() -> String {
        // TODO!
        _locale
    }
    /*!
     * Sets the locale to \a aLocale.
     *
     * The global locale is used by default.
     *
     * \note If set to an empty string, no locale will be matched. This effectively disables
     * reading translated entries.
     *
     * Returns \c true if locale was changed,
     * \c false if the call had no effect
     * (that is, \a aLocale was already the current locale for this object).
     */
    public func setLocale(_ aLocale: String) -> Bool {
        var privateResult = false
        // Private.
        if (aLocale != _locale) {
            _locale = aLocale;
            privateResult = true
        }
        privateResult = false

        // Public.
        if privateResult {
            self.reparseConfiguration()
            return true
        }
        return false
    }

    /*!
     * When \a b is set, all readEntry calls return the system-wide (default) values
     * instead of the user's settings.
     *
     * This is off by default.
     */
    public func setReadDefaults(_ b: Bool) {
        // TODO!
    }
    /*!
     * Returns \c true if the system-wide defaults will be read instead of the user's settings.
     */
    public func readDefaults() -> Bool {
        // TODO!
        false
    }

    public func isImmutable() -> Bool {
        // TODO!
        false
    }

    public func isGroupImmutable(_ group: String) -> Bool {
        // TODO!
        false
    }

    public func groupList() -> [String] {
        // TODO!
        []
    }

    /*!
     * Returns \c true if the specified group is known about.
     *
     * \a group name of group to search for
     */
    public func hasGroup(_ group: String) -> Bool {
        self.hasNonDeletedEntries(group)
    }

    /*!
     * Returns an object for the named subgroup.
     *
     * \a group the group to open. Pass an empty string here to the KConfig
     *   object to obtain a handle on the root group.
     * Returns config group object for the given group name.
     */
    public func group(_ group: String) -> KConfigGroup {
        KConfigGroup(self, group)
    }

    public func deleteGroup(_ group: String, _ flags: WriteConfigFlags) {
        // TODO!
    }

    /*!
     * Returns a map (tree) of entries in \a aGroup, indexed by key.
     *
     * The entries are all returned as strings.
     *
     * The returned map may be empty if the group is empty or not found.
     */
    public func entryMap(_ aGroup: String = "") -> [String:String] {
        // TODO!
        [:]
    }

    /*!
     * Sets the name of the application config file with the given string \a str.
     * \since 5.0
     */
    public static func setMainConfigName(_ str: String) {
        // TODO!
    }

    /*!
     * Get the name of application config file.
     * \since 5.93
     */
    public static func mainConfigName() -> String {
        // TODO!
        ""
    }

// protected:

    // friend class KConfigGroup;
    // friend class KConfigGroupPrivate;
    // friend class KSharedConfig;

    /*
     * Virtual hook, used to add new "virtual" functions while maintaining
     * binary compatibility. Unused in this class.
     */
    // internal func virtual_hook(_ id: Int, _ data: UnsafeMutablePointer<UInt8>) {
    //     let _ = id
    //     let _ = data
    // }

    // internal init(_ d: KConfigPrivate)

// private:
    // friend class KConfigTest;

    // Q_DISABLE_COPY(KConfig)

    // Q_DECLARE_PRIVATE(KConfig)
}
// Q_DECLARE_OPERATORS_FOR_FLAGS(KConfig::OpenFlags)
