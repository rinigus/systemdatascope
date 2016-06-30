import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    allowedOrientations : Orientation.All

    property string stat: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

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
        stat = "collectd: " + (service.running ? "Running" : "Stopped") + " / " +
                (service.enabled ? "Enabled on boot" : "Will not start on boot") +
                "<br><br>" +

                "RRDtool: " + (appWindow.stateRRDRunning ? "Running" : "Stopped") + "<br><br>" +

                "Last state of the loading URL: " + stateLoadingUrl + "<br><br>" +

                "Last RRDtool error: " + stateLastRRDError + "<br>"
    }

    Component.onCompleted: { updateStatus() }
}

