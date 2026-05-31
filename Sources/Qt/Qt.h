#ifndef KREST_QT_H
#define KREST_QT_H

#include <QCoreApplication>

#ifdef __cplusplus
extern "C" {
#endif

typedef QCoreApplication* KQCoreApplication;

KQCoreApplication KQCoreApplication_instance();

const char* KQCoreApplication_translate(KQCoreApplication qCoreApplication,
                                        const char *context,
                                        const char *srcText,
                                        const char *disambiguation,
                                        int n);

#ifdef __cplusplus
}
#endif

#endif /* KREST_QT_H */
