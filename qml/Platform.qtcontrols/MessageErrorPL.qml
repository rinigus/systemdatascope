import QtQuick 2.0
import "."

MessageDialogPL {

    property string mainText: ""

    Text {
        text: "Error"
        font.pointSize: 24
    }

    Item {}

    Text {
        text: mainText
        //style: Text.StyledText
        font.pointSize: 12
    }
}
