import QtQuick 2.0
import "."

Item {
    property bool extraSpacing: false

    property int marginText: 5
    property int paddingBetween: 5
    property int paddingEnd: 10

    height: container.height + (extraSpacing ? paddingEnd : 0)

    Column {
        id: container

        anchors.right: parent.right
        anchors.left: parent.left
        spacing: paddingBetween

        Text {
            id: indicator_text

            visible: false
            anchors.right: parent.right
            anchors.margins: marginText
            font.bold: true
            text: ""
        }

        Image {
            id: image
            property int imageHeight: 0

            source: ""

            anchors.left: parent.left
            anchors.right: parent.right
        }
    }
    
    IndicatorPL {
        id: indicator_graph
        anchors.verticalCenter: container.verticalCenter
        anchors.right: container.right
        visible: false
    }

    function calcMyHeight() {
        image.height = image.imageHeight
    }

    function setSize(h) {
        image.imageHeight = h
        calcMyHeight()
    }

    function getSize() {
        return image.imageHeight
    }

    function setSource(sname, h) {
        image.source = sname
    }
    
    function setHeading(txt, vis) {
        indicator_text.text = txt
        indicator_graph.visible = vis
        indicator_text.visible = vis
    }

    Component.onCompleted: {
        calcMyHeight()
    }
}

