/****************************************************************************
** Meta object code from reading C++ file 'imageExtractor.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../imageExtractor.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'imageExtractor.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_ImageExtract_t {
    QByteArrayData data[22];
    char stringdata0[293];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_ImageExtract_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_ImageExtract_t qt_meta_stringdata_ImageExtract = {
    {
QT_MOC_LITERAL(0, 0, 12), // "ImageExtract"
QT_MOC_LITERAL(1, 13, 20), // "coverImageUrlChanged"
QT_MOC_LITERAL(2, 34, 0), // ""
QT_MOC_LITERAL(3, 35, 17), // "extractionStarted"
QT_MOC_LITERAL(4, 53, 8), // "filePath"
QT_MOC_LITERAL(5, 62, 18), // "extractionFinished"
QT_MOC_LITERAL(6, 81, 8), // "imageUrl"
QT_MOC_LITERAL(7, 90, 16), // "extractionFailed"
QT_MOC_LITERAL(8, 107, 6), // "reason"
QT_MOC_LITERAL(9, 114, 17), // "onProcessFinished"
QT_MOC_LITERAL(10, 132, 8), // "exitCode"
QT_MOC_LITERAL(11, 141, 20), // "QProcess::ExitStatus"
QT_MOC_LITERAL(12, 162, 6), // "status"
QT_MOC_LITERAL(13, 169, 14), // "onProcessError"
QT_MOC_LITERAL(14, 184, 22), // "QProcess::ProcessError"
QT_MOC_LITERAL(15, 207, 5), // "error"
QT_MOC_LITERAL(16, 213, 19), // "setExtractorCommand"
QT_MOC_LITERAL(17, 233, 7), // "program"
QT_MOC_LITERAL(18, 241, 11), // "defaultArgs"
QT_MOC_LITERAL(19, 253, 19), // "requestCoverForFile"
QT_MOC_LITERAL(20, 273, 5), // "clear"
QT_MOC_LITERAL(21, 279, 13) // "coverImageUrl"

    },
    "ImageExtract\0coverImageUrlChanged\0\0"
    "extractionStarted\0filePath\0"
    "extractionFinished\0imageUrl\0"
    "extractionFailed\0reason\0onProcessFinished\0"
    "exitCode\0QProcess::ExitStatus\0status\0"
    "onProcessError\0QProcess::ProcessError\0"
    "error\0setExtractorCommand\0program\0"
    "defaultArgs\0requestCoverForFile\0clear\0"
    "coverImageUrl"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_ImageExtract[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      10,   14, // methods
       1,   98, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       4,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   64,    2, 0x06 /* Public */,
       3,    1,   65,    2, 0x06 /* Public */,
       5,    2,   68,    2, 0x06 /* Public */,
       7,    2,   73,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       9,    2,   78,    2, 0x08 /* Private */,
      13,    1,   83,    2, 0x08 /* Private */,

 // methods: name, argc, parameters, tag, flags
      16,    2,   86,    2, 0x02 /* Public */,
      16,    1,   91,    2, 0x22 /* Public | MethodCloned */,
      19,    1,   94,    2, 0x02 /* Public */,
      20,    0,   97,    2, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,
    QMetaType::Void, QMetaType::QString, QMetaType::QUrl,    4,    6,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    4,    8,

 // slots: parameters
    QMetaType::Void, QMetaType::Int, 0x80000000 | 11,   10,   12,
    QMetaType::Void, 0x80000000 | 14,   15,

 // methods: parameters
    QMetaType::Void, QMetaType::QString, QMetaType::QStringList,   17,   18,
    QMetaType::Void, QMetaType::QString,   17,
    QMetaType::Void, QMetaType::QString,    4,
    QMetaType::Void,

 // properties: name, type, flags
      21, QMetaType::QUrl, 0x00495001,

 // properties: notify_signal_id
       0,

       0        // eod
};

void ImageExtract::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<ImageExtract *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->coverImageUrlChanged(); break;
        case 1: _t->extractionStarted((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 2: _t->extractionFinished((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QUrl(*)>(_a[2]))); break;
        case 3: _t->extractionFailed((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 4: _t->onProcessFinished((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< QProcess::ExitStatus(*)>(_a[2]))); break;
        case 5: _t->onProcessError((*reinterpret_cast< QProcess::ProcessError(*)>(_a[1]))); break;
        case 6: _t->setExtractorCommand((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QStringList(*)>(_a[2]))); break;
        case 7: _t->setExtractorCommand((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 8: _t->requestCoverForFile((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 9: _t->clear(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (ImageExtract::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ImageExtract::coverImageUrlChanged)) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (ImageExtract::*)(const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ImageExtract::extractionStarted)) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (ImageExtract::*)(const QString & , const QUrl & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ImageExtract::extractionFinished)) {
                *result = 2;
                return;
            }
        }
        {
            using _t = void (ImageExtract::*)(const QString & , const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&ImageExtract::extractionFailed)) {
                *result = 3;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<ImageExtract *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QUrl*>(_v) = _t->coverImageUrl(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject ImageExtract::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ImageExtract.data,
    qt_meta_data_ImageExtract,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *ImageExtract::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ImageExtract::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ImageExtract.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ImageExtract::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 10;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 1;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void ImageExtract::coverImageUrlChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void ImageExtract::extractionStarted(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void ImageExtract::extractionFinished(const QString & _t1, const QUrl & _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void ImageExtract::extractionFailed(const QString & _t1, const QString & _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
