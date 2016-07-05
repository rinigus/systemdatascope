/*
  Copyright (C) 2016 rinigus <rinigus.git@gmail.com>
  License: MIT
*/

import QtQuick 2.2

import "Platform"
import "."

ApplicationWindowPL {
    visible: true
    id: appWindow

    property var graphConfig: {}
    property int nextId: 0

    // signals
    signal updateGraphs()
    signal loadNewConfig(string url)

    SettingsStoragePL {
        id: settings

        property int graph_base_height: 400
        property int graph_font_size_title: 14
        property int graph_font_size_axis: 10
        property int graph_font_size_unit: 10
        property int graph_font_size_legend: 10

        property real timewindow_duration: 24*60*60
        property real timewindow_from: 0

        property string graph_definitions: ""
        property string graph_last_used_url: ""

        property string workingdir_collectd_running: ""
        property string workingdir_collectd_stopped: ""

        property bool track_connectd_service: true

        property real updates_period: 30

        property real cover_timewindow_duration: 60*60
        property int cover_index: 0
    }

    // Main GUI List
    GraphList {
        id: gList
    }

    Component.onCompleted: {

        settings.timewindow_from = 0

        // Settings
        if (settings.workingdir_collectd_running.length < 1)
            settings.workingdir_collectd_running = grapher.suggestDirectory(true);

        if (settings.workingdir_collectd_stopped.length < 1)
            settings.workingdir_collectd_stopped = grapher.suggestDirectory(false);

        setConfig()
    }

    // Signal handlers: Timewindow
    onAppZoomIn: { settings.timewindow_duration = settings.timewindow_duration / 2.0; updateGraphs()  }
    onAppZoomOut: { settings.timewindow_duration = settings.timewindow_duration * 2.0; updateGraphs() }

    onAppTimeToNow: { settings.timewindow_from = 0; updateGraphs() }
    onAppTimeToHistory: { settings.timewindow_from = settings.timewindow_from - settings.timewindow_duration; updateGraphs() }
    onAppTimeToFuture: {
        if ( settings.timewindow_from + settings.timewindow_duration > 1e-10 ) return; // cannot look into real future
        settings.timewindow_from = settings.timewindow_from + settings.timewindow_duration;
        updateGraphs()
    }

    onAppTimespan: {
        settings.timewindow_duration = timespan
        updateGraphs()
    }

    // update timer
    Timer {
        id: mainTimer
        interval: settings.updates_period * 1000
        running: true
        repeat: true
        onTriggered: {
            // var now = new Date()
            // console.log(now.toTimeString() + " Timer")
            grapher.checkCache();
            if ( isActive() )
            {
                appWindow.updateGraphs()
            }
        }
    }

    onApplicationActiveChanged: {
        // var now = new Date()
        // console.log(now.toTimeString() + " Application active changed to " + Qt.application.active)
        if ( isActive() )
        {
            // make updates and reinstall timer
            grapher.checkCache();
            appWindow.updateGraphs()
            mainTimer.interval = settings.updates_period * 1000
        }
        else
        {
            mainTimer.interval = 15 * 60 * 1000
        }
    }

    // Dialogs
    AppAbout {
        id: aboutDialog
    }

    onAppAbout: {
        aboutDialog.open()
    }

    AppSettings {
        id: settingsDialog
    }

    onAppSettings: {
        settingsDialog.updateAndOpen()
    }

    onAppHelp: {
        appWindow.pushPage(Qt.resolvedUrl("AppHelp.qml"))
    }

    // Applies configuration from settings.graph_definitions
    //
    function setConfig()
    {
        // drop all image types in grapher
        grapher.dropAllImageTypes()

        // change to new directory
        if ( settings.track_connectd_service && !service.running)
            grapher.chdir( settings.workingdir_collectd_stopped )
        else
            grapher.chdir( settings.workingdir_collectd_running )

        // keep image cache for as long as the update period is. It cannot be very close to
        // the update time, since some of the time is used up for image generation and the time-stamp
        // of the image is set to the moment its ready.
        grapher.setImageCacheTimeout( settings.updates_period * 0.75 )

        for (var i in extraVariables)
            grapher.setExtraVariable( i, extraVariables[i] )

        // parse configuration taking into account generators and variables
        var tmps = grapher.setConfig( settings.graph_definitions )

        // console.log(tmps)
        try {
            graphConfig = JSON.parse( tmps )

            for (var prop in graphConfig.types)
                if ( graphConfig.types.hasOwnProperty(prop)) {
                    grapher.registerImageType( prop,
                                              JSON.stringify(graphConfig.types[prop]) )
                }

            gList.graphDefs = graphConfig.page
        }
        catch (e) {
            console.log("Error: " + e)
        }

        // update font sizes
        grapher.setFontSize( "TITLE", settings.graph_font_size_title )
        grapher.setFontSize( "AXIS", settings.graph_font_size_axis )
        grapher.setFontSize( "UNIT", settings.graph_font_size_unit )
        grapher.setFontSize( "LEGEND", settings.graph_font_size_legend )

        // update GUI
        popAll()
        pushPage(gList)
        updateGraphs()
        setCover()
    }

    // returns Callback IDs in sequence
    function getCallbackId() {
        nextId += 1
        return nextId
    }


    // Load new JSON graph description from URL
    onLoadNewConfig: {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if ( doc.readyState == XMLHttpRequest.DONE ) {

                var a = doc.responseText.split("\n")
                var res = ""
                for (var i=0; i < a.length; ++i)
                    res += a[i] + " "

                try {
                    var b = JSON.parse(res)

                    settings.graph_definitions = JSON.stringify(b)
                    setConfig()
                    settings.graph_last_used_url = url

                    appWindow.stateLoadingUrl = "Loading `done"
                }
                catch(e) {
                    appWindow.stateLoadingUrl = "Error while loading " + url + " : " + e
                }
            }
        }

        appWindow.stateLoadingUrl = "Loading configuration from: " + url

        doc.open("GET", url);
        doc.send();
    }

    onStateLoadingUrlChanged: {
        // console.log(appWindow.stateLoadingUrl)
    }

    Connections {
        target: grapher
        onReadyChanged: { stateRRDRunning = grapher.ready }
    }

    Connections {
        target: grapher
        onErrorRRDTool: {
            stateLastRRDError = "Last error from RRD: " + error_text.replace("\n", " / ") + " @ " + Date().toString()
        }
    }

    Connections {
        target: service
        onRunningChanged: {
            setConfig()
        }
    }
}
