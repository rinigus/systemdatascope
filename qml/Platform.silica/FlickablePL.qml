import QtQuick 2.2
import Sailfish.Silica 1.0

SilicaFlickable {

    PullDownMenu {
        MenuItem {
            text: "About"
            onClicked: { appWindow.appAbout() }
        }

        MenuItem {
            text: "Help"
            onClicked: { appWindow.appHelp() }
        }

        MenuItem {
            text: "Status"
            onClicked: { appWindow.appStatus() }
        }

        MenuItem {
            text: "Settings"
            onClicked: { appWindow.appSettings() }
        }

        MenuItem {
            text: "Time"
            onClicked: {
                appWindow.pushPage(Qt.resolvedUrl("TimeControlPL.qml"))
            }
        }
    }

}
