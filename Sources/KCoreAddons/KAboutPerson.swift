import KQt

public class KAboutPerson
{
    public var _name: String
    public var _task: String
    public var _emailAddress: String
    public var _webAddress: String
    public var _avatarUrl: KQUrl

    /*!
     * \property KAboutPerson::name
     */
    public var name: String { _name }

    /*!
     * \property KAboutPerson::task
     */
    public var task: String { _task }

    /*!
     * \property KAboutPerson::emailAddress
     */
    public var emailAddress: String { _emailAddress }

    /*!
     * \property KAboutPerson::webAddress
     */
    public var webAddress: String { _webAddress }

    /*!
     * \property KAboutPerson::avatarUrl
     */
    public var avatarUrl: KQUrl { _avatarUrl }
    public var avatarURL: KQURL { _avatarUrl }
    // friend class KAboutData;

// public:
    /*!
     * Convenience constructor
     *
     * \a name The name of the person.
     *
     * \a task The task of this person.
     *
     * \a emailAddress The email address of the person.
     *
     * \a webAddress Home page of the person.
     *
     * \a avatarUrl URL to the avatar of the person, since 6.0
     *
     * \a name default argument, since 5.53
     */
    public init(
        _ name: String,
        _ task: String,
        _ emailAddress: String,
        _ webAddress: String,
        _ avatarUrl: KQUrl
    ) {
        _name = name
        _task = task
        _emailAddress = emailAddress
        _webAddress = webAddress
        _avatarUrl = avatarUrl
    }

    /*!
     * \internal Used by KAboutData to construct translator data.
     */
    internal init(_ name: String, _ email: String, _ disambiguation: Bool) {
        _name = name
        _task = ""
        _emailAddress = email
        _webAddress = ""
        _avatarUrl = KQURL("")
    }

    /*!
     * Copy constructor.  Performs a deep copy.
     *
     * \a other object to copy
     */
    // KAboutPerson(const KAboutPerson &other);

    deinit {}

    /*!
     * Assignment operator.  Performs a deep copy.
     *
     * \a other object to copy
     */
    // KAboutPerson &operator=(const KAboutPerson &other);


    /*!
     * Returns an URL pointing to the user's avatar
     * \since 6.0
     */
    // QUrl avatarUrl() const;

    /*!
      Creates a \c KAboutPerson from a JSON object with the following structure:

     \table
        \header
            \li Key
            \li Accessor
        \row
            \li Name
            \li name()
        \row
            \li EMail
            \li emailAddress()
        \row
            \li Task
            \li task()
        \row
            \li Website
            \li webAddress()
        \row
            \li AvatarUrl
            \li avatarUrl()
        \endtable

      The \c Name and \c Task key are translatable (by using e.g. a "Task[de_DE]" key)
      The AvatarUrl exists since version 6.0

      \since 5.18
     */
    public static func fromJSON(_ obj: KQJsonObject) -> KAboutPerson
    {
        print("KAboutPerson::fromJSON is not implemented yet!")
        /*
        let name: String = KJsonUtils::readTranslatedString(obj, QStringLiteral("Name"));
        let task: String = KJsonUtils::readTranslatedString(obj, QStringLiteral("Task"));
        let email: String = obj.value(QLatin1String("Email")).toString();
        let website: String = obj.value(QLatin1String("Website")).toString();
        let avatarUrl: KQURL = obj.value(QLatin1String("AvatarUrl")).toVariant().toUrl();
        return KAboutPerson(name, task, email, website, avatarUrl)
        */
        return KAboutPerson("", "", "", "", KQURL(""))
    }
}
