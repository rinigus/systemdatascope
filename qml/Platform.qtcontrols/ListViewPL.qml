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

    Connections {
        target: parent
        onFocusToMainList: { forceActiveFocus() }
    }

    highlight: Rectangle {
        color: "white"
        radius: 5
        border.width: 1
        border.color: "lightsteelblue"
    }

    highlightMoveDuration: 500
    highlightResizeDuration: 100
    focus: true
    clip: true

    Component.onCompleted: {
        forceActiveFocus()
    }

    function setFocus() {
        mainList.forceActiveFocus()
    }
}
