internal import Qt

public class KQJsonValue {
    private var _ptr: UnsafeMutableRawPointer!

    internal init(fromRawPointer rawPointer: UnsafeMutableRawPointer) {
        _ptr = rawPointer
    }

    public init(_ string: String) {
        _ptr = KQJsonValue_new_from_string(string)
    }

    // public init(_ int: Int) {
    // }

    deinit {
        KQJsonValue_free(_ptr)
    }

    public func toString() -> String {
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
        KQJsonValue_to_string(_ptr, buffer, 1024)
        let str = String(cString: buffer)
        buffer.deallocate()

        return str
    }

    public func toString(_ defaultValue: String) -> String {
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
        KQJsonValue_to_string_with_default(_ptr, defaultValue,
            buffer, 1024)
        let str = String(cString: buffer)
        buffer.deallocate()

        return str
    }
}

public class KQJsonObject {
    private var _ptr: UnsafeMutableRawPointer!

    public init() {
        _ptr = KQJsonObject_new()
    }

    deinit {
        KQJsonObject_free(_ptr)
    }

    public subscript(key: String) -> KQJSONValue? {
        let v = KQJsonObject_subscript(_ptr, key)

        return (v != nil) ? KQJsonValue(fromRawPointer: v!) : nil
    }
}

public typealias KQJSONValue = KQJsonValue
public typealias KQJSONObject = KQJsonObject
