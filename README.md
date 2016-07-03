# SystemDataScope
SystemDataScope is a GUI for visualization of collectd datasets

SystemDataScope reads the system performance data gathered by <i>collectd</i>. Graphs are generated using RRDtool and shown through provided GUI. If collectd is started by a GUI user through systemd, there is a support for starting/stopping the daemon.

SystemDataScope is build to support multiple different log configurations. The configuration is setup through JSON file that can be specified by user and downloaded from URL (local or remote). This should facilitate development of the graph generation scripts that are tailored for specific user setups.

The current implementation is developed on Linux Desktops and Sailfish OS mobile devices. More platforms should be supported immediately or possible to add relatively simply, as long as QML/Qt is supported.

The interface is revolving around stacked pages. User, after configuration, is presented with the top page and its possible to get into the details of the collected stats by pressing into the corresponding graph. The number of levels and connections between them are described by user-provided configuration. 

In Linux desktop, navigation is supported as follows. By mouse: left button selects the stats to be looked into, the right button goes back one level on page stack. By keyboard: arrow keys to go up/down list, Return to select the stats to be looked into, Esc to go back one level. The program options are shown through the buttons in a toolbar. Status messages are below the graphs, on the bottom of the window.

In Sailfish, navigation works by touching the stats image (looking details of the stats) and swiping whole page to get back one level. Use top-level menu to get to the options.

In all environments, configuration can be loaded under Settings.

## Current status

The program works in Linux Desktop and Sailfish OS. An example configuration is given in configs/sfos-n4.json file and has to be loaded by the user. For example, URL https://raw.githubusercontent.com/rinigus/systemdatascope/master/configs/sfos-n4.json can be used.

The default configuration is provided for Nexus 4 phone running Sailfish.

One can generate configuration by provided Python script (tools/makeconfig.py) or manually. Note that the configuration format allows variables expansion. For expansion to work, define variable in "variables" property of JSON object and use it in graph type definitions in the form $VARIABLE_NAME$. This allows to specify font sizes through GUI, for example.

## Screenshots

See https://github.com/rinigus/systemdatascope/tree/master/screenshots for screenshots


## Development

Everyone are welcome to join. RRDtool commands for graph generation are not complete. Linux desktop/Sailfish interface both require polishing. Current issues are listed under "Issues" in GitHub. If you have found a bug or have a suggestion, submit it as a new issue.

For developing interface, please choose PRO(ject) file that corresponds to the platform you want to develop for. Before loading PRO file into Qt Creator, make a symbolic link qml/Platform that points to corresponding platform specification (qml/Platform.silica or qml/Platform.qtcontrols, for example). Try to separate program logic from some specific platform GUI and position the code either in cross-platform (qml or src) or Platform sections, respectively.


## Used software and Acknowledgments

* collectd: https://collectd.org

* RRDtool: http://oss.oetiker.ch/rrdtool

Cross-platform approach similar to Universal Components https://github.com/M4rtinK/universal-components
