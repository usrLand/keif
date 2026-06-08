/*
    This file is part of the KDE libraries
    SPDX-FileCopyrightText: 2000 Reginald Stadlbauer <reggie@kde.org>
    SPDX-FileCopyrightText: 1997 Stephan Kulow <coolo@kde.org>
    SPDX-FileCopyrightText: 1997-2000 Sven Radej <radej@kde.org>
    SPDX-FileCopyrightText: 1997-2000 Matthias Ettrich <ettrich@kde.org>
    SPDX-FileCopyrightText: 1999 Chris Schlaeger <cs@kde.org>
    SPDX-FileCopyrightText: 2002 Joseph Wenninger <jowenn@kde.org>
    SPDX-FileCopyrightText: 2005-2006 Hamish Rodda <rodda@kde.org>
    SPDX-FileCopyrightText: 2000-2008 David Faure <faure@kde.org>

    SPDX-License-Identifier: LGPL-2.0-only
*/

import Blusher

import KCoreAddons

/*!
 * \class KMainWindow
 * \inmodule KXmlGui
 *
 * \brief KMainWindow represents a top-level main window.
 *
 * It extends QMainWindow with session management capabilities. For ready-made window functionality and simpler UI management, use KXmlGuiWindow instead.
 *
 * Define the minimum/maximum height/width of your central widget and KMainWindow will take this into account.
 * For fixed size windows set your main widget to a fixed size. Fixed aspect ratios (QWidget::heightForWidth()) and fixed width widgets are not supported.
 *
 * Use toolBar() to generate a main toolbar "mainToolBar" or refer to a specific toolbar.
 * For a simpler way to manage your toolbars, use KXmlGuiWindow::setupGUI() instead.
 *
 * Use setAutoSaveSettings() to automatically save and restore the window geometry and toolbar/menubar/statusbar state when the application is restarted.
 *
 * Use kRestoreMainWindows() in your main function to restore your windows when the session is restored.
 *
 * The window state is saved when the application is exited.
 * Reimplement queryClose() to warn the user of unsaved data upon close or exit.
 *
 * Reimplement saveProperties() / readProperties() or saveGlobalProperties() / readGlobalProperties()
 * to save/restore application-specific state during session management.
 *
 * Note that session saving is automatically called, session restoring is not,
 * and so it needs to be implemented in your main() function.
 *
 * See \l https://develop.kde.org/docs/features/session-managment for more information on session management.
 */
open class KMainWindow: BWindow {
    // friend class KMWSessionManager;
    // friend class DockResizeListener;

    //====================
    // C++ Private pImpl
    //====================
    private var p_settingsDirty: Bool
    private var p_autoSaveWindowSize: Bool
    private var p_sizeApplied: Bool
    private var p_suppressCloseEvent: Bool

    private var p_autoSaveGroup: KConfigGroup
    internal var _stateConfigGroup: KConfigGroup

    // inline
    private func getStateConfig() -> KConfigGroup {
        if (!_stateConfigGroup.isValid()) {
            // Always use a separate state config here, consumers may override this with a custom/window-specific group
            _stateConfigGroup = KSharedConfig::openStateConfig()->group(QStringLiteral("MainWindow"));
        }
        return _stateConfigGroup;
    }
    // inline
    private func migrateStateDataIfNeeded(_ cg: KConfigGroup) {
        if (m_stateConfigGroup.isValid()) {
            // The window sizes are written in KWindowSystem and RestorePositionForNextInstance is only temporarily written until
            // all instances of the app are closed
            cg.moveValuesTo({"State"}, m_stateConfigGroup);
        }
    }

    private var p_settingsTimer: QTimer?
    private var p_sizeTimer: QTimer?
    private var defaultWindowSize: QRect?
    private var helpMenu: KHelpMenu?
    private var q: KMainWindow?
    private weak var dockResizeListener: AnyObject?
    private var p_dbusName: String
    private var letDirtySettings: Bool
    private var locker: QEventLoopLocker

    // This slot will be called when the style KCM changes settings that need
    // to be set on the already running applications.
    private func _k_slotSettingsChanged(_ category: Int) {
        // TODO!
    }
    private func _k_slotSaveAutoSaveSize() {
        // TODO!
    }
    private func _k_slotSaveAutoSavePosition() {
        // TODO!
    }

