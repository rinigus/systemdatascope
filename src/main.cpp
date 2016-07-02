/*
  Copyright (C) 2016 rinigus <rinigus.git@gmail.com>
  License: MIT
*/

//#ifdef QT_QML_DEBUG
#include <QtQuick>
//#endif

#include "graphgenerator.h"
#include "systemdserviceswitchcmd.h"

#ifdef IS_SAILFISH_OS

// Sailfish
#include <sailfishapp.h>

#else
// Desktop

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QtQml>

#endif

int main(int argc, char *argv[])
{

#ifdef IS_SAILFISH_OS

    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> v(SailfishApp::createView());
    QQmlContext *rootContext = v->rootContext();

#else

    QGuiApplication app(argc, argv);
    app.setOrganizationName("SystemDataScope");
    app.setOrganizationDomain("gui.for.collectd.org");
    app.setApplicationName("SystemDataScope");

    QQmlApplicationEngine engine;
    QQmlContext *rootContext = engine.rootContext();

#endif

    Graph::Generator grapher;
    SystemDServiceSwitchCmd service( "collectd.service" );

#ifndef IS_SAILFISH_OS
    service.startAutoUpdates(60);
#endif

    rootContext->setContextProperty("grapher", &grapher);
    rootContext->setContextProperty("service", &service);

    rootContext->setContextProperty("programName", "SystemDataScope");
    rootContext->setContextProperty("programVersion", APP_VERSION);

    // Start the application.
#ifdef IS_SAILFISH_OS

    v->setSource(SailfishApp::pathTo("qml/main.qml"));
    v->show();
    return app->exec();

#else
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
#endif
}

