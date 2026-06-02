#include "Qt.h"

#include <string.h>

#include <QUrl>
#include <QDate>
#include <QXmlStreamReader>

#ifdef __cplusplus
extern "C" {
#endif

KQString* KQString_new(const char *str)
{
    return new QString(str);
}

const char* KQString_to_c_str(const KQString *string)
{
    return ((QString*)string)->c_str();
}

void KQString_free(KQString *string)
{
    delete string;
}

void* KQCoreApplication_instance()
{
    return QCoreApplication::instance();
}

const char* KQCoreApplication_translate(void *CoreApplication,
                                        const char *context,
                                        const char *srcText,
                                        const char *disambiguation,
                                        int n)
{
    auto res = qCoreApplication->translate(context, srcText, disambiguation, n);
    return res.c_str();
}


void* KQUrl_new(const char *url)
{
    void *k_url = new QUrl(url);

    return k_url;
}

KQString* KQUrl_host(void *url)
{
    QString *host = new QString(((QUrl*)url)->host());
    return host;
}

KQString* KQUrl_scheme(const void *url)
{
    const QUrl *qURL = (const QUrl*)url;
    QString *scheme = new QString(qURL->scheme());

    return scheme;
}

void KQUrl_set_host(const void *url, const char *host)
{
    const QUrl *qURL = (const QUrl*)url;

    qURL->setHost(host);
}

void KQUrl_set_url(const void *url, const char *value)
{
    const QUrl *qURL = (const QUrl*)url;

    qURL->setUrl(value);
}

bool KQUrl_is_valid(const void *url)
{
    const QUrl *qURL = (const QUrl*)url;

    return qURL->isValid();
}

void KQUrl_free(void *url)
{
    delete url;
}


void* KQDate_new()
{
    void *date = new QDate;

    return date;
}

void KQDate_free(void *date)
{
    delete date;
}


void* KQJsonObject_new()
{
    void *qjo = new QJsonObject();

    return qjo;
}

void* KQJsonObject_subscript(const void *jsonObject, const char *key)
{
    QJsonObject *obj = (QJsonObject*)jsonObject;

    QJsonValue *val = new QJsonObject(obj[QStringView(key)]);
    if (val->isUndefined()) {
        return nullptr;
    }
    return val;
}

void KQJsonObject_free(void *json)
{
    delete json
}

void* KQJsonValue_new_from_string(const char *string)
{
    void *qjv = new QJsonValue(string);

    return qjv;
}

void KQJsonValue_to_string(const void *jsonValue,
                           char *buffer,
                           int size)
{
    const QJsonValue &v = *jsonValue;

    auto str = v.toString();
    const char *c_str = str.c_str();
    strncpy(buffer, c_str, size);
}

void KQJsonValue_to_string_with_default(const void *jsonValue,
                                        const char *defaultValue,
                                        char *buffer,
                                        int size)
{
    const QJsonValue *v = jsonValue;

    auto str = v->toString(defaultValue);
    const char *c_str = str.c_str();
    strncpy(buffer, c_str, size);
}

void KQJsonValue_free(void *value)
{
    delete value;
}


void* KQXmlStreamReader_new(const char *src)
{
    QAnyStringView s = QAnyStringView(src);
    QXmlStreamReader *reader = new QXmlStreamReader(s);

    return reader;
}

bool KQXmlStreamReader_at_end(const void *reader)
{
    QXmlStreamReader *qReader = (QXmlStreamReader*)reader;

    return qReader->atEnd();
}

bool KQXmlStreamReader_has_error(const void *reader)
{
    QXmlStreamReader *qReader = (QXmlStreamReader*)reader;

    return qReader->hasError();
}

int KQXmlStreamReader_read_next(const void *reader)
{
    QXmlStreamReader *qReader = (QXmlStreamReader*)reader;

    return qReader->readNext();
}

KQString* KQXmlStreamReader_name(const void *reader)
{
    QXmlStreamReader *qReader = (QXmlStreamReader*)reader;

    QString *qStr = new QString(qReader->name());

    return qStr;
}

KQString* KQXmlStreamReader_text(const void *reader)
{
    QXmlStreamReader *qReader = (QXmlStreamReader*)reader;

    QString *qStr = new QString(qReader->text());

    return qStr;
}

void KQXmlStreamReader_skip_current_element(void *reader)
{
    QXmlStreamReader *qReader = (QXmlStreamReader*)reader;

    reader->skipCurrentElement();
}

KQString* KQXmlStreamReader_attributes_value_ns(const void *reader,
                                                const char *namespaceURI,
                                                const char *name)
{
    const QXmlStreamReader *qReader = (const QXmlStreamReader*)reader;

    auto val = qReader->attributes().value(namespaceURI, name);
    QString *qStr = new QString(val);

    return qStr;
}

KQString* KQXmlStreamReader_attributes_value(const void *reader,
                                             const char *qualifiedName)
{
    const QXmlStreamReader *qReader = (const QXmlStreamReader*)reader;

    auto val = qReader->attributes().value(qualifiedName);
    QString *qStr = new QString(val);

    return qStr;
}

KQString* KQXmlStreamReader_read_element_text(const void *reader)
{
    const QXmlStreamReader *qReader = (const QXmlStreamReader*)reader;

    auto val = qReader->readElementText();
    QString *qStr = new QString(val);

    return qStr;
}

bool KQXmlStreamReader_is_whitespace(const void *reader)
{
    const QXmlStreamReader *qReader = (const QXmlStreamReader*)reader;

    return qReader->isWhitespace();
}

void KQXmlStreamReader_free(void *reader)
{
    delete reader;
}

//==================
// Inline Helpers
//==================

KQString* KQStandardPaths_locate(const char *v)
{
    QString qString = QStandardPaths::locate(QStandardPaths::GenericDataLocation,
        "metainfo/"_L1 + applicationId + '.'_L1 + variant + ".xml"_L1,
        QStandardPaths::LocateFile);

    QString *ret = new QString(qString);

    return ret;
}

#ifdef __cplusplus
}
#endif
