# SystemDataScope
SystemDataScope is a GUI for visualization of collectd datasets

SystemDataScope reads the system performance data gathered by <i>collectd</i>. Graphs are generated using RRDtool and shown through provided GUI. If collectd is started by a GUI user through systemd, there is a support for starting/stopping the daemon.

SystemDataScope is build to support multiple different log configurations. The configuration is setup through JSON file that can be specified by user and downloaded from URL (local or remote). This should facilitate development of the graph generation scripts that are tailored for specific user setups.

The current implementation is developed on Linux Desktops and Sailfish OS mobile devices. More platforms should be supported immediately or possible to add relatively simply, as long as QML/Qt is supported.

## Current status

The program works in Linux Desktop. Linux Desktop requires further polishing, but its not the priority at the moment.

In Sailfish OS, program works and requires polishing.

RRDtool sets of commands for different readouts are missing. There is no default configuration given leading to an empty interface at the start. 

My current development will focus on polishing Sailfish OS interface and generation of graph configurations. In addition, this README will be expanded as the development progresses.

## To develop

Everyone are welcome to join. As mentioned, RRDtool commands for graph generation are missing. Linux desktop/Sailfish interface both require polishing.

For developing interface, please choose PRO(ject) file that corresponds to the platform you want to develop for. Before loading PRO file into Qt Creator, make a symbolic link qml/Platform that points to corresponding platform specification (qml/Platform.silica or qml/Platform.qtcontrols, for example). Try to separate program logic from some specific platform GUI and position the code either in cross-platform (qml or src) or Platform sections, respectively.
