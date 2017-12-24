import QtQuick 2.0
import "Platform"

MessageAboutPL {

    mainText: "<p>" + programName + " reads the system performance data gathered by <i>collectd</i>. Graphs are generated using RRDTOOL</p><br>" +
              "Source code at: <br> <a href='https://github.com/rinigus/systemdatascope'>https://github.com/rinigus/systemdatascope</a><br><br>" +
              "<p>GUI Copyright: 2016-2018 <br>rinigus http://github.com/rinigus<br></p>" +
              "License: MIT<br><br>" +
              "Donations: <a href='https://liberapay.com/rinigus'>https://liberapay.com/rinigus</a>" + "<br><br>" +
              "<b>Used software and Acknowledgments:</b><br><br>" +
              "collectd: <a href='https://collectd.org'>https://collectd.org</a><br>" +
              "RRDTOOL: <a href='http://oss.oetiker.ch/rrdtool'>http://oss.oetiker.ch/rrdtool</a><br><br>" +
              "Cross-platform approach similar to Universal Components <br>" +
              "<a href='https://github.com/M4rtinK/universal-components'>https://github.com/M4rtinK/universal-components</a>"

}
