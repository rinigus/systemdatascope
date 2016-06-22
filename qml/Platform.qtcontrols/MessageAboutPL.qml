import QtQuick 2.0
import "."

MessageDialogPL {

    property string mainText: ""

    Text {
        text: "About"
        font.pointSize: 24
    }

    Text {
        text: programName + ", version " + programVersion
        font.pointSize: 24
    }

    Item {}

    Text {
        text: programName + " is a GUI for visualization of collectd datasets"
        font.pointSize: 16
    }

    Item {}

    Text {
        text: mainText
        //style: Text.StyledText
        font.pointSize: 12
    }
}
