import QtQuick 2.0
import Sailfish.Silica 1.0
import "."

Item {
    property bool extraSpacing: false
    height: container.height + (extraSpacing ? Theme.paddingLarge : 0)

    Column {
        id: container

        anchors.right: parent.right
        anchors.left: parent.left
        spacing: Theme.paddingMedium

        Label {
            id: indicator_text

            visible: false
            anchors.right: parent.right
            anchors.margins: Theme.horizontalPageMargin
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
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

    function getWidth() {
        return image.sourceSize.width
    }

    function setSource(sname) {
        image.source = sname
        image.imageHeight = image.sourceSize.height
        calcMyHeight()
    }

    function getSource() {
        return image.source
    }

    function setHeading(txt, vis) {
        indicator_text.text = txt
        indicator_graph.visible = vis
        indicator_text.visible = vis
    }
}

