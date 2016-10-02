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
                //color: Theme.highlightColor
            }

            Item { }

        }
    }
}

