import KQt
import Blusher

nonisolated(unsafe) internal var KABOUTDATA = "kf.coreaddons.kaboutdata"

internal func qCWarning(_ category: String, _ msg: String) {
    print(" !WARN! (\(category)) - \(msg)")
}

internal func warnIfOutOfSync(
    _ aboutDataString: String,
    _ aboutDataValue: String,
    _ appDataString: String,
    _ appDataValue: String
) {
    if (aboutDataValue != appDataValue) {
        let msg = "\(appDataString) \(aboutDataString) \(appDataValue) is out-of-sync with \(aboutDataString) \(aboutDataValue)"
        qCWarning(KABOUTDATA, msg)
    }
}

internal func resolveLanguage(
    _ value: Dictionary<String, String>,
    _ langs: [String] = ["en-US"] // QLocale().uiLanguages()
) -> String {
    for (index, lang) in langs.enumerated() {
        let it = value[lang]
        if let it = it {
            return it
        }

        let idx = lang.firstIndex(of: "-")
        if idx == nil || lang.hasPrefix("-") {
            continue
        }

        let genericLang = lang[..<idx!]
        if index + 1 < langs.count && langs[index + 1].starts(with: genericLang) {
            continue
        }
        if value.keys.firstIndex(of: String(genericLang)) != nil {
            return value[String(genericLang)]!
        }
    }

    return value[""] ?? ""
}

// built-in entities that QXmlStreamReader resolves and that we need to re-apply to rich text content
let entityMap: Dictionary<Character, String> = [
    "<": "lt",
    ">": "gt",
    "&": "amp",
    "'": "apos",
    "\"": "quot",
]

internal func quoteEntities(_ s: String) -> String {
    var out = ""
    for ch in s {
        /*
        const auto it = std::ranges::find_if(entity_map, [c](const auto &m) {
            return m.c == c.cell() && c.row() == 0;
        });
        */
        if let found = entityMap[ch] {
            out += "&\(found);"
        } else {
            out.append(ch)
        }
    }
    return out;
}

internal func readAppStreamDescription(_ reader: KQXMLStreamReader) -> AppDataDesc {
    var desc = AppDataDesc()

    var elemName = ""
    var translationBuffer: Dictionary<String, String> = [:]

    while (!reader.atEnd && !reader.hasError) {
        let token = reader.readNext()
        if (token == .endElement) {
            break
        }
        if (token == .startElement) {
            let lang = reader.attributesValueNamespace(
                "http://www.w3.org/XML/1998/namespace", "lang")
            if ((lang.isEmpty || elemName != reader.name) && !translationBuffer.isEmpty) {
                /*
                desc.desc += '<'_L1 + elemName + '>'_L1
                    + resolveLanguage(translationBuffer)
                    + "</"_L1
                    + elemName
                    + '>'_L1;
                */
                desc.desc += "<\(elemName)>\(resolveLanguage(translationBuffer))</\(elemName)>"
                translationBuffer.removeAll()
            }
            elemName = reader.name
            let subDesc = readAppStreamDescription(reader)
            translationBuffer[lang] = subDesc.desc
            /*
            if (lang.isEmpty && !translationBuffer.isEmpty) {
                desc.rawDesc += '<'_L1 + elemName + '>'_L1
                    + resolveLanguage(translationBuffer, {})
                    + "</"_L1 + elemName + '>'_L1;
            */
            desc.rawDesc +=
                "<\(elemName)>\(resolveLanguage(translationBuffer, []))</\(elemName)>"
        }
        if (token == .characters && !reader.isWhitespace) {
            if (!translationBuffer.isEmpty) {
                /*
                desc.desc += '<'_L1 + elemName + '>'_L1
                    + resolveLanguage(translationBuffer)
                    + "</"_L1 + elemName + '>'_L1;
                */
                desc.desc += "<\(elemName)>\(resolveLanguage(translationBuffer))</\(elemName)>"
                /*
                desc.rawDesc += '<'_L1 + elemName + '>'_L1
                    + resolveLanguage(translationBuffer, [])
                    + "</"_L1 + elemName + '>'_L1;
                */
                desc.rawDesc +=
                    "<\(elemName)>\(resolveLanguage(translationBuffer, []))</\(elemName)>"
                translationBuffer.removeAll()
            }
            desc.desc += quoteEntities(reader.text)
            desc.rawDesc += quoteEntities(reader.text)
        }
    }
    if (!translationBuffer.isEmpty) {
        // desc.desc += '<'_L1 + elemName + '>'_L1
        //     + resolveLanguage(translationBuffer) + "</"_L1 + elemName + '>'_L1;
        desc.desc += "<\(elemName)>\(resolveLanguage(translationBuffer))</\(elemName)>"
    }

    desc.desc = String(desc.desc
        .reversed()
        .drop(while: \.isWhitespace)
        .reversed())
    desc.rawDesc = String(desc.rawDesc
        .reversed()
        .drop(while: \.isWhitespace)
        .reversed())
    return desc;
}

internal struct AppDataDesc {
    var desc: String
    var rawDesc: String

    init() {
        desc = ""
        rawDesc = ""
    }
}

public class KAboutData {
    private var _displayName: String = ""
    private var _productName: String = ""
    private var _componentName: String = ""
    private var _programLogo: Any = 0
    private var _shortDescription: String = ""
    private var _homepage: String = ""
    private var _bugAddress: String = ""
    private var _version: String = ""
    private var _otherText: String = ""
    private var _authors: [KAboutPerson] = []
    private var _credits: [KAboutPerson] = []
    private var _translators: [KAboutPerson] = []
    private var _components: [KAboutComponent] = []
    private var _licenses: [KAboutLicense] = []
    private var _copyrightStatement: String = ""
    private var _desktopFileName: String = ""
    private var _releases: [KAboutRelease] = []

    private var _customAuthorPlainText: String = ""
    private var _customAuthorRichText: String = ""
    private var _customAuthorTextEnabled: Bool = false
    private var _organizationDomain: String = ""

    internal var _internalProgramName: String = ""

    /*!
     * \property KAboutData::displayName
     */
    public var displayName: String {
        get { _displayName }
        set { _displayName = newValue }
    }

    /*!
     * \property KAboutData::productName
     */
    public var productName: String {
        get { _productName }
        set { _productName = newValue }
    }

    /*!
     * \property KAboutData::componentName
     */
    public var componentName: String {
        get { _componentName }
        set { _componentName = newValue }
    }

    /*!
     * \property KAboutData::programLogo
     */
    public var programLogo: Any {
        get { _programLogo }
        set { _programLogo = newValue }
    }
    // Q_PROPERTY(QVariant programLogo READ programLogo CONSTANT)

