import QtQuick 2.0
import "Platform"

StatusPL {

    Component.onCompleted: {
        service.updateState()
        stat = "<b>collectd:</b> " + (service.running ? "Running" : "Stopped") + " / " +
                (service.enabled ? "Enabled on boot" : "Will not start on boot") +
                "<br><br>";

        if (settings.track_connectd_service)
        {
            stat += "<b>collectd status:</b><br><small>"
            var s = service.status
            s = s.replace(/\n/g, "<br>")
            s = s.replace(/ /g, "&nbsp;")
            stat += s
            stat += "</small><br><br>";
        }

        stat += "<b>RRDtool:</b> " + (appWindow.stateRRDRunning ? "Running" : "Stopped") + "<br><br>" +

                "<b>Last state of the loading URL:</b> " + stateLoadingUrl + "<br><br>" +

                "<b>Last RRDtool error:</b> " + stateLastRRDError + "<br><br>" +

                qsTr("<b>Use " + programName + " to enable/disable collectd:</b> ") + settings.track_connectd_service + "<br><br>"

        stat += qsTr("<b>Folder with the collectd databases while running:</b> ") + settings.workingdir_collectd_running +
                " : check result : " + configurator.isDirectoryOK(settings.workingdir_collectd_running,
                                                                  !settings.track_connectd_service || service.running) + "<br><br>"

        if (settings.track_connectd_service)
            stat += qsTr("<b>Folder with the collectd databases while the daemon is stopped:</b> ") +
                    settings.workingdir_collectd_stopped +
                    " : check result : " + configurator.isDirectoryOK(settings.workingdir_collectd_stopped,
                                                                      !service.running) + "<br>"

        if (appWindow.graphConfig && appWindow.graphConfig.page) {
            stat += "<br><b>Loaded configuration:</b><br><br><small>" + appWindow.config2str("", appWindow.graphConfig.page)
            stat += "<br>N/A corresponds to the non-available plot (RRD file is missing, for example)<br></small>"
        }
        else
            stat += "<br><b>No active configuration defined.</b> Please generate the configuration of the graphs.</br>"

    }
}

