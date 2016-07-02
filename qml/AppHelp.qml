import QtQuick 2.0
import "Platform"

PagePL {

    FlickablePL {
        anchors.fill: parent
        contentHeight: helpText.height

        HelpText {
            id: helpText
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }
}

