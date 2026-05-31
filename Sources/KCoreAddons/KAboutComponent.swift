public class KAboutComponent {
    private var _name: String
    private var _description: String
    private var _version: String
    private var _webAddress: String
    private var _license: KAboutLicense

    public var description: String {
        get { "" }
    }
    public var license: KAboutLicense {
        get { _license }
    }
    public var name: String {
        get { "" }
    }
    public var version: String {
        get { "" }
    }
    public var webAddress: String {
        get { "" }
    }

    public init(
        _ name: String,
        _ description: String,
        _ version: String,
        _ webAddress: String,
        _ pathToLicenseFile: String
    ) {
        _name = name
        _description = description
        _version = version
        _webAddress = webAddress
        _license = KAboutLicense() // TODO: MUST FIX!
    }

    public init(
        _ name: String,
        _ description: String,
        _ version: String,
        _ webAddress: String,
        _ licenseType: KAboutLicense.LicenseKey = .Unknown
    ) {
        _name = name
        _description = description
        _version = version
        _webAddress = webAddress
        _license = KAboutLicense(licenseType, nil)
    }
}
