internal import Qt

public func QStandardPaths_locate(_ v: String) -> String {
    let qStr = KQStandardPaths_locate(v)

    let ret = String(cString: KQString_to_c_str(qStr))
    KQString_free(qStr)

    return ret
}