    /*!
     * \property KAboutData::shortDescription
     */
    public var shortDescription: String {
        get { _shortDescription }
        set { _shortDescription = newValue }
    }

    /*!
     * \property KAboutData::homepage
     */
    public var homepage: String {
        get { _homepage }
        set { _homepage = newValue }
    }

    /*!
     * \property KAboutData::bugAddress
     */
    public var bugAddress: String {
        get { _bugAddress }
        set { _bugAddress = newValue }
    }

    /*!
     * \property KAboutData::version
     */
    public var version: String {
        get { _version }
        set { _version = newValue }
    }

    /*!
     * \property KAboutData::otherText
     */
    public var otherText: String {
        get { _otherText }
        set { _otherText = newValue }
    }

    /*!
     * \property KAboutData::authors
     */
    public var authors: [KAboutPerson] {
        // constant in practice as addAuthor is not exposed to Q_GADGET
        get { _authors }
        set { _authors = newValue }
    }

    /*!
     * \property KAboutData::credits
     */
    public var credits: [KAboutPerson] {
        get { _credits }
        set { _credits = newValue }
    }

    /*!
     * \property KAboutData::translators
     */
    public var translators: [KAboutPerson] {
        get { _translators }
        set { _translators = newValue }
    }

    /*!
     * \property KAboutData::components
     */
    public var components: [KAboutComponent] {
        get { _components }
        set { _components = newValue }
    }

    /*!
     * \property KAboutData::licenses
     */
    public var licenses: [KAboutLicense] {
        get { _licenses }
        set { _licenses = newValue }
    }

    /*!
     * \property KAboutData::copyrightStatement
     */
    public var copyrightStatement: String {
        get { _copyrightStatement }
        set { _copyrightStatement = newValue }
    }

    /*!
     * \property KAboutData::desktopFileName
     */
    public var desktopFileName: String {
        get { _desktopFileName }
        set { _desktopFileName = newValue }
    }

    /*!
     * \property KAboutData::releases
     */
    public var releases: [KAboutRelease] {
        get { _releases }
        set { _releases = newValue }
    }

    /*!
     * \property KAboutData::organizationDomain
     */
    public var organizationDomain: String {
        get { _organizationDomain }
        set { _organizationDomain = newValue }
    }

// public:
    /*!
     * Returns the KAboutData for the application.
     *
     * This contains information such as authors, license, etc.,
     * provided that setApplicationData has been called before.
     * If not called before, the returned KAboutData will be initialized from the
     * equivalent properties of QCoreApplication (and its subclasses),
     * if an instance of that already exists.
     * For the list of such properties see setApplicationData
     * (before 5.22: limited to QCoreApplication::applicationName).
     * \sa setApplicationData
     */
    public static func applicationData() -> KAboutData {
        // QCoreApplication *app = QCoreApplication::instance();
        let app = KQCoreApplication.shared

        let s_registry = KAboutDataRegistry.shared
        var aboutData = s_registry.m_appData

        // not yet existing
        if aboutData == nil {
            // init from current Q*Application data
            aboutData = KAboutData(KQCoreApplication.applicationName, "", "")
            // Unset the default (KDE) bug address, this is likely a third-party app. https://bugs.kde.org/show_bug.cgi?id=473517
            aboutData?.bugAddress = ""
            // For applicationDisplayName & desktopFileName, which are only properties of QGuiApplication,
            // we have to try to get them via the property system, as the static getter methods are
            // part of QtGui only. Disadvantage: requires an app instance.
            // Either get all or none of the properties & warn about it
            if (true /* app != nil */) {
                let _ = aboutData?.setOrganizationDomain(KQCoreApplication.organizationDomain)
                aboutData?.version = KQCoreApplication.applicationVersion
                aboutData?.displayName = app.property("applicationDisplayName") as! String
                aboutData?.desktopFileName = app.property("desktopFileName") as! String
            } else {
                qCWarning(KABOUTDATA, "Could not initialize the properties of KAboutData::applicationData by the equivalent properties from Q*Application: no "
                                        + "app instance (yet) existing.")
            }

            s_registry.m_appData = aboutData
        } else {
            // check if in-sync with Q*Application metadata, as their setters could have been called
            // after the last KAboutData::setApplicationData, with different values
            warnIfOutOfSync("KAboutData::applicationData().componentName",
                            aboutData?.componentName ?? "error!",
                            "QCoreApplication::applicationName",
                            KQCoreApplication.applicationName)
            warnIfOutOfSync("KAboutData::applicationData().version",
                            aboutData?.version ?? "error!",
                            "QCoreApplication::applicationVersion",
                            KQCoreApplication.applicationVersion);
            warnIfOutOfSync("KAboutData::applicationData().organizationDomain",
                            aboutData?.organizationDomain ?? "error!",
                            "QCoreApplication::organizationDomain",
                            KQCoreApplication.organizationDomain);
            if (true /* app != nil */) {
                warnIfOutOfSync("KAboutData::applicationData().displayName",
                                aboutData!.displayName,
                                "QGuiApplication::applicationDisplayName",
                                app.property("applicationDisplayName") as! String)
                warnIfOutOfSync("KAboutData::applicationData().desktopFileName",
                                aboutData!.desktopFileName,
                                "QGuiApplication::desktopFileName",
                                app.property("desktopFileName") as! String)
            }
        }

        return aboutData!
    }

    /*!
     * Sets the application data for this application.
     *
     * In addition to changing the result of applicationData, this initializes
     * the equivalent properties of QCoreApplication (and its subclasses) with
     * information from \a aboutData, if an instance of that already exists.
     * Those properties are:
     *  \list
     *  \li QCoreApplication::applicationName
     *  \li QCoreApplication::applicationVersion
     *  \li QCoreApplication::organizationDomain
     *  \li QGuiApplication::applicationDisplayName
     *  \li QGuiApplication::desktopFileName (since 5.16)
     *  \endlist
     * \sa applicationData
     */
    public static func setApplicationData(_ aboutData: KAboutData) {
        let s_registry = KAboutDataRegistry.shared

        if s_registry.m_appData != nil {
            s_registry.m_appData = aboutData;
        } else {
            s_registry.m_appData = KAboutData(copy: aboutData)
        }

        // For applicationDisplayName & desktopFileName, which are only properties of QGuiApplication,
        // we have to try to set them via the property system, as the static getter methods are
        // part of QtGui only. Disadvantage: requires an app instance.
        // So set either all or none of the properties & warn about it
        let app = KQCoreApplication.shared
        if (true /* app != nil */) {
            type(of: app).applicationVersion = aboutData.version
            type(of: app).applicationName = aboutData.componentName
            type(of: app).organizationDomain = aboutData.organizationDomain
            app.setProperty("applicationDisplayName", aboutData.displayName);
            app.setProperty("desktopFileName", aboutData.desktopFileName);
        } else {
            qCWarning(KABOUTDATA,
                "Could not initialize the equivalent properties of Q*Application: no instance (yet) existing.")
        }

        // KF6: Rethink the current relation between KAboutData::applicationData and the Q*Application metadata
        // Always overwriting the Q*Application metadata here, but not updating back the KAboutData
        // in applicationData() is unbalanced and can result in out-of-sync data if the Q*Application
        // setters have been called meanwhile
        // Options are to remove the overlapping properties of KAboutData for cleancode, or making the
        // overlapping properties official shadow properties of their Q*Application countparts, though
        // that increases behavioural complexity a little.

        /* TODO: Implement signal/slot mechanism.
        if (KAboutDataListener.s_theListener != nil) {
            Q_EMIT KAboutDataListener::s_theListener->applicationDataChanged();
        }
        */
    }

