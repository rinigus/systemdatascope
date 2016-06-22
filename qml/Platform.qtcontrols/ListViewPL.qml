import QtQuick 2.0

ListView {
    property string header_text: ""

    header: Text {
        text: header_text

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.width * 0.025

        font.pointSize: 32
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        minimumPointSize: 8

    }
}
