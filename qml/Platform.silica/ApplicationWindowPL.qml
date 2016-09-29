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
    signal appCoverTimespan(real timespan)
    signal appSettings()
    signal appAbout()
    signal appHelp()
    signal appStatus()
    signal appSetConfig()
    signal appMakeReport()

    // Settings
    allowedOrientations : Orientation.All

    // Menu is defined in ListViewPL

    function isActive() {
        return Qt.application.active
    }

    function pushPage(pageInstance, pageProperties, animate) {
        pageStack.completeAnimation()
        //console.log("Pushing new " + pageStack.depth + " " + pageStack.busy)
        pageStack.push(pageInstance, pageProperties)
        return pageInstance
    }

    function popPage() {
        //console.log("Popping " + pageStack.depth)
        pageStack.pop()
    }

    function popAll() {
        //console.log("Popping all "+ pageStack.busy)
        pageStack.clear()
    }

    Timer {
        id: transitionChecker
        interval: 250 // 0.25 s
        running: false
        repeat: true
        onTriggered: {
            appWindowBase.appSetConfig()
        }
    }

    onAppSetConfig: {
        if ( pageStack.busy ) // wait till the transition ends
        {
            //console.log("Wait for it")
            transitionChecker.running = true
            return
        }
        transitionChecker.running = false
        appWindow.setConfig()
    }

    //    Connections {
    //        target: service
    //        onRunningChanged: {  }
    //        onEnabledChanged: {  }
    //    }

    Component.onCompleted: {

        extraVariables = {
            "COLOR_BACKGROUND": "#00000000",
            "COLOR_FONT": Theme.secondaryColor,
            "COLOR_AXIS": Theme.secondaryColor,
            "COLOR_ARROW": Theme.secondaryColor,
            "COLOR_LINE_SINGLE": Theme.highlightColor,
            "COLOR_LINE_SINGLE_SUB": Theme.secondaryHighlightColor
        }
    }

    // Progress bar to show image generation
    //
    Rectangle {
        id: progress
        property int progHeight: Math.max(3, Screen.height*0.0075)
        property double currentProgress: 0.0

        z: 100
        x: 0
        y: 0

        height: 0
        width: 0
        color: "steelblue"
        visible: false

        function changeSize(sz)
        {
            currentProgress = sz
            drawBar()
        }

        function drawBar()
        {
            if (appWindowBase.orientation == Orientation.Portrait) {
                x = 0
                y = 0
                height = progHeight
                width = Screen.width * currentProgress
            }
            else if (appWindowBase.orientation == Orientation.Landscape) {
                x = Screen.width - progHeight
                y = 0
                height = Screen.height * currentProgress
                width = progHeight
            }
            else if (appWindowBase.orientation == Orientation.PortraitInverted) {
                height = progHeight
                width = Screen.width * currentProgress
                x = Screen.width - width
                y = Screen.height - height
            }
            else if (appWindowBase.orientation == Orientation.LandscapeInverted) {
                height = Screen.height * currentProgress
                width = progHeight
                x = 0
                y = Screen.height - height
            }
        }
    }

    onOrientationChanged: {
        progress.drawBar()
    }

    function getProgressFullWidth()
    {
        return 1.0
    }

    function setProgressState(visible, width)
    {
        progress.changeSize(width)
        progress.visible = visible
    }

    //////////////////////////////////////////////////////////////////////
    /// Functions and objects dealing with cover

    property var cover_list: []

    function setCover()
    {
        if ( appWindow.graphConfig ) {
            cover_list = appWindow.graphConfig[ "cover" ]
            if ('undefined' !== typeof imageCover) imageCover.askImage()
        }
    }

    cover: Component {
        CoverBackground {
            id: cover

            CoverActionList {

                CoverAction {
                    iconSource: "image://theme/icon-cover-previous"
                    onTriggered: {
                        if ( cover_list.length < 1 ) return;
                        settings.cover_index = settings.cover_index-1
                        if (settings.cover_index < 0)
                            settings.cover_index = cover_list.length-1

                        imageCover.askImage()
                    }

                }
                CoverAction {
                    iconSource: "image://theme/icon-cover-next"
                    onTriggered: {
                        if ( cover_list.length < 1 ) return;
                        settings.cover_index = settings.cover_index+1
                        if (settings.cover_index >= cover_list.length)
                            settings.cover_index = 0

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

                source: "/usr/share/icons/hicolor/128x128/apps/systemdatascope.png"

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: parent.height*0.8
                fillMode: Image.PreserveAspectFit

                function askImage() {
                    if ( cover_list == null )
                        return;

                    if (myCallbackId <= 0)
                        myCallbackId = appWindow.getCallbackId()

                    if (cover_list.length < 1)
                        return ; // list is not filled

                    if (settings.cover_index >= cover_list.length)
                        settings.cover_index = 0

                    grapher.getImage(myCallbackId, cover_list[settings.cover_index], 0, settings.cover_timewindow_duration,
                                     Qt.size(width,height), true, source )
                }

                Connections {
                    target: grapher
                    onNewImage: {
                        if (imageFor == imageCover.myCallbackId)
                        {
                            // console.log("Cover Image received: ", imageFor, fname)
                            imageCover.source = fname
                        }
                    }

                }

                Connections {
                    target: appWindow
                    onAppCoverTimespan: {
                        settings.cover_timewindow_duration = timespan
                        imageCover.askImage()
                    }
                }

                onWidthChanged: {
                    imageCover.askImage()
                }

                onHeightChanged: {
                    imageCover.askImage()
                }

                Component.onCompleted: {
                    imageCover.askImage()
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
