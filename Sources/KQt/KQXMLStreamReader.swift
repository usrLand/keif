internal import Qt

public class KQXMLStreamReader {
    public enum TokenType: Int {
        case noToken = 0
        case invalid = 1
        case startElement = 4
        case endElement = 5
        case characters = 6
    }

    private var _ptr: UnsafeMutableRawPointer!

    public var atEnd: Bool {
        KQXmlStreamReader_at_end(_ptr)
    }

    public var hasError: Bool {
        KQXmlStreamReader_has_error(_ptr)
    }

    public var name: String {
        let qStr = KQXmlStreamReader_name(_ptr)
        let ret = String(cString: KQString_to_c_str(qStr))
        KQString_free(qStr)

        return ret
    }

    public var text: String {
        let qStr = KQXmlStreamReader_text(_ptr);
        let ret = String(cString: KQString_to_c_str(qStr))
        KQString_free(qStr)

        return ret
    }

    public var isWhitespace: Bool {
        KQXmlStreamReader_is_whitespace(_ptr)
    }

    public init(_ src: String) {
        _ptr = KQXmlStreamReader_new(src)
    }

    deinit {
        KQXmlStreamReader_free(_ptr)
    }

    public func readNext() -> TokenType {
        let type = KQXmlStreamReader_read_next(_ptr)

        return TokenType(rawValue: Int(type))!
    }

    public func skipCurrentElement() {
        KQXmlStreamReader_skip_current_element(_ptr)
    }

    public func attributesValueNamespace(_ namespaceURI: String, _ name: String) -> String {
        let qStr = KQXmlStreamReader_attributes_value_ns(_ptr, namespaceURI, name)

        let ret = String(cString: KQString_to_c_str(qStr))
        KQString_free(qStr)

        return ret
    }

    public func attributesValue(_ qualifiedName: String) -> String {
        let qStr = KQXmlStreamReader_attributes_value(_ptr, qualifiedName)

        let ret = String(cString: KQString_to_c_str(qStr))
        KQString_free(qStr)

        return ret
    }

    public func readElementText() -> String {
        let qStr = KQXmlStreamReader_read_element_text(_ptr)

        let ret = String(cString: KQString_to_c_str(qStr))
        KQString_free(qStr)

        return ret
    }
}
