import QtQuick 2.0
import "Platform"

TextPL {

    property bool asHelp: true

    text: qsTr("
<h1>Welcome to " + programName + "</h1>" +

( asHelp ? "" : "
<p>It seems that you are
running non-configured GUI or, for some reason, with an empty
configuration on this level.</p>" ) + "

<p>This is a short HOWTO to get you started.
On Desktop, press Esc or the right mouse button to get out of this HOWTO.
On Sailfish, swipe the page back, as usual.</p>

<h2>Very short version</h2>

<p>For those who are just checking out and/or are trusting the default settings:</p>

<ol>
<li>Go to Settings, select <i>Use " + programName + " to enable/disable collectd</i>.</li>
<li>In Settings, select <i>Run collectd</i> and, if you wish, <i>Enable collectd on boot</i>.
Note that when you select Run, GUI may revert back Help screen or graph list.</li>
<li>Close GUI and wait for 10 minutes. You can close it after 10 minutes, but GUI restart is needed.</li>
<li>Start the GUI and check if a directory corresponding to running collectd passed a check in Status.</li>
<li>Go to Settings, scroll down, and push the button to <i>Generate definitions</i>.</li>
</ol>

<p>If it all worked, you are all set and can proceed monitoring your system. To see the generated outline of graphs
and other info regarding GUI, go to Status (Sailfish only at present). In Status, you could also copy the state to
clipboard via pulley menu.  If you wish to know more, something failed, or you want to
tune it, read on. </p>

<p>Below, is more detailed HOWTO</p>

<h2>Start <i>collectd</i></h2>

<p>If you have not started <i>collectd</i>, then you have to start it. This GUI supports systemd and you could use it for starting/stopping and
enabling collectd on boot.</p>

<h3>collectd configuration</h3>

<p>Before starting collectd, check its configuration. Its usually
located at /etc/collectd.conf. Frequently, reasonable defaults
are used. However, you may want to specify enabled plugins and
check their settings.</p>

<h3>Using " + programName + " to track collectd</h3>

<p>This GUI allows you to start/stop collectd as a user running
the GUI. For that, go to Settings (either menu on the top or a button on
the top) and choose 'Use this program to enable/disable
collectd'. Then press 'Run collectd' and, if you wish, 'Enable
collectd on boot'. </p>

<h3>Using INIT to run collectd</h3>

<p>If you don't use systemd or want to run collectd as root or
other user, please use your INIT system commands to start
collectd. Note that in this case, disable in " + programName + "
settings 'use this program to enable/disable collectd'.  You
would have to specify then only one directory containing collectd
datasets.</p>

<h3>After starting collectd</h3>

<p>Let collectd run a bit to start collecting data. In Sailfish,
default time interval is 2 minutes 30 seconds, so take that into
account as well. You would need some data before you would be
able to generate configuration files for this GUI.</p>


<h2>Configuring GUI</h2>

<p>Presented graphs are all described in GUI
configuration. Configuration is given in JSON format that
includes description of RRDtool commands, names of the pages, and
how the graphs are organized in a tree. There are several ways to
get configuration. </p>

<h3>Setting directory to read data from</h3>

<p>Before proceeding with the configuration, specify the
directory where the collectd keeps its datasets. If tracking
collectd state by GUI, you have to specify 2 directories with one
of them corresponding to the case when collectd is running and
the second one to read data from when collectd is stopped. The
directories would depend on your collectd configuration.</p>

<p>In Sailfish, the GUI may be able to detect the directories
automatically. If you just started collectd, try to close the GUI
and start it again. The directories are checked on the startup
and should be filled (at least the running one) if collectd
runs. The second directory (on collectd stopped) would get filled
when collectd has been stopped earlier. </p>

<p>After setting directory(ies), go to Status to see if the directory(ies)
are passing the check. If you just started, you are mainly interested in the
directory that corresponds to current <i>collectd</i> state (running or stopped).</p>


<h3>Configuration loading by GUI</h3>

<p>Note that when configuration is changed by loading a new one in
Settings or some graph parameters are changed (sizes,...) in
Settings, the whole configuration is reloaded. As a part of a
loading process, configuration is checked against available RRD
files. For example, if a graph requires load/load.rrd and this
file is unavailable, the corresponding graph will not be
shown. If the file appeared later, you would have to reload
configuration to get it detected.</p>

<p>At any stage, you could check the configuration under Status.</p>

<h3>Make configuration from GUI</h3>

<p>Go to Settings and press the button Generate configuration. The configuration
script will be run by GUI and configuration loaded from it. If it works, you are all
set.</p>

<h3>Make configuration using a helper script and command line</h3>

<p>The helper script requires python2.7, which should be installed as dependency in Sailfish .</p>

<p>Get the helper script from the GUI source tree in GitHub:
<a href=https://github.com/rinigus/systemdatascope/blob/master/tools/systemdatascope-makeconfig>
https://github.com/rinigus/systemdatascope/blob/master/tools/systemdatascope-makeconfig.py
</a> . In Sailfish, the script is installed as a part of a RPM package. </p>

<p>Run script:</p>

<p><tt>systemdatascope-makeconfig /tmp/collectd/Jolla > myconf.json </tt></p>

<p>where the first argument is the directory with collectd
datasets. Check the configuration by looking into the generated
file. To load it, go to Settings and, at the bottom of the
Settings, insert location of configuration as URL:</p>

<p>file:///home/nemo/myconf.json</p>

<p>The URL will be loaded after you press Load button. Note that
if the loading was successful, URL will stay in settings and you
could easily update configuration by script or editor and then
reload it again in Settings.</p>


<h3>Load default configuration from Internet</h3>

<p>Some configurations would be provided online. At present, there
is a configuration for Nexus 4 running Sailfish at GitHub in GUI
source tree under configs:
<a href=https://github.com/rinigus/systemdatascope/blob/master/configs/sfos-n4.json>
https://github.com/rinigus/systemdatascope/blob/master/configs/sfos-n4.json</a></p>

<p>To load the configuration given online, insert URL in Settings
and press Load button. Loading is performed using QML
XMLHttpRequest.</p>

<p>If you want to share your configuration, send it as a pull
request in GitHub or open an issue with it.</p>


<h3>Manual configuration</h3>

<p>The configuration file can be written manually. See default
configuration in the GitHub source tree as an example. Note that
all variables defined in <i>variables</i> section of JSON would
be replaced by their values in RRD commands specified under
<i>types</i>.</p>

<h2>Help</h2>

<p>This help text is available under Help menu (or Button), depending on your platform.</p>

<p> </p>

"
)
}