    private func initialize(_ _q: KMainWindow?) {
        q = _q;

        q.setAnimated(q.style()->styleHint(QStyle::SH_Widget_Animate, nullptr, q));

        q.setAttribute(Qt::WA_DeleteOnClose);

        helpMenu = nil

        // actionCollection()->setWidget( this );
#if false
        QObject::connect(KGlobalSettings::self(), SIGNAL(settingsChanged(int)),
                        q, SLOT(_k_slotSettingsChanged(int)));
#endif

#if !QT_NO_SESSIONMANAGER
        // force KMWSessionManager creation
        ksm();
#endif

        sMemberList()->append(q);

        // If application is translated, load translator information for use in
        // KAboutApplicationDialog or other getters. The context and messages below
        // both must be exactly as listed, and are forced to be loaded from the
        // application's own message catalog instead of kxmlgui's.
        let aboutData: KAboutData = KAboutData.applicationData()
        if (aboutData.translators().isEmpty()) {
            aboutData.setTranslator(i18ndc(nullptr, "NAME OF TRANSLATORS", "Your names"), //
                                    i18ndc(nullptr, "EMAIL OF TRANSLATORS", "Your emails"));

            KAboutData::setApplicationData(aboutData);
        }

        p_settingsDirty = false
        autoSaveSettings = false
        p_autoSaveWindowSize = true // for compatibility
        // d->kaccel = actionCollection()->kaccel();
        settingsTimer = nil
        sizeTimer = nil

        dockResizeListener = DockResizeListener(_q)
        letDirtySettings = true

        sizeApplied = false
        suppressCloseEvent = false

        qApp->installEventFilter(KToolTipHelper::instance());

        // create the conflict detector only if some main window got created
        // before we did that on library load, that might mess with plain Qt applications
        // see bug 467130
        static QPointer<KActionConflictDetector> conflictDetector;
        if (!conflictDetector) {
            conflictDetector = new KActionConflictDetector(QCoreApplication::instance());
            QCoreApplication::instance()->installEventFilter(conflictDetector);
        }

        // same for accelerator checking
        KCheckAccelerators::initiateIfNeeded();
    }
    private func polish(_ q: KMainWindow?) {
        // TODO!
    }

    enum CallCompression: Int {
        case NoCompressCalls = 0
        case CompressCalls = 1
    }
    private func setSettingsDirty(_ callCompression: CallCompression = .NoCompressCalls) {
        // TODO!
    }
    private func setSizeDirty() {
        // TODO!
    }

    //================
    // Class Begin
    //================

    private var _hasMenuBar: Bool
    private var _autoSaveSettings: Bool
    private var _autoSaveGroup: String

    public var hasMenuBar: Bool {
        _hasMenuBar
    }

    public var autoSaveSettings: Bool {
        get { _autoSaveSettings }
        set { _autoSaveSettings = newValue }
    }

    public var autoSaveGroup: String {
        get {
            autoSaveSettings ? p_autoSaveGroup.name() : ""
        }
    }

// public:
    /*!
     * \brief Constructs a main window.
     *
     * \a parent The parent widget. This is usually \c nullptr, but it may also be
     * the window group leader. In that case,
     * the KMainWindow becomes a secondary window.
     *
     * \a flags Specify the window flags. The default is none.
     *
     * Note that by default a KMainWindow is created with the
     * Qt::WA_DeleteOnClose attribute set, i.e. it is automatically destroyed
     * when the window is closed. If you do not want this behavior, call
     * \code
     * window->setAttribute(Qt::WA_DeleteOnClose, false);
     * \endcode
     *
     * KMainWindows must be created on the heap with 'new', like:
     * \code
     * KMainWindow *kmw = new KMainWindow(...);
     * kmw->setObjectName(...);
     * \endcode
     *
     * Since KDE Frameworks 5.16, KMainWindow will enter information regarding
     * the application's translators by default, using KAboutData::setTranslator(). This only occurs
     * if no translators are already assigned in KAboutData (see KAboutData::setTranslator() for
     * details -- the auto-assignment here uses the same translated strings as specified for that
     * function).
     *
     * \warning For session management and window management to work
     * properly, all main windows in the application should have a
     * different name. Otherwise, KMainWindow will create
     * a unique name, but it's recommended to explicitly pass a window name that will
     * also describe the type of the window. If there can be several windows of the same
     * type, append '#' (hash) to the name, and KMainWindow will replace it with numbers to make
     * the names unique. For example, for a mail client which has one main window showing
     * the mails and folders, and which can also have one or more windows for composing
     * mails, the name for the folders window should be e.g. "mainwindow" and
     * for the composer windows "composer#".
     *
     * \sa KAboutData
     */
    public init(parent: BWindow? = nil /*, Qt::WindowFlags flags = Qt::WindowFlags() */) {
        //=====================
        // Private Init
        //=====================
        self.initialize(self)

        //=====================
        // Public Init
        //=====================

        // TODO!
    }

