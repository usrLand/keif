import KQt
import Blusher

public class KAboutLicense {
    public enum LicenseKey: Int {
        case Custom = -2
        case File = -1
        case Unknown = 0
        case GPL = 1
        public static var GPL_V2: Self { .GPL }
        case LGPL = 2
        public static var LGPL_V2: Self { .LGPL }
        case BSD_2_Clause = 3
        case Artistic = 4
        case GPL_V3 = 5
        case LGPL_V3 = 6
        case LGPL_V2_1 = 7
        case MIT = 8
        case ODbL_V1 = 9
        case Apache_V2 = 10
        case FTL = 11
        case BSL_V1 = 12
        case BSD_3_Clause = 13
        case CC0_V1 = 14
        case MPL_V2 = 15

        @available(*, deprecated, renamed: "BSD_2_Clause")
        public static var BSDL: Int { 3 }

        public static var custom: Self { .Custom }
        public static var file: Self { .File }
        public static var unknown: Self { .Unknown }
        public static var gpl: Self { .GPL }
        public static var gplV2: Self { GPL }
        public static var lgpl: Self { .LGPL }
        public static var lgplV2: Self { .LGPL }
        // public static var bsdl: Int { BSDL }
        public static var bsd2clause: Self { .BSD_2_Clause }
        public static var artistic: Self { .Artistic }
        public static var gplV3: Self { .GPL_V3 }
        public static var lgplV3: Self { .LGPL_V3 }
        public static var lgplV2_1: Self { .LGPL_V2_1 }
        public static var mit: Self { .MIT }
        public static var odblV1: Self { .ODbL_V1 }
        public static var apacheV2: Self { .Apache_V2 }
        public static var ftl: Self { .FTL }
        public static var bslV1: Self { .BSL_V1 }
        public static var bsd_3_clause: Self { .BSD_3_Clause }
        public static var cc0V1: Self { .CC0_V1 }
        public static var mplV2: Self { .MPL_V2 }
    }

    public enum NameFormat: Int {
        case shortName
        case fullName

        public static var ShortName: Self { .shortName }
        public static var FullName: Self { .fullName }
    }

    public enum VersionRestriction: Int {
        case onlyThisVersion
        case orLaterVersions

        public static var OnlyThisVersion: Self { .onlyThisVersion }
        public static var OrLaterVersions: Self { .orLaterVersions }
    }

    private var _licenseKey: LicenseKey = .unknown
    private var _licenseText: String = ""
    private var _pathToLicenseTextFile: String = ""
    private var _versionRestriction: VersionRestriction = .init(rawValue: 0)!
    private var _aboutData: KAboutData? = nil

    public var key: LicenseKey {
        .unknown  // TODO: MUST IMPLEMENT
    }
    public func name(_ format: NameFormat) -> String {
        return ""   // TODO: MUST IMPLEMENT
    }
    public var spdx: String {
        // SPDX licenses are comprised of an identifier (e.g. GPL-2.0), an optional + to denote 'or
        // later versions' and optional ' WITH $exception' to denote standardized exceptions from the
        // core license. As we do not offer exceptions we effectively only return GPL-2.0 or GPL-2.0+,
        // this may change in the future. To that end the documentation makes no assertions about the
        // actual content of the SPDX license expression we return.
        // Expressions can in theory also contain AND, OR and () to build constructs involving more than
        // one license. As this is outside the scope of a single license object we'll ignore this here
        // for now.
        // The expectation is that the return value is only run through spec-compliant parsers, so this
        // can potentially be changed.

        let id = self.spdxID()
        // QString can be null while Swift String can't be.
        /*
        if id == nil {
            return id
        }
        */
        return _versionRestriction == .orLaterVersions ? "\(id)+" : id
    }

