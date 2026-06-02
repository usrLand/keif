internal import Qt

public class KQCoreApplication {
    nonisolated(unsafe) static var _instance = KQCoreApplication()

    private var _properties: Dictionary<String, Any> = [:]

    public static var shared: KQCoreApplication {
        return _instance
    }

    public static var applicationName: String {
        get { "TODO: Implementation" }
        set { }
    }

    public static var applicationVersion: String {
        get { "0.0.0-TODO" }
        set { }
    }

    public static var organizationDomain: String {
        get { "TODO.org" }
        set { }
    }

    public static func translate(
        _ context: String,
        _ srcText: String,
        _ disambiguation: String = "",
        _ n: Int32 = -1
    ) -> String {
        let rawApp = KQCoreApplication_instance()

        let c_str = KQCoreApplication_translate(rawApp, context, srcText, disambiguation, n);

        return String(cString: c_str!)
    }

    public func property(_ key: String) -> Any {
        return _properties[key]
    }

    public func setProperty(_ key: String, _ value: Any) {
        _properties[key] = value
    }
}
