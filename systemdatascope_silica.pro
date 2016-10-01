# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = systemdatascope

CONFIG += sailfishapp sailfishapp_no_deploy_qml
CONFIG += c++11

qml.files = qml/*.qml qml/Platform qml/Platform.silica
qml.path = /usr/share/$${TARGET}/qml
INSTALLS += qml

confscript.files = tools/systemdatascope-makeconfig
confscript.path = /usr/bin
INSTALLS += confscript

CONFIG(release, debug|release):DEFINES += QT_NO_DEBUG_OUTPUT

DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += IS_SAILFISH_OS

SOURCES += \
    src/commandqueue.cpp \
    src/graphgenerator.cpp \
    src/imagefile.cpp \
    src/main.cpp \
    src/systemdserviceswitchcmd.cpp \
    src/configurator.cpp

OTHER_FILES += \
    rpm/systemdatascope.spec \
    rpm/systemdatascope.yaml \
    translations/*.ts \
    systemdatascope.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
# TRANSLATIONS += translations/systemdatascope-de.ts

HEADERS += \
    src/commandqueue.h \
    src/graphgenerator.h \
    src/imagefile.h \
    src/systemdserviceswitchcmd.h \
    src/configurator.h

DISTFILES += \
    qml/AppAbout.qml \
    qml/AppSettings.qml \
    qml/GraphList.qml \
    qml/main.qml \
    qml/Platform/ApplicationWindowPL.qml \
    qml/Platform/BusyIndicatorPL.qml \
    qml/Platform/FlickablePL.qml \
    qml/Platform/ListViewPL.qml \
    qml/Platform/MessageDialogPL.qml \
    qml/Platform/PagePL.qml \
    qml/Platform/SettingsPL.qml \
    qml/Platform/SettingsStoragePL.qml \
    qml/Platform/MessageAboutPL.qml \
    qml/Platform/TimeControlPL.qml \
    qml/Platform/StatusPL.qml \
    qml/Platform/IndicatorPL.qml \
    qml/Platform/TextPL.qml \
    qml/HelpText.qml \
    qml/AppHelp.qml \
    qml/Platform/MessageErrorPL.qml \
    qml/AppStatus.qml \
    rpm/systemdatascope.changes \
    qml/Platform/MessagePL.qml

