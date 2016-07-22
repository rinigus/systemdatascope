import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {

    //    property string folderWhileRunning: ""
    //    property string folderWhileStopped: ""

    //    property int graphHeight: 400
    //    property int graphFSZTitle: 14
    //    property int graphFSZAxis: 14
    //    property int graphFSZUnit: 14
    //    property int graphFSZLegend: 14
    //    property int updateGraphsInterval: 30

    //    property bool trackCollecd: false

    property bool applyOnInactive: false

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
                checked: settings.track_connectd_service
                text: qsTr("Use " + programName + " to enable/disable collectd")
                //anchors.left: grid.left
            }

            TextSwitch {
                id: guiRunCollectd
                text: qsTr("Run collectd")
                enabled: guiTrackCollectd.checked
                checked: service.running
                //anchors.left: grid.left
            }

            TextSwitch {
                id: guiEnableCollectd
                text: qsTr("Enable collectd on boot")
                enabled: guiTrackCollectd.checked
                checked: service.enabled
                //anchors.left: grid.left
            }

            Column {
                width: parent.width
                anchors.margins: Theme.horizontalPageMargin
                spacing: Theme.paddingSmall
                TextField {
                    id: guiFolderWhileRunning;
                    width: parent.width
                    text: settings.workingdir_collectd_running
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
                    text: settings.workingdir_collectd_stopped
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
                text: settings.updates_period
                width: parent.width
                label: qsTr("Update graphs interval [seconds]")
                validator: IntValidator { bottom: 1 }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                id: guiGraphHeight
                text: settings.graph_base_height
                width: parent.width
                label: qsTr("Graph height in pixels")
                validator: IntValidator { bottom: 30 }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Title font size")
                id: guiGraphFSZTitle
                text: settings.graph_font_size_title
                width: parent.width
                validator: IntValidator { bottom: 4 }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Axis font size")
                id: guiGraphFSZAxis
                text: settings.graph_font_size_axis
                validator: IntValidator { bottom: 4 }
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Unit font size")
                id: guiGraphFSZUnit
                text: settings.graph_font_size_unit
                validator: IntValidator { bottom: 4 }
                width: parent.width
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                label: qsTr("Graphs: Legend font size")
                id: guiGraphFSZLegend
                text: settings.graph_font_size_legend
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
                    text: qsTr("Graph definitions can be generated by running systemdatascope-makeconfig automatically")
                    wrapMode: Text.WordWrap
                    x: Theme.horizontalPageMargin
                    width: parent.width - x*2
                    font.pixelSize: Theme.fontSizeSmall

                }

                Button {
                    text: qsTr("Generate definitions")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        appWindow.makeConfiguration()

                        // Commented out since if we get an error while in
                        // transition. There are 2 outcomes, either we are successful or not. In the case
                        // of success, all pages are reloaded. If failed, error page will come up.

                        //reject()
                    }
                }

                Label { text: " " } // extra separator
            }

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
                    onClicked: {
                        appWindow.loadNewConfig(guiConfigUrl.text)
                        reject()
                    }
                }

                Label { text: " " } // extra separator
            }
        }

        VerticalScrollDecorator {}
    }

    //    function prop2gui()
    //    {
    //        // keep URL as it was in the dialog, to allow to fix the typos. Same for the directories

    //        guiTrackCollectd.checked = trackCollecd
    //        guiUpdateGraphsInterval.text = updateGraphsInterval
    //        guiGraphHeight.text = graphHeight
    //        guiGraphFSZTitle.text = graphFSZTitle
    //        guiGraphFSZAxis.text = graphFSZAxis
    //        guiGraphFSZUnit.text = graphFSZUnit
    //        guiGraphFSZLegend.text = graphFSZLegend
    //    }

    //    function gui2props()
    //    {
    //        folderWhileRunning = guiFolderWhileRunning.text
    //        folderWhileStopped = guiFolderWhileStopped.text
    //        trackCollecd = guiTrackCollectd.checked

    //        if (guiUpdateGraphsInterval.acceptableInput) updateGraphsInterval = parseInt(guiUpdateGraphsInterval.text, 10)
    //        if (guiGraphHeight.acceptableInput) graphHeight = parseInt(guiGraphHeight.text, 10)
    //        if (guiGraphFSZTitle.acceptableInput) graphFSZTitle = parseInt(guiGraphFSZTitle.text, 10)
    //        if (guiGraphFSZAxis.acceptableInput) graphFSZAxis = parseInt(guiGraphFSZAxis.text, 10)
    //        if (guiGraphFSZUnit.acceptableInput) graphFSZUnit = parseInt(guiGraphFSZUnit.text, 10)
    //        if (guiGraphFSZLegend.acceptableInput) graphFSZLegend = parseInt(guiGraphFSZLegend.text, 10)
    //    }

    onAccepted:
    {
        applyOnInactive = true
    }

    onStatusChanged:
    {
        if (status != PageStatus.Inactive || !applyOnInactive)
            return

        settings.workingdir_collectd_running = guiFolderWhileRunning.text
        settings.workingdir_collectd_stopped = guiFolderWhileStopped.text
        settings.track_connectd_service = guiTrackCollectd.checked

        if (guiUpdateGraphsInterval.acceptableInput) settings.updates_period = parseInt(guiUpdateGraphsInterval.text, 10)
        if (guiGraphHeight.acceptableInput) settings.graph_base_height = parseInt(guiGraphHeight.text, 10)
        if (guiGraphFSZTitle.acceptableInput) settings.graph_font_size_title = parseInt(guiGraphFSZTitle.text, 10)
        if (guiGraphFSZAxis.acceptableInput) settings.graph_font_size_axis = parseInt(guiGraphFSZAxis.text, 10)
        if (guiGraphFSZUnit.acceptableInput) settings.graph_font_size_unit = parseInt(guiGraphFSZUnit.text, 10)
        if (guiGraphFSZLegend.acceptableInput) settings.graph_font_size_legend = parseInt(guiGraphFSZLegend.text, 10)

        if ( guiTrackCollectd.checked && guiEnableCollectd.checked != service.enabled )
            service.setEnable(guiEnableCollectd.checked)
        if ( guiTrackCollectd.checked && guiRunCollectd.checked != service.running )
            service.setRun(guiRunCollectd.checked)

        applyOnInactive = false

        appWindow.appSetConfig()
    }
}
