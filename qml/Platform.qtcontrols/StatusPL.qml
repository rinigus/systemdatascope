import QtQuick 2.0
import "."

PagePL {

    property string stat: ""

    FlickablePL {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            anchors.margins: 10
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 10

            Text {
                text: qsTr("Status")

                anchors.left: column.left
                anchors.right: column.right

                font.pointSize: 32
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                minimumPointSize: 8
            }

            Text {
                text: stat
                wrapMode: Text.WordWrap
                width: column.width
                textFormat: Text.RichText
            }

            Item { }

        }
    }
}

