import QtQuick 2.2
import Sailfish.Silica 1.0

ApplicationWindow {

    id: appWindowBase

    property bool stateRRDRunning: false
    property string stateLoadingUrl: ""
    property string stateLastRRDError: ""

    property var extraVariables: { }

    signal appZoomIn()
    signal appZoomOut()
    signal appTimeToNow()
    signal appTimeToHistory()
    signal appTimeToFuture()
    signal appTimespan(real timespan)
    signal appSettings()
    signal appAbout()

    // Settings
    allowedOrientations : Orientation.All

    // Menu is defined in ListViewPL

    function isActive() {
        return Qt.application.active
    }

    function pushPage(pageInstance, pageProperties, animate) {
        pageStack.push(pageInstance, pageProperties)
        return pageInstance
    }

    function popPage() {
        console.log("Popping " + pageStack.depth)
        pageStack.pop()
    }

    function popAll() {
        pageStack.clear()
    }

    function statusUpdate()
    {
        if (settings.track_connectd_service)
        {
            var stat = "collectd: "
            if ( service.running ) stat += "running and "
            else stat += "stopped and "
            if ( service.enabled ) stat += "is enabled on boot"
            else stat += "will not start on boot"

        }
        else
        {
            //guiCollectDStat.text = ""
        }
    }

    Connections {
        target: service
        onRunningChanged: { statusUpdate() }
        onEnabledChanged: { statusUpdate() }
    }

    Component.onCompleted: {

        extraVariables = {
            "COLOR_BACKGROUND": "#00000000",
            "COLOR_FONT": Theme.secondaryColor,
            "COLOR_AXIS": Theme.secondaryColor,
            "COLOR_ARROW": Theme.secondaryColor
        }

        statusUpdate()
    }

}
