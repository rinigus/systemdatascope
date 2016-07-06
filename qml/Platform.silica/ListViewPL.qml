import QtQuick 2.2
import Sailfish.Silica 1.0

SilicaListView {
    property string header_text: ""

    header: Column {
        width: parent.width
        height: header.height + Theme.paddingLarge    // add space between button and first list item

        PageHeader {
            id: header
            title: header_text
        }
    }

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
            onClicked: { appWindow.pushPage(Qt.resolvedUrl("StatusPL.qml")) }
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

    VerticalScrollDecorator {}
}