    /*!
     * Create about data from an AppStream file.
     *
     * This fills all fields of the returned KAboutData object that can be
     * found in the the given AppStream file, including (translated) name,
     * license, URLs, etc. Note that most importantly the version number
     * is not included in this.
     *
     * \a appStreamFileName A path to the AppStream file to read.
     *
     * \sa fromAppStreamId, fromAppStreamForApplication
     * \since 6.26
     */
    public static func fromAppStreamFile(_ appStreamFileName: String) -> KAboutData {
        let s_registry = KAboutDataRegistry.shared
        if s_registry.m_appData == nil {
            s_registry.m_appData = KAboutData(KQCoreApplication.applicationName, "", "")
            s_registry.m_appData?.bugAddress = ""
        }
        let aboutData = s_registry.m_appData!

        let isEmpty = FileSystem.fileExists(atPath: appStreamFileName)
        let appStreamFile = FileSystem.File.open(appStreamFileName, "rb")
        if (isEmpty || false /* !appStreamFile.open(QFile::ReadOnly) */) {
            qCWarning(KABOUTDATA,
                "Failed to open appStreamFile") // + appStreamFile.fileName() + appStreamFile.errorString())
            return aboutData
        }

        // Make the XML as String.
        let data: Bytes = appStreamFile.readAll()
        let xmlSrc: String = data.decode(encoding: UTF8())!

        var appName: Dictionary<String, String> = [:]
        var appSummary: Dictionary<String, String> = [:]
        let reader = KQXMLStreamReader(xmlSrc)
        while (!reader.atEnd && !reader.hasError) {
            let token = reader.readNext()
            if (token != .startElement) {
                continue
            }

            if (reader.name == "component" || reader.name == "releases") {
                // recurse into
            } else if (reader.name == "id") {
                aboutData.desktopFileName = reader.readElementText()
            } else if (reader.name == "project_license") {
                let _ = aboutData.addLicense(KAboutLicense.byKeyword(reader.readElementText()))
            } else if (reader.name == "developer") {
                let _ = aboutData.setOrganizationDomain(reader.attributesValue("id"))
                // where to put developer-name?
                reader.skipCurrentElement()
            } else if (reader.name == "name") {
                let lang = reader.attributesValueNamespace(
                    "http://www.w3.org/XML/1998/namespace","lang")
                appName[lang] = reader.readElementText();
            } else if (reader.name == "summary") {
                let lang = reader.attributesValueNamespace(
                    "http://www.w3.org/XML/1998/namespace", "lang")
                appSummary[lang] = reader.readElementText();
            } else if (reader.name == "url") {
                let type = reader.attributesValue("type")
                if (type == "homepage") {
                    aboutData.homepage = reader.readElementText()
                } else if (type == "bugtracker") {
                    aboutData.bugAddress = reader.readElementText()
                } else {
                    reader.skipCurrentElement()
                }
            } else if (reader.name == "release") {
                let version = reader.attributesValue("version")
                // QDate::fromString(QStringView(reader.attributes().value("date")).left(10), Qt::ISODate);
                let date = KQDate() // TODO: DO NOT leave it empty.
                var desc = AppDataDesc()
                var url = KQURL()

                while (!reader.atEnd && !reader.hasError) {
                    let token = reader.readNext()
                    if (token == .endElement && reader.name == "release") {
                        break
                    }
                    if (token != .startElement) {
                        continue
                    }

                    if (reader.name == "url") {
                        url = KQURL(reader.readElementText())
                    } else if (reader.name == "description") {
                        desc = readAppStreamDescription(reader)
                    } else {
                        reader.skipCurrentElement()
                    }
                }

                if (!version.isEmpty && !desc.desc.isEmpty) {
                    let _ = aboutData.addRelease(KAboutRelease(
                        version, date, desc.desc, desc.rawDesc, url));
                }
            } else {
                reader.skipCurrentElement();
            }
        }

        aboutData.displayName = resolveLanguage(appName)
        aboutData.shortDescription = resolveLanguage(appSummary)
        return aboutData
    }

    /*!
     * Create about data from an AppStream file.
     *
     * This fills all fields of the returned KAboutData object that can be
     * found in the the given AppStream file, including (translated) name,
     * license, URLs, etc. Note that most importantly the version number
     * is not included in this.
     *
     * \a applicationId An application identifier used to find the corresponding
     *    AppStream file in the default install location.
     *
     * \sa fromAppStreamFile, fromAppStreamForApplication
     * \since 6.26
     */
    public static func fromAppStreamId(_ applicationId: String) -> KAboutData {
        /* Original C++
        for (const auto &variant : {"metainfo"_L1, "appdata"_L1}) {
            const auto p = QStandardPaths::locate(QStandardPaths::GenericDataLocation,
                                                "metainfo/"_L1 + applicationId + '.'_L1 + variant + ".xml"_L1,
                                                QStandardPaths::LocateFile);
            if (!p.isEmpty) {
                return KAboutData.fromAppStreamFile(p)
            }
        }
        */
        let p1 = QStandardPaths_locate(
            "metainfo/\(applicationId).\("metainfo").xml"
        )
        if !p1.isEmpty {
            return KAboutData.fromAppStreamFile(p1)
        }

        let p2 = QStandardPaths_locate(
            "metainfo/\(applicationId).\("appdata").xml"
        )
        if !p2.isEmpty {
            return KAboutData.fromAppStreamFile(p2)
        }

        return KAboutData()
    }

