import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    property string mainText: ""

    allowedOrientations : Orientation.All

    function open() {
        appWindow.pushPage(aboutDialog)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            anchors.margins: Theme.horizontalPageMargin
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About " + programName)
            }

            Label {
                text: qsTr("version: ") + programVersion
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: "<center>" + programName + " is a GUI for visualization of <i>collectd</i> datasets</center>"
                wrapMode: Text.WordWrap
                width: column.width
                textFormat: Text.RichText
            }

            Label {
                text: mainText
                wrapMode: Text.WordWrap
                width: column.width
                font.pixelSize: Theme.fontSizeSmall
                //textFormat: Text.RichText
            }
        }
    }


}

