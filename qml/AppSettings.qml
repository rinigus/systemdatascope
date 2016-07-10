import QtQuick 2.0
import "Platform"

SettingsPL {

    Component.onCompleted: {
        service.updateState()

        updateGraphsInterval = settings.updates_period
        graphHeight = settings.graph_base_height
        graphFSZTitle = settings.graph_font_size_title
        graphFSZAxis = settings.graph_font_size_axis
        graphFSZUnit = settings.graph_font_size_unit
        graphFSZLegend = settings.graph_font_size_legend

        folderWhileRunning = settings.workingdir_collectd_running
        folderWhileStopped = settings.workingdir_collectd_stopped
        trackCollecd = settings.track_connectd_service

        prop2gui()
    }

    onAccepted:
    {
        gui2props()

        settings.updates_period = updateGraphsInterval
        settings.graph_base_height = graphHeight
        settings.graph_font_size_title = graphFSZTitle
        settings.graph_font_size_axis = graphFSZAxis
        settings.graph_font_size_unit = graphFSZUnit
        settings.graph_font_size_legend = graphFSZLegend

        settings.workingdir_collectd_running = folderWhileRunning
        settings.workingdir_collectd_stopped = folderWhileStopped
        settings.track_connectd_service = trackCollecd

        appWindow.setConfig()
    }
}