    /*!
     * Create about data from the AppStream file of the current application.
     *
     * This fills all fields of the returned KAboutData object that can be
     * found in the the given AppStream file, including (translated) name,
     * license, URLs, etc. Note that most importantly the version number
     * is not included in this.
     *
     * QGuiApplication::desktopFileName has to be set prior to calling this.
     *
     * \sa fromAppStreamFile, fromAppStreamId
     *
     * \since 6.26
     */
    public static func fromAppStreamForApplication() -> KAboutData {
        let desktopFileName = KQCoreApplication.shared.property("desktopFileName")
        return KAboutData.fromAppStreamId(desktopFileName as! String)
    }

// public:
    public init() {
        //
    }

    // KF6: remove constructor that includes catalogName, and put default
    //      values back in for shortDescription and licenseType
    /*!
     * Constructor.
     *
     * Porting Note: The \a catalogName parameter present in KDE4 was
     * deprecated and removed. See also K4AboutData
     * in kde4support if this feature is needed for compatibility purposes, or
     * consider using componentName() instead.
     *
     * \a componentName The program name or plugin name used internally.
     * Example: QStringLiteral("kwrite"). This should never be translated.
     *
     * \a displayName A displayable name for the program or plugin. This string
     *        should be translated. Example: i18n("KWrite")
     *
     * \a version The component version string. Example: QStringLiteral("1.0").
     *
     * \a shortDescription A short description of what the component does.
     *        This string should be translated.
     *        Example: i18n("A simple text editor.")
     *
     * \a licenseType The license identifier. Use setLicenseText or
     *        setLicenseTextFile if you use a license not predefined here.
     *
     * \a copyrightStatement A copyright statement, that can look like this:
     *        i18n("Copyright (C) 1999-2000 Name"). The string specified here is
     *        taken verbatim; the author information from addAuthor is not used.
     *
     * \a otherText Some free form text, that can contain any kind of
     *        information. The text can contain newlines. This string
     *        should be translated.
     *
     * \a homePageAddress The URL to the component's homepage, including
     *        URL scheme. "http://some.domain" is correct, "some.domain" is
     *        not. Since KDE Frameworks 5.17, https and other valid URL schemes
     *        are also valid. See also the note below.
     *
     * \a bugAddress The bug report address string, an email address or a URL.
     *        This defaults to the kde.org bug system.
     *
     * \note The \a homePageAddress argument is used to derive a default organization
     * domain for the application (which is used to register on the session D-Bus,
     * locate the appropriate desktop file, etc.), by taking the host name and dropping
     * the first component, unless there are less than three (e.g. "www.kde.org" -> "kde.org").
     * Use both setOrganizationDomain(const QByteArray&) and setDesktopFileName() if their default values
     * do not have proper values.
     *
     * \sa setOrganizationDomain(const QByteArray&), setDesktopFileName(const QString&)
     */
    /*
    public init(const QString &componentName,
               const QString &displayName,
               const QString &version,
               const QString &shortDescription,
               enum KAboutLicense::LicenseKey licenseType,
               const QString &copyrightStatement = QString(),
               const QString &otherText = QString(),
               const QString &homePageAddress = QString(),
               const QString &bugAddress = QStringLiteral("submit@bugs.kde.org"));
    */
    public init(
        _ componentName: String,
        _ displayName: String,
        _ version: String,
        _ licenseType: KAboutLicense.LicenseKey,
        _ copyrightStatement: String = "",
        _ otherText: String = "",
        _ homePageAddress: String = "",
        _ bugAddress: String = "submit@bugs.kde.org"
    ) {
        _componentName = componentName;
        let p = _componentName.firstIndex(of: "/")
        if let p = p {
            let mid = _componentName.index(after: p)
            _componentName = String(_componentName[mid...])
        }

        _displayName = displayName;
        if !_displayName.isEmpty { // KComponentData("klauncher") gives empty program name
            _internalProgramName = _displayName
        }
        _version = version
        _shortDescription = shortDescription; // !TODO!
        _licenses.append(KAboutLicense(licenseType, self))
        _copyrightStatement = copyrightStatement
        _otherText = otherText
        _homepage = homePageAddress
        _bugAddress = bugAddress

        /*
        QUrl homePageUrl(homePageAddress);
        if (!homePageUrl.isValid() || homePageUrl.scheme().isEmpty()) {
            // Default domain if nothing else is better
            homePageUrl.setUrl(QStringLiteral("https://kde.org/"));
        }
        */
        let homePageURL = KQURL(homePageAddress)
        if !homePageURL.isValid || homePageURL.scheme.isEmpty {
            homePageURL.setURL("https://kde.org/")
        }

        /*
        const QChar dotChar(QLatin1Char('.'));
        QStringList hostComponents = homePageUrl.host().split(dotChar);
        */
        var hostComponents = homePageURL.host().split(separator: ".")

        // Remove leading component unless 2 (or less) components are present
        if (hostComponents.count > 2) {
            let _ = hostComponents.dropFirst(1)
        }

        self.organizationDomain = hostComponents.joined(separator: ".");

        // KF6: do not set a default desktopFileName value here, but remove this code and leave it empty
        // see KAboutData::desktopFileName() for details

        // desktop file name is reverse domain name
        /*
        std::reverse(hostComponents.begin(), hostComponents.end());
        */
        hostComponents.reverse()
        hostComponents.append(String.SubSequence(_componentName));

        self.desktopFileName = hostComponents.joined(separator: ".")
    }

    /*!
     * Constructor.
     *
     * \a componentName The program name or plugin name used internally.
     * Example: "kwrite".
     *
     * \a displayName A displayable name for the program or plugin. This string
     *        should be translated. Example: i18n("KWrite")
     *
     * \a version The component version string.
     *
     * Sets the property desktopFileName to "org.kde."+componentName and
     * the property organizationDomain to "kde.org".
     *
     * Default arguments since 5.53
     *
     * \sa setOrganizationDomain(const QByteArray&), setDesktopFileName(const QString&)
     */
    public init(
        _ componentName: String = "",
        _ displayName: String = "",
        _ version: String = ""
    ) {
        _componentName = componentName
        /*
        int p = d->_componentName.indexOf(QLatin1Char('/'));
        if (p >= 0) {
            d->_componentName = d->_componentName.mid(p + 1);
        }
        */
        if let p = _componentName.firstIndex(of: "/") {
            let mid = _componentName.index(after: p)
            _componentName = String(_componentName[mid...])
        }

        _displayName = displayName
        if _displayName.isEmpty { // KComponentData("klauncher") gives empty program name
            _internalProgramName = _displayName
        }
        _version = version

        // match behaviour of other constructors
        _licenses.append(KAboutLicense(.unknown, self))
        _bugAddress = "submit@bugs.kde.org";
        _organizationDomain = "kde.org"
        // KF6: do not set a default desktopFileName value here, but remove this code and leave it empty
        // see KAboutData::desktopFileName() for details
        _desktopFileName = "org.kde.\(_componentName)"
    }

