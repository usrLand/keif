import KQt

internal func getDefaultLocaleName() -> String {
    // TODO: Use QLocale.
    return "en_US"
}

public enum KJsonUtils {

public static func readTranslatedValue(
    _ jo: KQJsonObject,
    _ key: String,
    _ defaultValue: KQJsonValue
) -> KQJsonValue {
    let languageWithCountry = getDefaultLocaleName()
    let found = jo["\(key)[\(languageWithCountry)]"]
    /*
    auto it = jo.constFind(key + QLatin1Char('[') + languageWithCountry + QLatin1Char(']'));
    if (it != jo.constEnd()) {
        return it.value();
    }
    */
    if found != nil {
        return found!
    }

    // const QStringView language = QStringView(languageWithCountry)
    //     .mid(0, languageWithCountry.indexOf(QLatin1Char('_')));
    let language = languageWithCountry.prefix(while: { $0 != "_" })
    if let found = jo["\(key)[\(language)]"] {
        return found
    }
    /*
    it = jo.constFind(key + QLatin1Char('[') + language + QLatin1Char(']'));
    if (it != jo.constEnd()) {
        return it.value();
    }
    */
    // no translated value found -> check key
    /*
    it = jo.constFind(key);
    if (it != jo.constEnd()) {
        return jo.value(key);
    }
    */
    if let found = jo[key] {
        return found
    }
    return defaultValue;
}

public static func readTranslatedString(
    _ jo: KQJSONObject,
    _ key: String,
    _ defaultValue: String
) -> String {
    return KJsonUtils.readTranslatedValue(jo, key, KQJSONValue(defaultValue))
        .toString(defaultValue);
}

} // enum KJsonUtils
