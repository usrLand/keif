internal import Qt

public class KQUrl {
    private var _ptr: UnsafeMutableRawPointer

    public var isValid: Bool {
        KQUrl_is_valid(_ptr)
    }

    public var scheme: String {
        get {
            let qString = KQUrl_scheme(_ptr)
            let scheme = String(cString: KQString_to_c_str(qString))
            KQString_free(qString)

            return scheme
        }
    }

    public init() {
        _ptr = KQUrl_new("")
    }

    public init(_ url: String) {
        _ptr = KQUrl_new(url)
    }

    deinit {
        KQUrl_free(_ptr)
    }

    public func host() -> String {
        let h = KQUrl_host(_ptr)
        let ret = String(cString: KQString_to_c_str(h))

        KQString_free(h)

        return ret
    }

    public func setHost(_ host: String) {
        let h = KQString_new(host)
        KQUrl_set_host(_ptr, h)

        KQString_free(h)
    }

    public func setURL(_ url: String) {
        KQUrl_set_url(_ptr, url);
    }
}

public typealias KQURL = KQUrl