    /*!
     * Copy constructor.  Performs a deep copy.
     *
     * \a other object to copy
     */
    public init(copy: KAboutData) {
        _displayName = copy._displayName
        _productName = copy._productName
        _componentName = copy._componentName
        _programLogo = copy._programLogo
        _shortDescription = copy._shortDescription
        _homepage = copy._homepage
        _bugAddress = copy._bugAddress
        _version = copy._version
        _otherText = copy._otherText
        _authors = copy._authors
        _credits = copy._credits
        _translators = copy._translators
        _components = copy._components
        _licenses = copy._licenses
        _copyrightStatement = copy._copyrightStatement
        _desktopFileName = copy._desktopFileName
        _releases = copy._releases

        _customAuthorPlainText = copy._customAuthorPlainText
        _customAuthorRichText = copy._customAuthorRichText
        _customAuthorTextEnabled = copy._customAuthorTextEnabled
        _organizationDomain = copy._organizationDomain

        _internalProgramName = copy._internalProgramName
    }
    // KAboutData(const KAboutData &other);

    // KAboutData &operator=(const KAboutData &other);

    deinit { /* */ }

    /*!
     * Add an author.
     *
     * You can call this function as many times as you need. Each entry
     * is appended to a list.
     *
     * \a author the author.
     * \since 6.9
     */
    public func addAuthor(_ author: KAboutPerson) -> KAboutData {
        _authors.append(author)
        return self
    }

    /*!
     * Defines an author.
     *
     * You can call this function as many times as you need. Each entry is
     * appended to a list. The person in the first entry is assumed to be
     * the leader of the project.
     *
     * \a name The developer's name. It should be translated.
     *
     * \a task What the person is responsible for. This text can contain
     *             newlines. It should be translated.
     *             Can be left empty.
     *
     * \a emailAddress An Email address where the person can be reached.
     *                     Can be left empty.
     *
     * \a webAddress The person's homepage or a relevant link.
     *        Start the address with "http://". "http://some.domain" is
     *        correct, "some.domain" is not. Can be left empty.
     *
     * \a avatarUrl URL to the avatar of the person
     */
    /*
    KAboutData &addAuthor(const QString &name,
                          const QString &task = QString(),
                          const QString &emailAddress = QString(),
                          const QString &webAddress = QString(),
                          const QUrl &avatarUrl = QUrl());
    */
    public func addAuthor(
        _ name: String,
        _ task: String = "",
        _ emailAddress: String = "",
        _ webAddress: String = "",
        _ avatarURL: KQUrl = KQUrl()
    ) -> KAboutData {
        let person = KAboutPerson(name, task, emailAddress, webAddress, avatarURL)
        _authors.append(person)
        return self
    }

    /*!
     * \overload
     * \since 6.0
     */
    public func addAuthor(
        _ name: String,
        _ task: String,
        _ emailAddress: String,
        _ webAddress: String,
        _ kdeStoreUsername: String
    ) -> KAboutData {
        return addAuthor(name, task, emailAddress, webAddress,
            KQURL("https://store.kde.org/avatar/\(kdeStoreUsername)"))
    }
    /*
    KAboutData &addAuthor(const QString &name, const QString &task, const QString &emailAddress, const QString &webAddress, const QString &kdeStoreUsername)
    {
        return addAuthor(name, task, emailAddress, webAddress, QUrl(QStringLiteral("https://store.kde.org/avatar/") + kdeStoreUsername));
    }
    */

    /*!
     * Add a person that deserves credit.
     *
     * You can call this function as many times as you need. Each entry
     * is appended to a list.
     *
     * \a person The person.
     * \since 6.9
     */
    public func addCredit(_ person: KAboutPerson) -> KAboutData {
        _credits.append(person)
        return self
    }
    /*
    KAboutData &addCredit(const KAboutPerson &person);
    */

    /*!
     * Defines a person that deserves credit.
     *
     * You can call this function as many times as you need. Each entry
     * is appended to a list.
     *
     * \a name The person's name. It should be translated.
     *
     * \a task What the person has done to deserve the honor. The
     *        text can contain newlines. It should be translated.
     *        Can be left empty.
     *
     * \a emailAddress An email address when the person can be reached.
     *        Can be left empty.
     *
     * \a webAddress The person's homepage or a relevant link.
     *        Start the address with "http://". "http://some.domain" is
     *        is correct, "some.domain" is not. Can be left empty.
     *
     * \a avatarUrl URL to the avatar of the person
     */
    public func addCredit(
        _ name: String,
        _ task: String = "",
        _ emailAddress: String = "",
        _ webAddress: String = "",
        _ avatarUrl: KQURL = KQURL()
    ) -> KAboutData {
        _credits.append(KAboutPerson(name, task, emailAddress, webAddress, avatarUrl))
        return self
    }

    /*!
     * \overload
     * \since 6.0
     */
    public func addCredit(
        _ name: String,
        _ task: String,
        _ emailAddress: String,
        _ webAddress: String,
        _ kdeStoreUsername: String
    ) -> KAboutData {
        return addCredit(name, task, emailAddress, webAddress,
            KQUrl("https://store.kde.org/avatar/" + kdeStoreUsername))
    }

    /*!
     * \brief Sets the name(s) of the translator(s) of the GUI.
     *
     * The canonical use with the ki18n framework is:
     *
     * \code
     * setTranslator(i18nc("NAME OF TRANSLATORS", "Your names"),
     *               i18nc("EMAIL OF TRANSLATORS", "Your emails"));
     * \endcode
     *
     * If you are using a KMainWindow this is done for you automatically.
     *
     * The name and emailAddress are treated as lists separated with ",".
     *
     * If the strings are empty or "Your names"/"Your emails"
     * respectively they will be ignored.
     *
     * \a name the name(s) of the translator(s)
     *
     * \a emailAddress the email address(es) of the translator(s)
     */
    public func setTranslator(_ name: String, _ emailAddress: String) -> KAboutData {
        _translators = self.parseTranslators(name, emailAddress);
        return self
    }

