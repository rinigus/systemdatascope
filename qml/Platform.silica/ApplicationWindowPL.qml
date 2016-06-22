import QtQuick 2.2
import Sailfish.Silica 1.0

ApplicationWindow {

    id: appWindowBase

    property bool stateRRDRunning: false
    property string stateLoadingUrl: ""
    property string stateLastRRDError: ""

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

    function pushPage(pageInstance, pageProperties, animate) {
        pageStack.push(pageInstance, pageProperties)
        return pageInstance
    }

    function popPage() {
        console.log("Popping " + pageStack.depth)
        pageStack.pop()
    }

    function popAll() {
        while (pageStack.depth > 1) {
            pageStack.pop()
        }
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
        statusUpdate()
    }

}
