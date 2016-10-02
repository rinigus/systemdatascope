import QtQuick 2.2
import Sailfish.Silica 1.0

Page {

    property string mainText: ""

    allowedOrientations : Orientation.All

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
                title: qsTr("About " + programName)
            }

            Label {
                text: qsTr("version: ") + programVersion
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
            }

            Label {
                text: "<center>" + programName + " is a GUI for visualization of <i>collectd</i> datasets</center>"
                wrapMode: Text.WordWrap
                width: column.width
                textFormat: Text.RichText
                //color: Theme.highlightColor
            }

            Label {
                text: mainText
                wrapMode: Text.WordWrap
                width: column.width
                font.pixelSize: Theme.fontSizeSmall
                //color: Theme.highlightColor
                //textFormat: Text.RichText
            }
        }
    }


}