    private func parseTranslators(
        _ translatorName: String,
        _ translatorEmail: String
    ) -> [KAboutPerson]
    {
        if (translatorName.isEmpty || translatorName == "Your names") {
            return []
        }

        // use list of string views to delay creating new QString instances after the white-space trimming
        // const QList<QStringView> nameList = QStringView(translatorName).split(QLatin1Char(','));
        let nameList: [String] = translatorName.split(separator: ",")
            .map(String.init)

        var emailList: [String] = []
        if (!translatorEmail.isEmpty && translatorEmail != "Your emails") {
            emailList = translatorEmail.split(separator: ",", omittingEmptySubsequences: false)
                .map(String.init)
        }

        var personList: [KAboutPerson] = []
        // personList.reserve(nameList.size());

        /* Original C++
        auto eit = emailList.constBegin();

        for (const QStringView &name : nameList) {
            QStringView email;
            if (eit != emailList.constEnd()) {
                email = *eit;
                ++eit;
            }

            personList.append(KAboutPerson(name.trimmed().toString(), email.trimmed().toString(), true));
        }
        */
        for (index, _) in nameList.enumerated() {
            let name = String(nameList[index].drop(while: \.isWhitespace)
                .reversed()
                .drop(while: \.isWhitespace)
                .reversed()
            )
            let email = String(emailList[index].drop(while: \.isWhitespace)
                .reversed()
                .drop(while: \.isWhitespace)
                .reversed()
            )
            personList.append(KAboutPerson(name, email, true))
        }

        return personList
    }

    /*!
     * Add a component that is used by the application.
     *
     * You can call this function as many times as you need. Each entry is
     * appended to a list.
     *
     * \a component The component
     *
     * \since 6.9
     */
    public func addComponent(_ component: KAboutComponent) -> KAboutData {
        _components.append(component)
        return self
    }

    /*!
     * Defines a component that is used by the application.
     *
     * You can call this function as many times as you need. Each entry is
     * appended to a list.
     *
     * \a name The component's name. It should be translated.
     *
     * \a description Short description of the component and maybe
     *        copyright info. This text can contain newlines. It should
     *        be translated. Can be left empty.
     *
     * \a version The version of the component. Can be left empty.
     *
     * \a webAddress The component's homepage or a relevant link.
     *        Start the address with "http://". "http://some.domain" is
     *        correct, "some.domain" is not. Can be left empty.
     *
     * \a licenseKey The component's license identifier. Can be left empty (i.e. KAboutLicense::Unknown)
     *
     * \since 5.84
     */
    public func addComponent(
        _ name: String,
        _ description: String = "",
        _ version: String = "",
        _ webAddress: String = "",
        _ licenseKey: KAboutLicense.LicenseKey = .unknown
    ) -> KAboutData {
        _components.append(KAboutComponent(name, description, version, webAddress, licenseKey))
        return self
    }

    /*!
     * Defines a component that is used by the application with a custom license text file.
     *
     * You can call this function as many times as you need. Each entry is
     * appended to a list.
     *
     * \a name The component's name. It should be translated.
     *
     * \a description Short description of the component and maybe
     *        copyright info. This text can contain newlines. It should
     *        be translated. Can be left empty.
     *
     * \a version The version of the component. Can be left empty.
     *
     * \a webAddress The component's homepage or a relevant link.
     *        Start the address with "http://". "http://some.domain" is
     *        correct, "some.domain" is not. Can be left empty.
     *
     * \a pathToLicenseFile Path to the file in the local filesystem containing the license text.
     *        The file format has to be plain text in an encoding compatible to the local.
     *
     * \since 5.84
     */
    public func addComponent(
        _ name: String,
        _ description: String,
        _ version: String,
        _ webAddress: String,
        _ pathToLicenseFile: String
    ) -> KAboutData {
        _components.append(
            KAboutComponent(name, description, version, webAddress, pathToLicenseFile)
        )
        return self
    }

    /*!
     * Defines a license text, which is translated.
     *
     * Example:
     * \code
     * setLicenseText( i18n("This is my license") );
     * \endcode
     *
     * \a license The license text.
     */
    public func setLicenseText(_ licenseText: String) -> KAboutData {
        _licenses[0] = KAboutLicense(self);
        _licenses[0].setLicenseFromText(licenseText);

        return self
    }

    /*!
     * Adds a license text, which is translated.
     *
     * If there is only one unknown license set, e.g. by using the default
     * parameter in the constructor, that one is replaced.
     *
     * Example:
     * \code
     * addLicenseText( i18n("This is my license") );
     * \endcode
     *
     * \a license The license text.
     * \sa setLicenseText, addLicense, addLicenseTextFile
     */
    public func addLicenseText(_ licenseText: String) -> KAboutData
    {
        // if the default license is unknown, overwrite instead of append
        let firstLicense = _licenses[0]
        let newLicense: KAboutLicense = KAboutLicense(self)
        newLicense.setLicenseFromText(licenseText);
        if (_licenses.count == 1 && firstLicense.key == .Unknown) {
            _licenses[0] = newLicense;
        } else {
            _licenses.append(newLicense);
        }

        return self
    }

    /*!
     * Defines a license text by pointing to a file where it resides.
     * The file format has to be plain text in an encoding compatible to the locale.
     *
     * \a file Path to the file in the local filesystem containing the license text.
     */
    public func setLicenseTextFile(_ pathToFile: String) -> KAboutData {
        _licenses[0] = KAboutLicense(self)
        _licenses[0].setLicenseFromPath(pathToFile);
        return self
    }

    /*!
     * Adds a license text by pointing to a file where it resides.
     * The file format has to be plain text in an encoding compatible to the locale.
     *
     * If there is only one unknown license set, e.g. by using the default
     * parameter in the constructor, that one is replaced.
     *
     * \a file path to the file in the local filesystem containing the license text.
     * \sa addLicenseText, addLicense, setLicenseTextFile
     */
    public func addLicenseTextFile(_ pathToFile: String) -> KAboutData
    {
        // if the default license is unknown, overwrite instead of append
        let firstLicense = _licenses[0]
        let newLicense = KAboutLicense(self)
        newLicense.setLicenseFromPath(pathToFile);
        if (_licenses.count == 1 && firstLicense.key == .Unknown) {
            _licenses[0] = newLicense;
        } else {
            _licenses.append(newLicense);
        }
        return self
    }

    /*!
     * Defines the component name used internally.
     *
     * \a componentName the application or plugin name. Example: "kate".
     */
    public func setComponentName(_ componentName: String) -> KAboutData {
        _componentName = componentName
        return self
    }

    /*!
     * Defines the displayable component name string.
     *
     * \a displayName the display name. This string should be
     *        translated.
     *        Example: i18n("Advanced Text Editor").
     */
    /*
    KAboutData &setDisplayName(const QString &displayName);
    */

