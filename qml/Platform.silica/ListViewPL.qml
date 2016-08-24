import QtQuick 2.2
import Sailfish.Silica 1.0

SilicaListView {
    property string header_text: ""
    property int pl_margin_bottom: Theme.paddingLarge
    property int pl_space_between_items_small: Theme.paddingSmall

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

    PushUpMenu {
        MenuItem {
            text: "Time"
            onClicked: {
                appWindow.pushPage(Qt.resolvedUrl("TimeControlPL.qml"))
            }
        }
    }


    VerticalScrollDecorator {}
}