    /*!
     * \brief Destructor.
     *
     * Will also destroy the toolbars and menubar if
     * needed.
     */
    deinit {
        // TODO!
    }

    /*!
     * Returns \c true if the number of KMainWindow instances of the previous session did contain the requested \a numberOfInstances, \c false otherwise.
     *
     * \a numberOfInstances The number of KMainWindow instances in the application.
     *
     * \sa restore()
     **/
    static public func canBeRestored(_ numberOfInstances: Int) -> Bool {
        // TODO!
    }

    /*!
     * \brief Useful if your application uses
     * different kinds of top-level windows.
     *
     * Returns The class name of the top-level window to be restored
     * that corresponds to \a instanceNumber.
     *
     * \sa restore()
     */
    static public func classNameOfToplevel(_ instanceNumber: Int) -> String {
        // TODO!
    }

    /*!
     * \brief Attempt to restore the top-level widget as defined by \a numberOfInstances (1..X).
     *
     * You should call canBeRestored() first.
     *
     * If the session did not contain so high a number, the configuration
     * is not changed and \c false is returned.
     *
     * That means clients could simply do the following:
     * \code
     * if (qApp->isSessionRestored()){
     *   int n = 1;
     *   while (KMainWindow::canBeRestored(n)){
     *     (new childMW)->restore(n);
     *     n++;
     *   }
     * } else {
     *   // create default application as usual
     * }
     * \endcode
     * Note that if \a show is \c true (default), QWidget::show() is called
     * implicitly in restore.
     *
     * With this you can easily restore all top-level windows of your
     * application.
     *
     * If your application uses different kinds of top-level
     * windows, then you can use KMainWindow::classNameOfToplevel(n)
     * to determine the exact type before calling the childMW
     * constructor in the example from above.
     *
     * \note You don't need to deal with this function. Use the
     * kRestoreMainWindows() convenience template function instead!
     *
     * \a numberOfInstances The number of KMainWindow instances from the last session.
     *
     * \a show Whether the KMainWindow instances will be visible by default.
     *
     * Returns \c true if the session contained
     * the same number of instances as the requested number,
     * \c false if the session contained less instances than the requested number,
     * in which case no configuration is changed.
     *
     * \sa kRestoreMainWindows()
     * \sa readProperties()
     * \sa canBeRestored()
     */
    public func restore(_ numberOfInstances: Int, _ show: Bool = true) -> Bool {
        // TODO!
    }

    /*!
     * Returns \c true if there is a menubar, \c false otherwise.
     */
    // bool hasMenuBar()

    /*!
     * Returns The list of members of the KMainWindow class.
     */
    static public func memberList() -> [KMainWindow] {
        // TODO!
        return []
    }

    /*!
     * \brief This is useful to both call specific toolbars that have been created
     * or to generate a default one upon call.
     *
     * This refers to toolbars created dynamically from the XML UI
     * framework via KConfig or appnameui.rc.
     *
     * If the toolbar does not exist, one will be created.
     *
     * \a name The internal name of the toolbar. If no name is specified,
     * "mainToolBar" is assumed.
     *
     * Returns A pointer to the toolbar with the specified name.
     * \sa toolBars()
     **/
    public func toolBar(_ name: String = "") -> KToolBar? {
        // TODO!
        return nil
    }

    /*!
     * Returns a list of all toolbars for this window
     */
    public func toolBars() -> [KToolBar] {
        // TODO!
        return []
    }

