import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {

    property string folderWhileRunning: ""
    property string folderWhileStopped: ""

    property int graphHeight: 400
    property int graphFSZTitle: 14
    property int graphFSZAxis: 14
    property int graphFSZUnit: 14
    property int graphFSZLegend: 14
    property int updateGraphsInterval: 30

    property bool trackCollecd: false

    allowedOrientations : Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height

        Column {
            id: mainColumn
            width: parent.width
            anchors.margins: Theme.horizontalPageMargin
            spacing: Theme.paddingMedium

            DialogHeader {
                title: qsTr("Settings")
            }


            TextSwitch {
                id: guiTrackCollectd
                checked: trackCollecd
                text: qsTr("Use " + programName + " to enable/disable collectd")
                //anchors.left: grid.left
            }

            TextSwitch {
                text: qsTr("Run collectd")
                enabled: guiTrackCollectd.checked
                checked: service.running
                //anchors.left: grid.left

                onCheckedChanged: {
                    if ( guiTrackCollectd.checked ) service.setRun(checked)
                }
            }

            TextSwitch {
                text: qsTr("Enable collectd on boot")
                enabled: guiTrackCollectd.checked
                checked: service.enabled
                //anchors.left: grid.left

                onCheckedChanged: {
                    if ( guiTrackCollectd.checked ) service.setEnable(checked)
                }
            }

            Column {
                width: parent.width
                anchors.margins: Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                TextField {
                    id: guiFolderWhileRunning;
                    width: parent.width
                    text: folderWhileRunning;
                    label: qsTr("collectd folder while running")
                }
                Label {
                    text: qsTr("Folder with the collectd databases while running. For example, /tmp/collectd/<hostname>")
                    x: Theme.horizontalPageMargin
                    width: parent.width-2*x
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            Column {
                width: parent.width
                anchors.margins: Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                enabled: guiTrackCollectd.checked
                TextField {
                    id: guiFolderWhileStopped;
                    width: parent.width
                    text: folderWhileStopped;
                    label: qsTr("collectd folder while stopped")
                }
                Label {
                    text: qsTr("Folder with the collectd databases while the daemon is stopped. For example, ~/.local/share/collectd/<hostname>")
                    x: Theme.horizontalPageMargin
                    width: parent.width-2*x
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            TextField {
                id: guiUpdateGraphsInterval
                text: updateGraphsInterval
                width: parent.width
                label: qsTr("Update graphs interval [seconds]")
                validator: IntValidator { bottom: 1 }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                id: guiGraphHeight
                text: graphHeight
                width: parent.width
                label: qsTr("Graph height in pixels")
                validator: IntValidator { bottom: 30 }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Title font size")
                id: guiGraphFSZTitle
                text: graphFSZTitle
                width: parent.width
                validator: IntValidator { bottom: 4 }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Axis font size")
                id: guiGraphFSZAxis
                text: graphFSZAxis
                validator: IntValidator { bottom: 4 }
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Unit font size")
                id: guiGraphFSZUnit
                text: graphFSZUnit
                validator: IntValidator { bottom: 4 }
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Legend font size")
                id: guiGraphFSZLegend
                text: graphFSZLegend
                validator: IntValidator { bottom: 4 }
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }


            Label { text: " " } // extra separator

            Column {
                width: parent.width
                anchors.margins: Theme.horizontalPageMargin
                spacing: Theme.paddingSmall

                Label {
                    text: qsTr("The graph definitions can be loaded from remote or local URL (use file:// for local URL). For that, type URL to graph definition in JSON format and press Load definitions button below. Note that acceping the new settings will not load the definitions")
                    wrapMode: Text.WordWrap
                    x: Theme.horizontalPageMargin
                    width: parent.width - x*2
                    font.pixelSize: Theme.fontSizeSmall

                }

                TextField {
                    label: qsTr("Interface configuration URL")
                    id: guiConfigUrl
                    text: settings.graph_last_used_url
                    width: parent.width
                }

                Button {
                    text: qsTr("Load definitions")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: { appWindow.loadNewConfig(guiConfigUrl.text) }
                }

                Label { text: " " } // extra separator
            }
        }

        VerticalScrollDecorator {}
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
        trackCollecd = guiTrackCollectd.checked

        if (guiUpdateGraphsInterval.acceptableInput) updateGraphsInterval = parseInt(guiUpdateGraphsInterval.text, 10)
        if (guiGraphHeight.acceptableInput) graphHeight = parseInt(guiGraphHeight.text, 10)
        if (guiGraphFSZTitle.acceptableInput) graphFSZTitle = parseInt(guiGraphFSZTitle.text, 10)
        if (guiGraphFSZAxis.acceptableInput) graphFSZAxis = parseInt(guiGraphFSZAxis.text, 10)
        if (guiGraphFSZUnit.acceptableInput) graphFSZUnit = parseInt(guiGraphFSZUnit.text, 10)
        if (guiGraphFSZLegend.acceptableInput) graphFSZLegend = parseInt(guiGraphFSZLegend.text, 10)
    }
}

