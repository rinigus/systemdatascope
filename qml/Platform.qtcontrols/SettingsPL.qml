import QtQuick 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Window 2.2

import "."

ColumnLayoutDialog {
    //Window {

    id: cld

//    property string folderWhileRunning: ""
//    property string folderWhileStopped: ""

//    property int graphHeight: 400
//    property int graphFSZTitle: 14
//    property int graphFSZAxis: 14
//    property int graphFSZUnit: 14
//    property int graphFSZLegend: 14
//    property int updateGraphsInterval: 30

//    property bool trackCollecd: false

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
        checked: settings.track_connectd_service
        text: qsTr("Use " + programName + " to enable/disable collectd")
        anchors.left: grid.left
    }

    Item { height: cld.elemSpacing }

    CheckBox {
        id: guiRunCollectd
        text: qsTr("Run collectd")
        enabled: guiTrackCollectd.checkedState
        checked: service.running
        anchors.left: grid.left
    }


    Item { height: cld.elemSpacing }

    CheckBox {
        id: guiEnableCollectd
        text: qsTr("Enable collectd on boot")
        enabled: guiTrackCollectd.checkedState
        checked: service.enabled
        anchors.left: grid.left
    }

    Item { height: cld.elemSpacing }

    Item { height: cld.elemSpacing }


    Grid {
        id: grid
        spacing: cld.elemSpacing
        columns: 2
        verticalItemAlignment: Grid.AlignVCenter

        Label { id: labelLong; text: qsTr("collectd folder while running, full pathname [/tmp/collectd/<hostname>]: ") }
        TextField { id: guiFolderWhileRunning; implicitWidth: labelLong.width; text: settings.workingdir_collectd_running; }

        Label {
            text: qsTr("collectd folder when stopped, full pathname [~/.local/share/collectd/<hostname>]: ")
            enabled: guiTrackCollectd.checkedState
        }
        TextField {
            id: guiFolderWhileStopped;
            implicitWidth: labelLong.width;
            text: settings.workingdir_collectd_stopped;
            enabled: guiTrackCollectd.checkedState
        }

        Label { text: qsTr("Update graphs interval [seconds]:") }
        TextField {
            id: guiUpdateGraphsInterval
            text: settings.updates_period
            validator: IntValidator { bottom: 1 }
        }

        Label { text: qsTr("Graph height in pixels:") }
        TextField {
            id: guiGraphHeight
            text: settings.graph_base_height
            validator: IntValidator { bottom: 30 }
        }

        Label { text: qsTr("Graphs: Title font size:") }
        TextField {
            id: guiGraphFSZTitle
            text: settings.graph_font_size_title
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Graphs: Axis font size:") }
        TextField {
            id: guiGraphFSZAxis
            text: settings.graph_font_size_axis
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Graphs: Unit font size:") }
        TextField {
            id: guiGraphFSZUnit
            text: settings.graph_font_size_unit
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Graphs: Legend font size:") }
        TextField {
            id: guiGraphFSZLegend
            text: settings.graph_font_size_legend
            validator: IntValidator { bottom: 4 }
        }

        Label { text: qsTr("Report: height in pixels:") }
        TextField {
            id: guiGraphReportHeight
            text: settings.graph_report_height
            validator: IntValidator { bottom: 30 }
        }

        Label { text: qsTr("Generate graph definitions using systemdatascope-makeconfig:") }
        Button {
            text: "Generate"
            onClicked: {
                appWindow.makeConfiguration()
                close()
            }
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
                    close()
                }
            }
        }

    }

    onAccepted:
    {
        settings.workingdir_collectd_running = guiFolderWhileRunning.text
        settings.workingdir_collectd_stopped = guiFolderWhileStopped.text
        settings.track_connectd_service = guiTrackCollectd.checked

        if (guiUpdateGraphsInterval.acceptableInput) settings.updates_period = parseInt(guiUpdateGraphsInterval.text, 10)
        if (guiGraphHeight.acceptableInput) settings.graph_base_height = parseInt(guiGraphHeight.text, 10)
        if (guiGraphFSZTitle.acceptableInput) settings.graph_font_size_title = parseInt(guiGraphFSZTitle.text, 10)
        if (guiGraphFSZAxis.acceptableInput) settings.graph_font_size_axis = parseInt(guiGraphFSZAxis.text, 10)
        if (guiGraphFSZUnit.acceptableInput) settings.graph_font_size_unit = parseInt(guiGraphFSZUnit.text, 10)
        if (guiGraphFSZLegend.acceptableInput) settings.graph_font_size_legend = parseInt(guiGraphFSZLegend.text, 10)
        if (guiGraphReportHeight.acceptableInput) settings.graph_report_height = parseInt(guiGraphReportHeight.text, 10)

        if ( guiTrackCollectd.checked && guiEnableCollectd.checked != service.enabled )
            service.setEnable(guiEnableCollectd.checked)
        if ( guiTrackCollectd.checked && guiRunCollectd.checked != service.running )
            service.setRun(guiRunCollectd.checked)

        appWindow.setConfig()
    }
}

