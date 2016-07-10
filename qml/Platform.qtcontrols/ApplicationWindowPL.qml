import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0

ApplicationWindow {

    id: appWindowBase

    property bool stateRRDRunning: false
    property string stateLoadingUrl: ""
    property string stateLastRRDError: ""
    property var extraVariables: { }

    signal appZoomIn()
    signal appZoomOut()
    signal appTimeToNow()
    signal appTimeToHistory()
    signal appTimeToFuture()
    signal appTimespan(real timespan)
    signal appSettings()
    signal appAbout()
    signal appHelp()
    signal appStatus()

    //////////////////////////////////////////////////////
    // special properties required by this platform

    // list of "pages" that are actually dialogs
    property var dialogFileNames: [ "AppAbout.qml", "AppSettings.qml", "MessageErrorPL.qml" ]

    // dummy properties/signals to ensure compatibility with Sailfish
    signal applicationActiveChanged()

    function setCover()
    {
    }


    toolBar: ToolBar {
        RowLayout {
            id: appToolbar

            ToolButton {
                text: qsTr("Zoom In")
                onClicked: { appWindowBase.appZoomIn() }
            }

            ToolButton {
                text: qsTr("Zoom Out")
                onClicked: { appWindowBase.appZoomOut() }
            }

            ToolButton {
                text: qsTr("Now")
                onClicked: { appWindowBase.appTimeToNow() }
            }

            ToolButton {
                text: qsTr("<---")
                onClicked: { appWindowBase.appTimeToHistory() }
            }

            ToolButton {
                text: qsTr("--->")
                onClicked: { appWindowBase.appTimeToFuture() }
            }

            ToolButton {
                text: qsTr("1 hour")
                onClicked: { appWindowBase.appTimespan(60*60) }
            }

            ToolButton {
                text: qsTr("4 hours")
                onClicked: { appWindowBase.appTimespan(4*60*60) }
            }

            ToolButton {
                text: qsTr("8 hours")
                onClicked: { appWindowBase.appTimespan(8*60*60) }
            }

            ToolButton {
                text: qsTr("12 hours")
                onClicked: { appWindowBase.appTimespan(12*60*60) }
            }

            ToolButton {
                text: qsTr("24 hours")
                onClicked: { appWindowBase.appTimespan(24*60*60) }
            }

            ToolButton {
                text: qsTr("3 days")
                onClicked: { appWindowBase.appTimespan(3*24*60*60) }
            }

            ToolButton {
                text: qsTr("1 week")
                onClicked: { appWindowBase.appTimespan(7*24*60*60) }
            }

            ToolButton {
                text: qsTr("4 weeks")
                onClicked: { appWindowBase.appTimespan(4*7*24*60*60) }
            }

            ToolButton {
                text: qsTr("100 days")
                onClicked: { appWindowBase.appTimespan(100*24*60*60) }
            }

            // separator
            Item {
                width: 8
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 6
                Rectangle {
                    width: 1
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#22000000"
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    anchors.horizontalCenterOffset: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#33ffffff"
                }
            }

            ToolButton {
                text: qsTr("Settings")
                onClicked: { appWindowBase.appSettings() }
            }

            ToolButton {
                text: qsTr("Status")
                onClicked: { appWindowBase.appStatus() }
            }

            ToolButton {
                text: qsTr("Help")
                onClicked: { appWindowBase.appHelp() }
            }

            ToolButton {
                text: qsTr("About")
                onClicked: { appWindowBase.appAbout() }
            }

        }
    }

    statusBar: StatusBar {
        RowLayout{
            spacing: 4
            Label { id: guiCollectDStat; text: "" }
            Item  {}
            Label { text: qsTr("RRDTool running: " + stateRRDRunning) }
            Label { text: "|" }
            Label { text: stateLoadingUrl }
            Label { text: "|" }
            Label { text: stateLastRRDError }
        }
    }

    StackView {
        anchors.fill : parent
        id : pageStack

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                if (mouse.button == Qt.RightButton)
                {
                    appWindow.popPage()
                }
            }
        }
    }

    function isActive() {
        return true //Qt.application.state can be used, but on desktop let's update always
    }

    function pushPage(pageInstance, pageProperties, animate) {

        // check if it as actually a page or dialog first
        if (typeof pageInstance === 'string' || pageInstance instanceof String)
            for (var i in dialogFileNames)
                if ( pageInstance.search(dialogFileNames[i]) >= 0 ) {
                    // we have a dialog and now need to open it
                    var c = Qt.createComponent(pageInstance);
                    if (pageProperties === undefined)
                        pageProperties = {}
                    var dialog = c.createObject(appWindow, pageProperties);
                    dialog.open()
                    return;
                }


        // the Controls page stack disables animations when
        // false is passed as the third argument, but we want to
        // have a more logical interface, so just invert the value
        // before passing it to the page stack
        pageStack.push(pageInstance, pageProperties, !animate)
        pageStack.currentItem.focusToChild()
        return pageInstance
    }

    function popPage() {
        //console.log("Popping " + pageStack.depth)
        pageStack.pop()
        pageStack.currentItem.focusToChild()
    }

    function popAll() {
        while (pageStack.depth > 1) {
            pageStack.pop()
        }
    }

    function statusUpdate()
    {
        if (settings.track_connectd_service)
        {
            var stat = "collectd: "
            if ( service.running ) stat += "running and "
            else stat += "stopped and "
            if ( service.enabled ) stat += "is enabled on boot"
            else stat += "will not start on boot"

            guiCollectDStat.text = stat + " | "
        }
        else
        {
            guiCollectDStat.text = ""
        }
    }

    Connections {
        target: service
        onRunningChanged: { statusUpdate() }
        onEnabledChanged: { statusUpdate() }
    }

    Component.onCompleted: {
        statusUpdate()
    }

    width: 800
    height: 600

    Settings {
        property alias appWindowX: appWindowBase.x
        property alias appWindowY: appWindowBase.y
        property alias appWindowWidth: appWindowBase.width
        property alias appWindowHeight: appWindowBase.height
    }
}
