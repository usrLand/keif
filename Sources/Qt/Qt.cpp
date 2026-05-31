#include "Qt.h"

#ifdef __cplusplus
extern "C" {
#endif

KQCoreApplication KQCoreApplication_instance()
{
    return QCoreApplication::instance();
}

const char* KQCoreApplication_translate(KQCoreApplication qCoreApplication,
                                        const char *context,
                                        const char *srcText,
                                        const char *disambiguation,
                                        int n)
{
    auto res = qCoreApplication->translate(context, srcText, disambiguation, n);
    return res.c_str();
}

#ifdef __cplusplus
}
#endif