    /*!
     * Defines the program logo.
     *
     * Use this if you need to have an application logo
     * in AboutData other than the application icon.
     *
     * Because KAboutData is a core class it cannot use QImage/QPixmap/QIcon directly,
     * so this is a QVariant that should contain a QImage/QPixmap/QIcon.
     *
     * QIcon should be preferred, to be able to properly handle HiDPI scaling.
     * If a QIcon is provided, it will be used at a typical size of 48x48.
     *
     * \a image logo image.
     * \sa programLogo()
     */
    /*
    KAboutData &setProgramLogo(const QVariant &image);
    */

    /*!
     * Defines the program version string.
     *
     * \a version the program version.
     */
    /*
    KAboutData &setVersion(const QByteArray &version);
    */

    /*!
     * Defines a short description of what the program does.
     *
     * \a shortDescription the program description. This string should
     *        be translated. Example: i18n("An advanced text
     *        editor with syntax highlighting support.").
     */
    public func setShortDescription(_ shortDescription: String) -> KAboutData {
        _shortDescription = shortDescription
        return self
    }

    /*!
     * Defines the license identifier.
     *
     * \a licenseKey the license identifier.
     * \sa addLicenseText, setLicenseText, setLicenseTextFile
     */
    public func setLicense(_ licenseKey: KAboutLicense.LicenseKey) -> KAboutData {
        return setLicense(licenseKey, .OnlyThisVersion);
    }

    /*!
     * Defines the license identifier.
     *
     * \a licenseKey the license identifier.
     *
     * \a versionRestriction Whether later versions of the license are also allowed.
     *    e.g. licensed under "GPL 2.0 or at your option later versions" would be OrLaterVersions.
     * \sa addLicenseText, setLicenseText, setLicenseTextFile
     *
     * \since 5.37
     */
    public func setLicense(
        _ licenseKey: KAboutLicense.LicenseKey,
        _ versionRestriction: KAboutLicense.VersionRestriction
    ) -> KAboutData {
        _licenses[0] = KAboutLicense(licenseKey, versionRestriction, self)
        return self
    }

    /*!
     * Sets the license.
     *
     * \a license a license object, obtained e.g. via KAboutLicense::byKeyword().
     * \sa addLicense, addLicenseText, setLicenseText, setLicenseTextFile
     *
     * \since 6.26
     */
    public func setLicense(_ license: KAboutLicense) -> KAboutData {
        _licenses[0] = license
        return self
    }

    /*!
     * Adds a license identifier.
     *
     * If there is only one unknown license set, e.g. by using the default
     * parameter in the constructor, that one is replaced.
     *
     * \a licenseKey the license identifier.
     * \sa setLicenseText, addLicenseText, addLicenseTextFile
     */
    public func addLicense(_ licenseKey: KAboutLicense.LicenseKey) -> KAboutData {
        return addLicense(licenseKey, .onlyThisVersion);
    }

    /*!
     * Adds a license identifier.
     *
     * If there is only one unknown license set, e.g. by using the default
     * parameter in the constructor, that one is replaced.
     *
     * \a licenseKey the license identifier.
     *
     * \a versionRestriction Whether later versions of the license are also allowed.
     *    e.g. licensed under "GPL 2.0 or at your option later versions" would be OrLaterVersions.
     *
     * \sa setLicenseText, addLicenseText, addLicenseTextFile
     *
     * \since 5.37
     */
    public func addLicense(
        _ licenseKey: KAboutLicense.LicenseKey,
        _ versionRestriction: KAboutLicense.VersionRestriction
    ) -> KAboutData {
        // if the default license is unknown, overwrite instead of append
        let firstLicense = _licenses[0];
        if (_licenses.count == 1 && firstLicense.key == .Unknown) {
            _licenses[0] /*firstLicense*/ = KAboutLicense(licenseKey, versionRestriction, self)
        } else {
            _licenses.append(KAboutLicense(licenseKey, versionRestriction, self))
        }
        return self
    }

    /*!
     * Adds a license.
     *
     * \a license a license object, obtained e.g. via KAboutLicense::byKeyword().
     * \sa addLicenseText, setLicense, setLicenseText, setLicenseTextFile
     *
     * \since 6.26
     */
    public func addLicense(_ license: KAboutLicense) -> KAboutData {
        if (_licenses.count == 1 && _licenses[0].key == .Unknown) {
            return setLicense(license);
        }
        _licenses.append(license)
        return self
    }

    /*!
     * Defines the copyright statement to show when displaying the license.
     *
     * \a copyrightStatement a copyright statement, that can look like
     *        this: i18n("Copyright (C) 1999-2000 Name"). The string specified here is
     *        taken verbatim; the author information from addAuthor is not used.
     */
    /*
    KAboutData &setCopyrightStatement(const QString &copyrightStatement);
    */

    /*!
     * Defines the additional text to show in the about dialog.
     *
     * \a otherText some free form text, that can contain any kind of
     *        information. The text can contain newlines. This string
     *        should be translated.
     */
    // KAboutData &setOtherText(const QString &otherText);

    /*!
     * Defines the program homepage.
     *
     * \a homepage the program homepage string.
     *        Start the address with "http://". "http://kate.kde.org"
     *        is correct but "kate.kde.org" is not.
     */
    // KAboutData &setHomepage(const QString &homepage);

    /*!
     * Defines the address where bug reports should be sent.
     *
     * \a bugAddress The bug report email address or URL.
     *        This defaults to the kde.org bug system.
     */
    // KAboutData &setBugAddress(const QByteArray &bugAddress);

    /*!
     * Defines the domain of the organization that wrote this application.
     * The domain is set to kde.org by default, or the domain of the homePageAddress constructor argument,
     * if set.
     *
     * Make sure to call setOrganizationDomain(const QByteArray&) if your product
     * is not developed inside the KDE community.
     *
     * Used e.g. for the registration to D-Bus done by KDBusService
     * from the KDE Frameworks KDBusAddons module.
     *
     * Calling this method has no effect on the value of the desktopFileName property.
     *
     * \note If your program should work as a D-Bus activatable service, the base name
     * of the D-Bus service description file or of the desktop file you install must match
     * the D-Bus "well-known name" for which the program will register.
     * For example, KDBusService will use a name created from the reversed organization domain
     * with the component name attached, so for an organization domain "bar.org" and a
     * component name "foo" the name of an installed D-Bus service file needs to be
     * "org.bar.foo.service" or the name of the installed desktop file "org.bar.foo.desktop"
     * (and the desktopFileName property accordingly set to "org.bar.foo").
     *
     * \a domain the domain name, for instance kde.org, koffice.org, etc.
     *
     * \sa setDesktopFileName(const QString&)
     */
    public func setOrganizationDomain(_ domain: String) -> KAboutData {
        _organizationDomain = domain
        return self
    }

