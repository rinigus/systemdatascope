import QtQuick 2.0
import "Platform"

MessageAboutPL {

    mainText: "<p>" + programName + " reads the system performance data gathered by <i>collectd</i>. Graphs are generated using RRDTOOL</p><br>" +
              "<p>GUI source code at: <br> <a href=http://github.com/rinigus>http://github.com/rinigus</a></p><br>" +
              "<p>GUI Copyright: 2016, 2017 <br>rinigus rinigus.git@gmail.com<br></p>" +
              "License: MIT<br><br>" +
              "Donations: <a href='https://liberapay.com/rinigus'>https://liberapay.com/rinigus</a>" + "<br><br>" +
              "<b>Used software and Acknowledgments:</b><br><br>" +
              "collectd: https://collectd.org <br>" +
              "RRDTOOL: http://oss.oetiker.ch/rrdtool/<br><br>" +
              "Cross-platform approach similar to Universal Components <br>https://github.com/M4rtinK/universal-components"

}