    public var text: String {
        var result = ""

        let lineFeed = "\n\n"

        // TODO: !MUST IMPLEMENT!
        /*
        if (_aboutData && !d->_aboutData->copyrightStatement().isEmpty()
            && (d->_licenseKey == KAboutLicense::BSD_2_Clause || d->_licenseKey == KAboutLicense::BSD_3_Clause || d->_licenseKey == KAboutLicense::MIT
                || d->_licenseKey == KAboutLicense::Artistic)) {
            result = d->_aboutData->copyrightStatement() + lineFeed;
        }
        */

        var knownLicense = false
        var pathToFile = "" // rel path if known license
        switch (_licenseKey) {
        case .File:
            pathToFile = _pathToLicenseTextFile
        case .GPL_V2:
            knownLicense = true;
            pathToFile = ("GPL_V2");
            break;
        case .LGPL_V2:
            knownLicense = true;
            pathToFile = ("LGPL_V2");
            break;
        case .BSD_2_Clause:
            knownLicense = true;
            pathToFile = ("BSD");
            break;
        case .Artistic:
            knownLicense = true;
            pathToFile = ("ARTISTIC");
            break;
        case .GPL_V3:
            knownLicense = true;
            pathToFile = ("GPL_V3");
            break;
        case .LGPL_V3:
            knownLicense = true;
            pathToFile = ("LGPL_V3");
            break;
        case .LGPL_V2_1:
            knownLicense = true;
            pathToFile = ("LGPL_V21");
            break;
        case .MIT:
            knownLicense = true;
            pathToFile = ("MIT");
            break;
        case .ODbL_V1, .Apache_V2, .FTL, .BSL_V1, .BSD_3_Clause, .CC0_V1, .MPL_V2:
            var result1 = KQCoreApplication.translate(
                "KAboutLicense",
                "<p>This program is distributed under the terms of the %1.</p>"
            )
            var result2 = KQCoreApplication.translate(
                "KAboutLicense",
                "<p>You can find the full terms on <a href=\"https://spdx.org/licenses/%1.html\">the SPDX website</a>.</p>"
            )

            result1 = result1.replacing("%1", with: self.name(.shortName))
            result2 = result2.replacing("%1", with: self.spdxID())

            result += result1 + result2
        case .Custom:
            if (_licenseText.isEmpty) {
                result = _licenseText;
                break;
            }
            fallthrough
        default:
            result += KQCoreApplication.translate(
                "KAboutLicense",
                "No licensing terms for this program have been specified.\n"
                    + "Please check the documentation or the source for any\n"
                    + "licensing terms.\n"
            )
        }

        if (knownLicense) {
            pathToFile = ":/org.kde.kcoreaddons/licenses/" + pathToFile;
            let resultTr = KQCoreApplication.translate(
                "KAboutLicense",
                "This program is distributed under the terms of the %1."
            )
            var resultSwift = resultTr
            resultSwift = resultSwift.replacing("%1", with: self.name(.shortName))
            result += resultSwift
            if (!pathToFile.isEmpty) {
                result += lineFeed;
            }
        }

        if (!pathToFile.isEmpty) {
            /*
            QFile file(pathToFile);
            if (file.open(QIODevice::ReadOnly)) {
                QTextStream str(&file);
                result += str.readAll();
            }
            */
            let file = FileSystem.File.open(pathToFile, "rb")
            result += file.readAll().decode(encoding: UTF8()) ?? ""
            file.close()
        }

        return result;
    }

    //===============
    // Private Init
    //===============

    private func _init(
        _ licenseType: LicenseKey,
        _ versionRestriction: VersionRestriction,
        _ aboutData: KAboutData?
    ) {
        _licenseKey = licenseType
        _versionRestriction = versionRestriction
        _aboutData = aboutData
    }

    /*
    private init(const KAboutLicensePrivate &other)
        : QSharedData(other)
        , _licenseKey(other._licenseKey)
        , _licenseText(other._licenseText)
        , _pathToLicenseTextFile(other._pathToLicenseTextFile)
        , _versionRestriction(other._versionRestriction)
        , _aboutData(other._aboutData)
    {
    }
    */

    //===============
    // Public Init
    //===============

    public init() {
        _init(.unknown, VersionRestriction.init(rawValue: 0)!, nil)
    }

    public init(
        _ licenseType: LicenseKey,
        _ versionRestriction: VersionRestriction,
        _ aboutData: KAboutData?)
    {
        _init(licenseType, versionRestriction, aboutData)
    }

    public init(_ licenseType: LicenseKey, _ aboutData: KAboutData?)
    {
        _init(licenseType, .OnlyThisVersion, aboutData)
    }

    public init(_ aboutData: KAboutData?)
    {
        _init(.unknown, .OnlyThisVersion, aboutData)
    }


    public static func byKeyword(_ keyword: String) -> KAboutLicense {
        // TODO: Implementation
        return KAboutLicense()
    }

    //==================
    // Private Method
    //==================
    private func spdxID() -> String {
        switch (_licenseKey) {
        case .GPL_V2:
            return ("GPL-2.0")
        case .LGPL_V2:
            return ("LGPL-2.0")
        case .BSD_2_Clause:
            return ("BSD-2-Clause")
        case .BSD_3_Clause:
            return ("BSD-3-Clause")
        case .Artistic:
            return ("Artistic-1.0")
        case .GPL_V3:
            return ("GPL-3.0")
        case .LGPL_V3:
            return ("LGPL-3.0")
        case .LGPL_V2_1:
            return ("LGPL-2.1")
        case .MIT:
            return ("MIT")
        case .ODbL_V1:
            return ("ODbL-1.0")
        case .Apache_V2:
            return ("Apache-2.0")
        case .FTL:
            return ("FTL")
        case .BSL_V1:
            return ("BSL-1.0")
        case .CC0_V1:
            return ("CC0-1.0")
        case .MPL_V2:
            return ("MPL-2.0")
        case .Custom:
            return ""
        case .File:
            return ""
        case .Unknown:
            return ""
        default:
            return ""
        }
    }

    internal func setLicenseFromPath(_ pathToFile: String)
    {
        _licenseKey = .File;
        _pathToLicenseTextFile = pathToFile;
    }

    internal func setLicenseFromText(_ licenseText: String)
    {
        _licenseKey = .Custom;
        _licenseText = licenseText;
    }
}
