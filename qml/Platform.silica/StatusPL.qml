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
                    s = s.replace(/<br>/g, "\n")
                    s = s.replace(/&nbsp;/g, " ")
                    Clipboard.text = s
                    console.log(s)
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
        stat = "<b>collectd:</b> " + (service.running ? "Running" : "Stopped") + " / " +
                (service.enabled ? "Enabled on boot" : "Will not start on boot") +
                "<br><br>" +

                "<b>RRDtool:</b> " + (appWindow.stateRRDRunning ? "Running" : "Stopped") + "<br><br>" +

                "<b>Last state of the loading URL:</b> " + stateLoadingUrl + "<br><br>" +

                "<b>Last RRDtool error:</b> " + stateLastRRDError + "<br><br>" +

                qsTr("<b>Use " + programName + " to enable/disable collectd:</b> ") + settings.track_connectd_service + "<br><br>" +

                qsTr("<b>Folder with the collectd databases while running:</b> ") + settings.workingdir_collectd_running + "<br><br>" +

                qsTr("<b>Folder with the collectd databases while the daemon is stopped:</b> ")  + settings.workingdir_collectd_stopped + "<br>"

        stat += "<br><b>Loaded configuration:</b><br><br><small>" + appWindow.config2str("", appWindow.graphConfig.page)
        stat += "<br>N/A corresponds to the non-available plot (RRD file is missing, for example)<br></small>"

    }

    Component.onCompleted: { updateStatus() }
}

