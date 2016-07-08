TEMPLATE = app

TARGET = systemdatascope

QT += qml quick widgets

CONFIG += c++11

DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += IS_QTQUICK

SOURCES += \ 
    src/commandqueue.cpp \
    src/graphgenerator.cpp \
    src/imagefile.cpp \
    src/main.cpp \
    src/systemdserviceswitchcmd.cpp \
    src/configurator.cpp

RESOURCES += qml_qtcontrols.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment_qtcontrols.pri)

HEADERS += \
    src/commandqueue.h \
    src/graphgenerator.h \
    src/imagefile.h \
    src/systemdserviceswitchcmd.h \
    src/configurator.h