    /*!
     * \brief This enables autosave of toolbar/menubar/statusbar settings
     * (and optionally window size).
     *
     * \a groupName A name that identifies the type of window.
     * You can have several types of window in the same application.
     * If no \a groupName is specified, the value defaults to "MainWindow".
     *
     * \a saveWindowSize Whether to include the window size
     * when saving. \c true by default.
     *
     * If the *bars were modified when the window is closed,
     * \c {saveMainWindowSettings( KConfigGroup(KSharedConfig::openConfig(), groupName) )} will be called.
     *
     * Typically, you will call setAutoSaveSettings() in your
     * KMainWindow-inherited class constructor, and it will take care
     * of restoring and saving automatically.
     *
     * By default, this generates an
     * appnamerc ini file as if using default KConfig constructor or KConfig::SimpleConfig.
     *
     * Make sure you call this \b after all your *bars have been created.
     *
     * To make sure that KMainWindow properly obtains the default
     * size of the window you should do the following:
     * - Remove hardcoded resize() calls in the constructor or main
     *   to let the automatic resizing determine the default window size.
     *   Hardcoded window sizes will be wrong for users that have big fonts,
     *   use different styles, long/small translations, large toolbars, and other factors.
     * - Put the setAutoSaveSettings() call after all widgets
     *   have been created and placed inside the main window
     *   (for most apps this means QMainWindow::setCentralWidget())
     * - QWidget-based objects should overload "virtual QSize sizeHint() const;"
     *   to specify a default size.
     * \sa KConfig
     * \sa KSharedConfig
     * \sa saveMainWindowSettings()
     * \sa toolBar()
     * \sa KXmlGuiWindow::setupGUI()
     */
    public func setAutoSaveSettings(
        _ groupName: String = "MainWindow",
        _ saveWindowSize: Bool = true
    ) {
        self.setAutoSaveSettings(KConfigGroup(KSharedConfig.openConfig(), groupName), saveWindowSize)
    }

    /*!
     * \overload KMainWindow::setAutoSaveSettings(const QString &groupName = QStringLiteral("MainWindow"), bool saveWindowSize = true)
     *
     * This allows the settings to be saved into a different file
     * that does not correspond to that used for KSharedConfig::openConfig().
     *
     * \a group A name that identifies the type of window.
     * You can have several types of window in the same application.
     *
     * \a saveWindowSize Whether to include the window size
     * when saving. \c true by default.
     *
     * \sa setAutoSaveSettings(const QString &groupName, bool saveWindowSize)
     * \sa KConfig
     * \sa KSharedConfig
     * \since 4.1
     */
    public func setAutoSaveSettings(_ group: KConfigGroup, _ saveWindowSize: Bool = true) {
        // We re making a little assumption that if you want to save the window
        // size, you probably also want to save the window position too
        // This avoids having to re-implement a new version of
        // KMainWindow::setAutoSaveSettings that handles these cases independently
        autoSaveSettings = true
        p_autoSaveGroup = group
        p_autoSaveWindowSize = saveWindowSize

        if (!saveWindowSize && p_sizeTimer != nil) {
            p_sizeTimer?.stop()
        }

        // Now read the previously saved settings
        applyMainWindowSettings(p_autoSaveGroup)
    }

    /*!
     * \brief Disables the autosave settings feature.
     * You don't normally need to call this, ever.
     * \sa setAutoSaveSettings()
     * \sa autoSaveSettings()
     */
    public func resetAutoSaveSettings() {
        autoSaveSettings = false
        if (p_settingsTimer) {
            p_settingsTimer?.stop()
        }
    }

    /*!
     * Returns \c true if setAutoSaveSettings() was called,
     * \c false by default or if resetAutoSaveSettings() was called.
     * \sa setAutoSaveSettings()
     * \sa resetAutoSaveSettings()
     */
    // public func autoSaveSettings() -> Bool {
    //     // TODO!
    // }

    /*!
     * Returns The group used for autosaving settings.
     *
     * Do not mistake this with autoSaveConfigGroup.
     *
     * Only meaningful if setAutoSaveSettings(const QString&, bool) was called.
     *
     * Do not use this method if setAutoSaveSettings(const KConfigGroup&, bool) was called.
     *
     * This can be useful for forcing a save or an apply, e.g. before and after
     * using KEditToolBar.
     *
     * \note Prefer saveAutoSaveSettings() for saving or autoSaveConfigGroup() for loading.
     *
     * \sa autoSaveSettings()
     * \sa setAutoSaveSettings()
     * \sa saveAutoSaveSettings()
     * \sa resetAutoSaveSettings()
     * \sa autoSaveConfigGroup()
     */

