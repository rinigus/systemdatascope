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
            "COLOR_ARROW": Theme.secondaryColor,
            "COLOR_LINE_SINGLE": Theme.highlightColor,
            "COLOR_LINE_SINGLE_SUB": Theme.secondaryHighlightColor
        }

        statusUpdate()
    }

    //////////////////////////////////////////////////////////////////////
    /// Functions and objects dealing with cover

    property int cover_index: 0
    property var cover_list: []

    function setCover()
    {
        var old_len = cover_list.length
        cover_list = appWindow.graphConfig[ "cover" ]

        if (old_len != cover_list.length )
            cover_index = 0

        imageCover.askImage()
    }

    cover:     Component {
        CoverBackground {
            id: cover

            CoverActionList {
                CoverAction {
                    iconSource: "image://theme/icon-m-left"
                    onTriggered: {
                        if ( cover_list.length < 1 ) return;
                        cover_index = cover_index-1
                        if (cover_index < 0)
                            cover_index = cover_list.length-1

                        imageCover.askImage()
                    }

                }
                CoverAction {
                    iconSource: "image://theme/icon-m-right"
                    onTriggered: {
                        if ( cover_list.length < 1 ) return;
                        cover_index = cover_index+1
                        if (cover_index >= cover_list.length)
                            cover_index = 0

                        imageCover.askImage()
                    }
                }
            }

            onStatusChanged: {
                if (status == Cover.Active)
                    imageCover.askImage()
            }

            Image {
                id: imageCover

                property int myCallbackId: -1

                source: "image://theme/icon-l-clock"

                anchors.left: parent.left
                anchors.right: parent.right
                height: cover.height * 0.75

                function askImage() {
                    if (myCallbackId <= 0)
                        myCallbackId = appWindow.getCallbackId()

                    if (cover_index >= cover_list.length)
                        return ; // list is not filled

                    grapher.getImage(myCallbackId, cover_list[cover_index], settings.timewindow_from, settings.timewindow_duration,
                                     Qt.size(width,height), true )
                }

                Connections {
                    target: grapher
                    onNewImage: {
                        if (imageFor == imageCover.myCallbackId)
                        {
                            console.log("Cover Image received: ", imageFor, fname)
                            imageCover.source = fname
                        }
                    }
                }

                onWidthChanged: {
                    askImage()
                }

                onHeightChanged: {
                    askImage()
                }

                Component.onCompleted: {
                    askImage()
                }

                // We are updating when the cover becomes active,
                // no need to do it earlier
//                // cover update timer
//                Timer {
//                    id: coverTimer
//                    interval: settings.updates_period * 1000
//                    running: true
//                    repeat: true
//                    onTriggered: {
//                        var now = new Date()
//                        console.log(now.toTimeString() + " Cover Timer")
//                        imageCover.askImage();
//                    }
//                }
            }
        }
    }
}
