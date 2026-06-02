public class KAboutComponent {
    private var _name: String
    private var _description: String
    private var _version: String
    private var _webAddress: String
    private var _license: KAboutLicense

    public var description: String {
        _description
    }
    public var license: KAboutLicense {
        get { _license }
    }
    public var name: String {
        _name
    }
    public var version: String {
        _version
    }
    public var webAddress: String {
        _webAddress
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