    /*!
     * Returns The group used for autosaving settings.
     *
     * Only meaningful if setAutoSaveSettings(const QString&, bool) was called.
     *
     * Do not use this method if setAutoSaveSettings(const KConfigGroup&, bool) was called.
     *
     * This can be useful for forcing an apply, e.g. after using KEditToolBar.
     *
     * \sa setAutoSaveSettings()
     * \sa autoSaveGroup()
     * \since 4.1
     */
    public func autoSaveConfigGroup() -> KConfigGroup {
        // TODO!
    }

    /*!
     * \brief Assigns the config group name for the KConfigGroup returned by stateConfigGroup.
     *
     * \a configGroup The config group to be assigned.
     *
     * Window size and state are stored in the resulting KConfigGroup when this function is called.
     * \note If this is used in combination with setAutoSaveSettings, you should call this method first.
     *
     * \sa KConfigGroup
     * \sa KSharedConfig::openStateConfig()
     * \sa stateConfigGroup()
     *
     * \since 5.88
     */
    public func setStateConfigGroup(_ configGroup: String) {
        // TODO!
    }

    /*!
     * Returns The KConfigGroup used to store state data like window sizes or window state.
     *
     * The resulting group is invalid if setStateConfig is not called explicitly.
     *
     * \sa KConfigGroup
     * \since 5.88
     */
    public func stateConfigGroup() -> KConfigGroup {
        // TODO!
    }

    /*!
     * \brief Read settings for statusbar, menubar and toolbar from their respective
     * groups in the config file and apply them.
     *
     * \a config Config group to read the settings from.
     */
    public func applyMainWindowSettings(_ config: KConfigGroup) {
        // TODO!
    }

    /*!
     * \brief Manually save the settings for statusbar, menubar and toolbar to their respective
     * groups in the KConfigGroup \a config.
     *
     * Usage example:
     * \code
     * KConfigGroup group(KSharedConfig::openConfig(), "MainWindow");
     * saveMainWindowSettings(group);
     * \endcode
     *
     * \a config Config group to save the settings to.
     * \sa setAutoSaveSettings()
     * \sa KConfig
     * \sa KSharedConfig
     * \sa KConfigGroup
     */
    public func saveMainWindowSettings(_ config: KConfigGroup) {
        // TODO!
    }

    /*!
     * Returns The path for the exported window's D-Bus object.
     * \since 4.0.1
     */
    public func dbusName() -> String {
        return p_dbusName
    }

// public Q_SLOTS:
    /*!
     * \brief Assigns a KDE compliant caption (window title).
     *
     * \a caption The string that will be
     * displayed in the window title, before the application name.
     *
     * \note This function does the same as setPlainCaption().
     *
     * \note Do not include the application name
     * in this string. It will be added automatically according to the KDE
     * standard.
     *
     * \sa setPlainCaption()
     */
    virtual void setCaption(const QString &caption);
    /*!
     * \brief Makes a KDE compliant caption.
     *
     * \a caption Your caption.
     *
     * \a modified Whether the document is modified. This displays
     * an additional sign in the title bar, usually "**".
     *
     * \overload
     *
     * \note Do not include the application name
     * in this string. It will be added automatically according to the KDE
     * standard.
     */
    virtual void setCaption(const QString &caption, bool modified);

    /*!
     * \brief Make a plain caption without any modifications.
     *
     * \a caption The string that will be
     * displayed in the window title, before the application name.
     *
     * \note This function does the same as setCaption().
     *
     * \note Do not include the application name
     * in this string. It will be added automatically according to the KDE
     * standard.
     *
     * \sa setCaption()
     */
    virtual void setPlainCaption(const QString &caption);

    /*!
     * \brief Opens the help page for the application.
     *
     * The application name is
     * used as a key to determine what to display and the system will attempt
     * to open \<appName\>/index.html.
     *
     * This method is intended for use by a help button in the toolbar or
     * components outside the regular help menu.
     *
     * Use helpMenu() when you
     * want to provide access to the help system from the help menu.
     *
     * Example (adding a help button to the first toolbar):
     *
     * \code
     * toolBar()->addAction(QIcon::fromTheme("help-contents"), i18n("Help"),
     *                       this, &KMainWindow::appHelpActivated);
     * \endcode
     *
     * \sa helpMenu()
     * \sa toolBar()
     */
    void appHelpActivated();

