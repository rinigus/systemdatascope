import QtQuick 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Window 2.2

import "."

ColumnLayoutDialog {
    //Window {

    id: cld

    property string folderWhileRunning: ""
    property string folderWhileStopped: ""

    property int graphHeight: 400
    property int graphFSZTitle: 14
    property int graphFSZAxis: 14
    property int graphFSZUnit: 14
    property int graphFSZLegend: 14
    property int updateGraphsInterval: 30

    property bool trackCollecd: false

    // Gui properties
    property int elemSpacing: 4

    title: qsTr("Settings")
    standardButtons: StandardButton.Cancel | StandardButton.Ok

    Text {
        text: qsTr("Settings")

        anchors.left: grid.left
        anchors.right: grid.right

        font.pointSize: 32
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        minimumPointSize: 8

    }

    CheckBox {
        id: guiTrackCollectd
        checked: trackCollecd
        text: qsTr("Use " + programName + " to enable/disable collectd")
        anchors.left: grid.left
    }

    Item { height: cld.elemSpacing }

    CheckBox {
        text: qsTr("Run collectd")
        enabled: guiTrackCollectd.checkedState
        checked: service.running
        anchors.left: grid.left

        onCheckedChanged: {
            if ( guiTrackCollectd.checkedState ) service.setRun(checked)
        }
    }


    Item { height: cld.elemSpacing }

    CheckBox {
        text: qsTr("Enable collectd on boot")
        enabled: guiTrackCollectd.checkedState
        checked: service.enabled
        anchors.left: grid.left

        onCheckedChanged: {
            if ( guiTrackCollectd.checkedState ) service.setEnable(checked)
        }
    }

    Item { height: cld.elemSpacing }

    Item { height: cld.elemSpacing }


    Grid {
        id: grid
        spacing: cld.elemSpacing
        columns: 2
        verticalItemAlignment: Grid.AlignVCenter

        Label { id: labelLong; text: qsTr("collectd folder while running, full pathname [/tmp/collectd/<hostname>]: ") }
        TextField { id: guiFolderWhileRunning; implicitWidth: labelLong.width; text: folderWhileRunning; }

        Label {
            text: qsTr("collectd folder when stopped, full pathname [~/.local/share/collectd/<hostname>]: ")
            enabled: guiTrackCollectd.checkedState
        }
        TextField {
            id: guiFolderWhileStopped;
            implicitWidth: labelLong.width;
            text: folderWhileStopped;
            enabled: guiTrackCollectd.checkedState
        }

        Label { text: qsTr("Update graphs interval [seconds]:") }
        TextField {
            id: guiUpdateGraphsInterval
            text: updateGraphsInterval
            validator: IntValidator { bottom: 1 }
        }

        Label { text: qsTr("Graph height in pixels:") }
        TextField {
            id: guiGraphHeight
            text: graphHeight
            validator: IntValidator { bottom: 30 }
        }

        Label { text: qsTr("Graphs: Title font size:") }
        TextField {
            id: guiGraphFSZTitle
            text: graphFSZTitle
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Graphs: Axis font size:") }
        TextField {
            id: guiGraphFSZAxis
            text: graphFSZAxis
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Graphs: Unit font size:") }
        TextField {
            id: guiGraphFSZUnit
            text: graphFSZUnit
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Graphs: Legend font size:") }
        TextField {
            id: guiGraphFSZLegend
            text: graphFSZLegend
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Load new graph definitions from URL:") }
        Row {
            spacing: cld.elemSpacing
            TextField {
                id: guiConfigUrl ;
                implicitWidth: labelLong.width - cld.elemSpacing - loadButton.width;
                text: settings.graph_last_used_url
            }
            Button {
                id: loadButton
                text: "Load"
                onClicked: {
                    appWindow.loadNewConfig(guiConfigUrl.text)
                }
            }
        }


    }

    function prop2gui()
    {
        // keep URL as it was in the dialog, to allow to fix the typos. Same for the directories

        guiTrackCollectd.checked = trackCollecd
        guiUpdateGraphsInterval.text = updateGraphsInterval
        guiGraphHeight.text = graphHeight
        guiGraphFSZTitle.text = graphFSZTitle
        guiGraphFSZAxis.text = graphFSZAxis
        guiGraphFSZUnit.text = graphFSZUnit
        guiGraphFSZLegend.text = graphFSZLegend
    }

    function gui2props()
    {
        folderWhileRunning = guiFolderWhileRunning.text
        folderWhileStopped = guiFolderWhileStopped.text
        trackCollecd = guiTrackCollectd.checkedState

        if (guiUpdateGraphsInterval.acceptableInput) updateGraphsInterval = parseInt(guiUpdateGraphsInterval.text, 10)
        if (guiGraphHeight.acceptableInput) graphHeight = parseInt(guiGraphHeight.text, 10)
        if (guiGraphFSZTitle.acceptableInput) graphFSZTitle = parseInt(guiGraphFSZTitle.text, 10)
        if (guiGraphFSZAxis.acceptableInput) graphFSZAxis = parseInt(guiGraphFSZAxis.text, 10)
        if (guiGraphFSZUnit.acceptableInput) graphFSZUnit = parseInt(guiGraphFSZUnit.text, 10)
        if (guiGraphFSZLegend.acceptableInput) graphFSZLegend = parseInt(guiGraphFSZLegend.text, 10)
    }
}

