import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    allowedOrientations : Orientation.All

    property string stat: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: "Copy to clipboard"
                onClicked: {
                    var s = stat
                    var n = s.replace(/<br>/g, "\n")
                    Clipboard.text = n
                }
            }
        }

        Column {
            id: column

            anchors.margins: Theme.horizontalPageMargin
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Status")
            }

            Label {
                text: stat
                wrapMode: Text.WordWrap
                width: column.width
                textFormat: Text.RichText
            }

            Item { }

        }
    }


    function updateStatus() {
        service.updateState()
        stat = "collectd: " + (service.running ? "Running" : "Stopped") + " / " +
                (service.enabled ? "Enabled on boot" : "Will not start on boot") +
                "<br><br>" +

                "RRDtool: " + (appWindow.stateRRDRunning ? "Running" : "Stopped") + "<br><br>" +

                "Last state of the loading URL: " + stateLoadingUrl + "<br><br>" +

                "Last RRDtool error: " + stateLastRRDError + "<br><br>" +

                qsTr("Use " + programName + " to enable/disable collectd: ") + settings.track_connectd_service + "<br><br>" +

                qsTr("Folder with the collectd databases while running: ") + settings.workingdir_collectd_running + "<br><br>" +

                qsTr("Folder with the collectd databases while the daemon is stopped: ")  + settings.workingdir_collectd_stopped + "<br>"

        stat += "<br>Loaded configuration:<br>" + appWindow.config2str("", appWindow.graphConfig.page)

    }

    Component.onCompleted: { updateStatus() }
}

