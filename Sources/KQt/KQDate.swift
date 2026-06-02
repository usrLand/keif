internal import Qt

public class KQDate {
    private var _qDate: UnsafeMutableRawPointer? = nil

    public init() {
        _qDate = KQDate_new()
    }

    deinit {
        KQDate_free(_qDate)
    }
}
