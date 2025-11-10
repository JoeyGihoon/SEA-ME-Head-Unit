#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtWebEngine/QtWebEngine>
#include <QtNetwork/QSslSocket>

#include "mapController.h"
#include "weather.h"
#include "youtubeController.h"
#include "usbscanner.h"
#include "imageExtractor.h"


int main(int argc, char *argv[])
{
    qputenv("QTWEBENGINE_DISABLE_SANDBOX", "1");
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", "--no-sandbox --disable-gpu --disable-gpu-compositing");

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    MapController mapController;
    engine.rootContext()->setContextProperty("mapController", &mapController);

    Weather weather;
    engine.rootContext()->setContextProperty("weather", &weather);

    YoutubeController YoutubeController;
    engine.rootContext()->setContextProperty("youtubeController", &YoutubeController);

    UsbScanner usbScanner;
    engine.rootContext()->setContextProperty("usbScanner", &usbScanner);

    ImageExtract imageExtractor;
    engine.rootContext()->setContextProperty("imageExtract", &imageExtractor);

    usbScanner.rescanMountedUsb();
    imageExtractor.setExtractorCommand("python3", {"/usr/bin/extract_cover.py", "--in", "%IN%", "--out", "%OUT%"});

    const QUrl url(QStringLiteral("qrc:/qml/pages/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl) QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
