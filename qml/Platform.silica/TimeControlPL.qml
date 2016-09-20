import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    allowedOrientations : Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: column
            spacing: Theme.paddingMedium
            width: parent.width

            PageHeader {
                title: qsTr("Time axis control")
            }

            SectionHeader {
                text: qsTr("Zoom")
            }

            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: "In"
                    //icon.source: "image://theme/icon-m-add"
                    onClicked: { appWindowBase.appZoomIn(); appWindow.popPage(); }
                }
                Button {
                    text: "Out"
                    //icon.source: "image://theme/icon-m-remove"
                    onClicked: { appWindowBase.appZoomOut(); appWindow.popPage(); }
                }
            }


            SectionHeader {
                text: qsTr("Shift")
            }
            Row {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    //icon.source: "image://theme/icon-m-left"
                    text: "Earlier"
                    onClicked: { appWindowBase.appTimeToHistory(); appWindow.popPage(); }
                }
                Button {
                    //icon.source: "image://theme/icon-m-right"
                    text: "Later"
                    onClicked: { appWindowBase.appTimeToFuture(); appWindow.popPage(); }
                }
            }
            Button {
                //icon.source: "image://theme/icon-m-next"
                text: "Now"
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthMedium
                onClicked: { appWindowBase.appTimeToNow(); appWindow.popPage(); }
            }

            Text { text: " " } // extra separator

            SectionHeader {
                text: qsTr("Time window duration")
            }

            ComboBox {
                id: maincombo

                property var timeWindows: [
                    {"value": 3600, "desc": qsTr("1 hour")},
                    {"value": 14400, "desc": qsTr("4 hours")},
                    {"value": 28800, "desc": qsTr("8 hours")},
                    {"value": 43200, "desc": qsTr("12 hours")},
                    {"value": 86400, "desc": qsTr("24 hours")},
                    {"value": 259200, "desc": qsTr("3 days")},
                    {"value": 604800, "desc": qsTr("1 week")},
                    {"value": 2419200, "desc": qsTr("4 weeks")},
                    {"value": 8640000, "desc": qsTr("100 days")},
                    {"value": 31536000, "desc": qsTr("1 year")}
                ]

                width: parent.width
                label: qsTr("Main graphs")
                currentIndex: -1

                menu: ContextMenu {
                    MenuItem { text: maincombo.timeWindows[0]["desc"] }
                    MenuItem { text: maincombo.timeWindows[1]["desc"] }
                    MenuItem { text: maincombo.timeWindows[2]["desc"] }
                    MenuItem { text: maincombo.timeWindows[3]["desc"] }
                    MenuItem { text: maincombo.timeWindows[4]["desc"] }
                    MenuItem { text: maincombo.timeWindows[5]["desc"] }
                    MenuItem { text: maincombo.timeWindows[6]["desc"] }
                    MenuItem { text: maincombo.timeWindows[7]["desc"] }
                    MenuItem { text: maincombo.timeWindows[8]["desc"] }
                    MenuItem { text: maincombo.timeWindows[9]["desc"] }
                }

                onCurrentIndexChanged: {
                    appWindowBase.appTimespan( timeWindows[currentIndex]["value"] )
                }

                Component.onCompleted: {
                    for (var i = 0; i < timeWindows.length; i++)
                        if ( Math.abs(timeWindows[i]["value"] - settings.timewindow_duration) < 1e-5 )
                        {
                            currentIndex = i
                            return
                        }
                }
            }

            ComboBox {
                id: covercombo

                property var timeWindows: [
                    {"value": 3600, "desc": qsTr("1 hour")},
                    {"value": 7200, "desc": qsTr("2 hours")},
                    {"value": 14400, "desc": qsTr("4 hours")},
                    {"value": 28800, "desc": qsTr("8 hours")}
                ]

                width: parent.width
                label: qsTr("Cover graphs")
                currentIndex: -1

                menu: ContextMenu {
                    MenuItem { text: covercombo.timeWindows[0]["desc"] }
                    MenuItem { text: covercombo.timeWindows[1]["desc"] }
                    MenuItem { text: covercombo.timeWindows[2]["desc"] }
                    MenuItem { text: covercombo.timeWindows[3]["desc"] }
                }

                onCurrentIndexChanged: {
                    appWindowBase.appCoverTimespan( timeWindows[currentIndex]["value"] )
                }

                Component.onCompleted: {
                    for (var i = 0; i < timeWindows.length; i++)
                        if ( Math.abs(timeWindows[i]["value"] - settings.cover_timewindow_duration) < 1e-5 )
                        {
                            currentIndex = i
                            return
                        }
                }
            }
        }
    }
}
