import KQt

public class KAboutRelease {
    private var _version: String
    private var _date: KQDate
    private var _description: String
    private var _untranslatedDescription: String
    private var _url: KQURL

    /*!
     * \property KAboutRelease::version
     */
    public var version: String { _version }
    /*!
     * \property KAboutRelease::date
     */
    public var date: KQDate { _date }
    /*!
     * \property KAboutRelease::description
     */
    public var description: String { _description }
    /*!
     * \property KAboutRelease::url
     */
    public var url: KQURL { _url }

    public var untranslatedDescription: String { _untranslatedDescription }

// public:
    public init() {
        _version = ""
        _date = KQDate()
        _description = ""
        _untranslatedDescription = ""
        _url = KQURL()
    }

    internal init(
        _ version: String,
        _ date: KQDate,
        _ description: String,
        _ untranslatedDescription: String,
        _ url: KQURL
    ) {
        _version = version
        _date = date
        _description = description
        _untranslatedDescription = untranslatedDescription
        _url = url
    }

    deinit {}

    /*!
     * Retursn the version this release note refers to.
     */
    // [[nodiscard]] QString version() const;
    /*!
     * Returns the date on which this version was released.
     */
    // [[nodiscard]] QDate date() const;
    /*!
     * Returns the (translated) release notes.
     *
     * This is provided as restricted rich text, following what the description tag
     * in AppStream allows. This is suitable for consumption by Qt rich text labels.
     */
    // [[nodiscard]] QString description() const;
    /*!
     * Returns the untranslated release notes.
     *
     * This is not meant for displaying to users, but for detecting changes
     * since the last display, when display release notes on development versions.
     *
     * \see description
     */
    // [[nodiscard]] QString untranslatedDescription() const;

    /*!
     * Returns a URL to a website with more information about the release.
     */
    // [[nodiscard]] QUrl url() const;
}
