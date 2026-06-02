#ifndef KREST_QT_H
#define KREST_QT_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

//==============
// QString
//==============

typedef void KQString;

KQString* KQString_new(const char *str);

const char* KQString_to_c_str(const KQString *string);

void KQString_free(KQString *string);

//====================
// QCoreApplication
//====================

void* KQCoreApplication_instance();

const char* KQCoreApplication_translate(void *qCoreApplication,
                                        const char *context,
                                        const char *srcText,
                                        const char *disambiguation,
                                        int n);

//========
// QUrl
//========

void* KQUrl_new(const char *url);

KQString* KQUrl_host(void *url);

KQString* KQUrl_scheme(const void *url);

void KQUrl_set_host(const void *url, const char *host);

void KQUrl_set_url(const void *url, const char *value);

bool KQUrl_is_valid(const void *url);

void KQUrl_free(void *url);

//============
// QJson
//============

void* KQJsonObject_new();

void* KQJsonObject_subscript(const void *jsonObject, const char *key);

void KQJsonObject_free(void *json);


void* KQJsonValue_new_from_string(const char *string);

void KQJsonValue_to_string(const void *jsonValue,
                           char *buffer,
                           int size);

void KQJsonValue_to_string_with_default(const void *jsonValue,
                                        const char *defaultValue,
                                        char *buffer,
                                        int size);

void KQJsonValue_free(void *value);

//===========
// Date
//===========

void* KQDate_new();

void KQDate_free(void *date);

//===============
// XML Reader
//===============

void* KQXmlStreamReader_new(const char *src);

bool KQXmlStreamReader_at_end(const void *reader);

bool KQXmlStreamReader_has_error(const void *reader);

int KQXmlStreamReader_read_next(const void *reader);

KQString* KQXmlStreamReader_name(const void *reader);

KQString* KQXmlStreamReader_text(const void *reader);

void KQXmlStreamReader_skip_current_element(void *reader);

KQString* KQXmlStreamReader_attributes_value_ns(const void *reader,
                                                const char *namespaceURI,
                                                const char *name);

KQString* KQXmlStreamReader_attributes_value(const void *reader,
                                             const char *qualifiedName);

KQString* KQXmlStreamReader_read_element_text(const void *reader);

bool KQXmlStreamReader_is_whitespace(const void *reader);

void KQXmlStreamReader_free(void *reader);

//==================
// Inline Helpers
//==================

KQString* KQStandardPaths_locate(const char *v);

#ifdef __cplusplus
}
#endif

#endif /* KREST_QT_H */