    /*!
     * Defines the product name which will be used in the KBugReport dialog.
     * By default it's the componentName, but you can overwrite it here to provide
     * support for special components e.g. in the form 'product/component',
     * such as 'kontact/summary'.
     *
     * \a name the name of product
     */
    public func setProductName(_ name: String) -> KAboutData {
        _productName = name
        return self
    }


    /*!
     * \internal
     * Provided for use by KCrash
     */
    internal func internalProductName() -> UnsafeMutablePointer<CChar>? {
        nil
        // return productName.isEmpty ? nil : productName.constData()
    }

    /*!
     * \internal
     * Provided for use by KCrash
     */
    internal func internalBugAddress() -> UnsafeMutablePointer<CChar>? {
        if _bugAddress.isEmpty {
            return nil;
        }
        return nil
        // return _bugAddress
    }

    /*!
     * Returns a message about the translation team.
     */
    public static func aboutTranslationTeam() -> String {
        return KQCoreApplication.translate(
            "KAboutData",
            "<p>KDE is translated into many languages thanks to the work "
                + "of the translation teams all over the world.</p>"
                + "<p>For more information on KDE internationalization "
                + "visit <a href=\"https://l10n.kde.org\">https://l10n.kde.org</a></p>",
            "replace this with information about your translation team"
        )
    }

    /*!
     * Returns a list of components.
     * \since 5.84
     */
    // QList<KAboutComponent> components() const;

    /*!
     * Returns a translated, free form text.
     */
    // QString otherText() const;

    /*!
     * Returns a list of licenses.
     */
    // QList<KAboutLicense> licenses() const;

    /*!
     * Returns the plain text displayed around the list of authors instead
     * of the default message telling users to send bug reports to bugAddress().
     */
    public func customAuthorPlainText() -> String {
        _customAuthorPlainText
    }

    /*!
     * Returns the rich text displayed around the list of authors instead
     * of the default message telling users to send bug reports to bugAddress().
     */
    public func customAuthorRichText() -> String {
        _customAuthorRichText
    }

    /*!
     * Returns whether custom text should be displayed around the list of
     * authors.
     */
    public func customAuthorTextEnabled() -> Bool {
        _customAuthorTextEnabled
    }

    /*!
     * Sets the custom text displayed around the list of authors instead
     * of the default message telling users to send bug reports to bugAddress().
     *
     * \a plainText the plain text.
     *
     * \a richText the rich text.
     *
     * Setting both to parameters to QString() will cause no message to be
     * displayed at all.  Call unsetCustomAuthorText() to revert to the default
     * message.
     */
    public func setCustomAuthorText(_ plainText: String, _ richText: String) -> KAboutData {
        _customAuthorPlainText = plainText
        _customAuthorRichText = richText

        _customAuthorTextEnabled = true

        return self
    }

    /*!
     * Clears any custom text displayed around the list of authors and falls
     * back to the default message telling users to send bug reports to
     * bugAddress().
     */
    public func unsetCustomAuthorText() -> KAboutData {
        _customAuthorPlainText = ""
        _customAuthorRichText = ""

        _customAuthorTextEnabled = false

        return self
    }

    /*!
     * Configures the \a parser command line parser to provide an authors entry with
     * information about the developers of the application and an entry specifying the license.
     *
     * Additionally, it will set the description to the command line parser, will add the help
     * option and if the QApplication has a version set (e.g. via KAboutData::setApplicationData)
     * it will also add the version option.
     *
     * Since 5.16 it also adds an option to set the desktop file name.
     *
     * Returns true if adding the options was successful; otherwise returns false.
     *
     * \sa processCommandLine
     */
    public func setupCommandLine(/* QCommandLineParser *parser */) -> Bool {
        // TODO: Low priority since this method not used in this module.
        false
    }

    /*!
     * Reads the processed \a parser and sees if any of the arguments are the ones set
     * up from setupCommandLine().
     *
     * \sa setupCommandLine()
     */
    public func processCommandLine(/* QCommandLineParser *parser */) {
        // TODO: Low priority since this method not used in this module.
    }

    /*!
     * Sets the base name of the desktop entry for this application.
     *
     * This is the file name, without the full path and without extension,
     * of the desktop entry that represents this application according to
     * the freedesktop desktop entry specification (e.g. "org.kde.foo").
     *
     * A default desktop file name is constructed when the KAboutData
     * object is created, using the reverse domain name of the
     * organizationDomain and the componentName as they are at the time
     * of the KAboutData object creation.
     * Call this method to override that default name. Typically this is
     * done when also setOrganizationDomain or setComponentName
     * need to be called to override the initial values.
     *
     * The desktop file name can also be passed to the application at runtime through
     * the \c desktopfile command line option which is added by setupCommandLine.
     * This is useful if an application supports multiple desktop files with different runtime
     * settings.
     *
     * \a desktopFileName the desktop file name of this application
     *
     * \sa desktopFileName()
     * \sa organizationDomain()
     * \sa componentName()
     * \sa setupCommandLine()
     * \since 5.16
     **/
    // KAboutData &setDesktopFileName(const QString &desktopFileName);

    /*!
     * Adds a release note for this application.
     * \sa releases()
     * \since 6.26
     */
    public func addRelease(_ release: KAboutRelease) -> KAboutData {
        _releases.append(release);
        return self
    }
    /*!
     * Returns all release notes for this application.
     * \sa addRelease()
     * \since 6.26
     */
    /*
    [[nodiscard]] QList<KAboutRelease> releases() const;
    */

// private:
    /*
    friend void KCrash::defaultCrashHandler(int sig);
    // exported for KCrash, no other users intended
    static const KAboutData *applicationDataPointer();
    */
}

class KAboutDataRegistry {
    nonisolated(unsafe) private static var _instance: KAboutDataRegistry = KAboutDataRegistry()

    public var m_appData: KAboutData? = nil

    public static var shared: KAboutDataRegistry {
        _instance
    }

    internal init() {
    }

    deinit {
        // delete m_appData;
    }
    /*
    KAboutDataRegistry(const KAboutDataRegistry &) = delete;
    KAboutDataRegistry &operator=(const KAboutDataRegistry &) = delete;
    */
}

public class KAboutDataListener {
    nonisolated(unsafe) private static var _instance: KAboutDataListener = KAboutDataListener()

    public static var instance: KAboutDataListener {
        _instance
    }

    private init() {
    }

// Q_SIGNALS:
    /*!
     * Notifies that KAboutData::setApplicationData was called.
     **/
    /*
    void applicationDataChanged();
    */

    public static var s_theListener: KAboutDataListener {
        self.instance
    }
}
