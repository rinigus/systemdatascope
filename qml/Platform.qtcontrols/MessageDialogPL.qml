import QtQuick.Dialogs 1.2

MessageDialog {

    property string mainText: ""
    property string additionalInfo: ""
    property bool toOpen: true

    text: mainText

    informativeText: additionalInfo

    standardButtons: StandardButton.Ok
}

