internal import Qt

public func QStandardPaths_locate(_ v: String) -> String {
    let qStr = KQStandardPaths_locate(v)

    let ret = String(cString: KQString_to_c_str(qStr))
    KQString_free(qStr)

    return ret
}

public enum KQStandardPaths {
    public enum StandardLocation: Int {
        case desktopLocation = 0
        case documentsLocation = 1
        case fontsLocation = 2
        case applicationsLocation = 3
        case musicLocation = 4
        case moviesLocation = 5
        case picturesLocation = 6
        case tempLocation = 7
        case homeLocation = 8
        case appLocalDataLocation = 9
        case cacheLocation = 10
        case genericCacheLocation = 15
        case genericDataLocation = 11
        case runtimeLocation = 12
        case configLocation = 13
        case downloadLocation = 14
        case genericConfigLocation = 16
        case appDataLocation = 17
        case appConfigLocation = 18
        case publicShareLocation = 19
        case templatesLocation = 20
        case stateLocation = 21
        case genericStateLocation = 22
    }
}
