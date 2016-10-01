import QtQuick 2.0
import QtQuick.Dialogs 1.2
import "."

MessageDialogPL {

    property string headerText: ""
    property string mainText: ""

    title: headerText

    text: mainText

    icon: StandardIcon.Information
}
