import QtQuick 2.0
import QtQuick.Dialogs 1.2
import "."

MessageDialogPL {

    title: "About " + programName

    text: programName + ", version " + programVersion + "\n" +
            programName + " is a GUI for visualization of collectd datasets"

    informativeText: mainText

    icon: StandardIcon.Information
}