    /*!
     * \brief Tell the main window that it should save its settings when being closed.
     *
     * This is part of the autosave settings feature.
     *
     * For everything related to toolbars this happens automatically,
     * but you have to call setSettingsDirty() in the slot that toggles
     * the visibility of the statusbar.
     *
     * \sa saveAutoSaveSettings()
     */
    void setSettingsDirty();

// protected:
    /*!
     * Reimplemented to return the \a event QEvent::Polish in order to adjust the object name
     * if needed, once all constructor code for the main window has run.
     * Also reimplemented to catch when a QDockWidget is added or removed.
     *
     * \reimp
     */
    internal func event(_ event: QEvent) -> Bool {
        // TODO!
    }

    /*!
     * \brief Reimplemented to open context menus on Shift+F10.
     *
     * \a keyEvent The event assigned to a key press.
     *
     * \reimp
     */
    void keyPressEvent(QKeyEvent *keyEvent) override;

    /*!
     * Reimplemented to autosave settings and call queryClose().
     *
     * We recommend that you reimplement queryClose() rather than closeEvent().
     * If you do it anyway, ensure to call the base implementation to keep
     * the feature of autosaving window settings working.
     *
     * \reimp
     */
    void closeEvent(QCloseEvent *) override;

    /*!
     * \brief This function is called before the window is closed,
     * either by the user or indirectly by the session manager.
     *
     * This can be used to prompt the user to save unsaved data before the window is closed.
     *
     * Usage example:
     * \code
     * switch ( KMessageBox::warningTwoActionsCancel( this,
     *          i18n("Save changes to document foo?"), QString(),
     *          KStandardGuiItem::save(), KStandardGuiItem::discard())) ) {
     *   case KMessageBox::PrimaryAction :
     *     // save document here. If saving fails, return false;
     *     return true;
     *   case KMessageBox::SecondaryAction :
     *     return true;
     *   default: // cancel
     *     return false;
     * \endcode
     *
     * \note Do \b not close the document from within this method,
     * as it may be called by the session manager before the
     * session is saved. If the document is closed before the session save occurs,
     * its location might not be properly saved. In addition, the session shutdown
     * may be canceled, in which case the document should remain open.
     *
     * Returns \c true by default, \c false according to the reimplementation.
     * Returning \c false will cancel the closing operation,
     * and if KApplication::sessionSaving() is true, it cancels logout.
     */
    virtual bool queryClose();

    /*!
     * \brief Saves your instance-specific properties.
     *
     * The function is
     * invoked when the session manager requests your application
     * to save its state.
     *
     * Reimplement this function in child classes.
     *
     * Usage example:
     * \code
     * void MainWindow::saveProperties(KConfigGroup &config) {
     *   config.writeEntry("myKey", "newValue");
     *   ...
     * }
     * \endcode
     *
     * \note No user interaction is allowed in this function!
     *
     */
    virtual void saveProperties(KConfigGroup &)
    {
    }

    /*!
     * \brief Reads your instance-specific properties.
     *
     * This function is called indirectly by restore().
     *
     * \code
     * void MainWindow::readProperties(KConfigGroup &config) {
     *   if (config.hasKey("myKey")) {
     *     config.readEntry("myKey", "DefaultValue");
     *   }
     *   ...
     * }
     * \endcode
     *
     * \sa readGlobalProperties()
     */
    virtual void readProperties(const KConfigGroup &)
    {
    }

    /*!
     * \brief Saves your application-wide properties.
     *
     * \a sessionConfig A pointer to the KConfig instance
     * used to save the session data.
     *
     * This function is invoked when the session manager
     * requests your application to save its state.
     * It is similar to saveProperties(), but it is only called for
     * the first main window. This is useful to save global state of your application
     * that isn't bound to a particular window.
     *
     * The default implementation does nothing.
     *
     * \sa readGlobalProperties()
     * \sa saveProperties()
     */
    virtual void saveGlobalProperties(KConfig *sessionConfig);

    /*!
     * \brief Reads your application-wide properties.
     *
     * \a sessionConfig A pointer to the KConfig instance
     * used to load the session data.
     *
     * \sa saveGlobalProperties()
     * \sa readProperties()
     *
     */
    virtual void readGlobalProperties(KConfig *sessionConfig);
    void savePropertiesInternal(KConfig *, int);
    bool readPropertiesInternal(KConfig *, int);

    /*!
     * \brief Returns whether there are unsaved changes.
     *
     * For inherited classes.
     */
    internal func settingsDirty() -> Bool {
        // TODO!
    }

// protected Q_SLOTS:
    /*!
     * This slot should only be called in case you reimplement closeEvent() and
     * if you are using the autosave feature. In all other cases,
     * setSettingsDirty() should be called instead to benefit from the delayed
     * saving.
     *
     * Usage example:
     * \code
     *
     * void MyMainWindow::closeEvent( QCloseEvent *e )
     * {
     *   // Save settings if autosave is enabled, and settings have changed
     *   if ( settingsDirty() && autoSaveSettings() )
     *     saveAutoSaveSettings();
     *   ..
     * }
     * \endcode
     *
     * \sa setAutoSaveSettings()
     * \sa setSettingsDirty()
     */
    internal func saveAutoSaveSettings() {
        //
    }

// protected:
    internal init(_ dd: KMainWindowPrivate, _ parent: BWindow? /* _ f: Qt::WindowFlags*/) {
        // TODO!
    }

    internal var _d_ptr: KMainWindowPrivate

// private:
    Q_DECLARE_PRIVATE(KMainWindow)

    Q_PRIVATE_SLOT(d_func(), void _k_slotSettingsChanged(int))
    Q_PRIVATE_SLOT(d_func(), void _k_slotSaveAutoSaveSize())
    Q_PRIVATE_SLOT(d_func(), void _k_slotSaveAutoSavePosition())

    /*!
    * \macro KDE_RESTORE_MAIN_WINDOWS_NUM_TEMPLATE_ARGS
    *
    * \relates KMainWindow
    *
    * Returns the maximal number of arguments that are actually
    * supported by kRestoreMainWindows().
    **/
    // #define KDE_RESTORE_MAIN_WINDOWS_NUM_TEMPLATE_ARGS 3
    public static let KDE_RESTORE_MAIN_WINDOWS_NUM_TEMPLATE_ARGS = 3

    /*!
    * \fn template<typename T> void kRestoreMainWindows()
    * \brief Restores the last session. (To be used in your main function).
    *
    * \relates KMainWindow
    *
    * These functions work also if you have more than one kind of top-level
    * widget (each derived from KMainWindow, of course).
    *
    * Imagine you have three kinds of top-level widgets: the classes \c ChildMW1,
    * \c ChildMW2 and \c ChildMW3. Then you can just do:
    *
    * \code
    * int main(int argc, char *argv[])
    * {
    *     // [...]
    *     if (qApp->isSessionRestored())
    *         kRestoreMainWindows<ChildMW1, ChildMW2, ChildMW3>();
    *     else {
    *       // create default application as usual
    *     }
    *     // [...]
    * }
    * \endcode
    *
    * kRestoreMainWindows will create (on the heap) as many instances
    * of your main windows as have existed in the last session and
    * call KMainWindow::restore() with the correct arguments. Note that
    * also QWidget::show() is called implicitly.
    *
    * Currently, these functions are provided for up to three
    * template arguments. If you need more, tell us. To help you in
    * deciding whether or not you can use kRestoreMainWindows, a
    * define KDE_RESTORE_MAIN_WINDOWS_NUM_TEMPLATE_ARGS is provided.
    *
    * \note Prefer this function over directly calling KMainWindow::restore().
    *
    * \sa KMainWindow::restore()
    * \sa KMainWindow::classNameOfToplevel()
    */
    // @inline
    private func kRestoreMainWindows<T>() {
        /*
        for (int n = 1; KMainWindow::canBeRestored(n); ++n) {
            const QString className = KMainWindow::classNameOfToplevel(n);
            if (className == QLatin1String(T::staticMetaObject.className())) {
                (new T)->restore(n);
            }
        }
        */
    }

    // @inline
    private func kRestoreMainWindows<T0, T1, each Tn>() {
        /*
        self.kRestoreMainWindows<T0>()
        self.kRestoreMainWindows<T1, Tn...>()
        */
    }
}

class KMWSessionManager {
// public:
    init() {
#if !QT_NO_SESSIONMANAGER
        connect(qApp, &QGuiApplication::saveStateRequest, this, &KMWSessionManager::saveState);
        connect(qApp, &QGuiApplication::commitDataRequest, this, &KMWSessionManager::commitData);
#endif
    }

    deinit {}

// private:
    private func saveState(_: QSessionManager)
    private func commitData(_: QSessionManager)
}
