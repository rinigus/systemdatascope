import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    allowedOrientations : Orientation.All

    SilicaListView{
        anchors.fill: parent

        header: Column {
            width: parent.width
            height: header.height + Theme.paddingLarge    // add space between button and first list item

            PageHeader {
                id: header
                title: qsTr("Time axis control")
            }
        }

        model: ListModel {

            ListElement { item_text: "Zoom In" }
            ListElement { item_text: "Zoom Out" }
            ListElement { item_text: "Go to Now" }
            ListElement { item_text: "Go to earlier time" }
            ListElement { item_text: "Go to later time" }
            ListElement { item_text: "Time window: 1 hour"; timewindow: 3600 }
            ListElement { item_text: "Time window: 4 hours"; timewindow: 14400 }
            ListElement { item_text: "Time window: 8 hours"; timewindow: 28800 }
            ListElement { item_text: "Time window: 12 hours"; timewindow: 43200 }
            ListElement { item_text: "Time window: 24 hours"; timewindow: 86400 }
            ListElement { item_text: "Time window: 3 days"; timewindow: 259200 }
            ListElement { item_text: "Time window: 1 week"; timewindow: 604800 }
            ListElement { item_text: "Time window: 4 weeks"; timewindow: 2419200 }
            ListElement { item_text: "Time window: 100 days"; timewindow: 8640000 }
            ListElement { item_text: "Cover time window: 1 hour"; timewindow: 3600 }
            ListElement { item_text: "Cover time window: 2 hours"; timewindow: 7200 }
            ListElement { item_text: "Cover time window: 4 hours"; timewindow: 14400 }
            ListElement { item_text: "Cover time window: 8 hours"; timewindow: 28800 }
        }

        delegate: ListItem {
            width: ListView.view.width-2*x
            height: Theme.itemSizeSmall
            x: Theme.horizontalPageMargin
            Label { text: item_text }
            onClicked: {

                if (item_text == "Zoom In") appWindowBase.appZoomIn();
                else if (item_text == "Zoom Out") appWindowBase.appZoomOut();
                else if (item_text == "Go to Now") appWindowBase.appTimeToNow();
                else if (item_text == "Go to earlier time") appWindowBase.appTimeToHistory();
                else if (item_text == "Go to later time") appWindowBase.appTimeToFuture();
                else if (item_text.indexOf("Cover time window:") > -1) appWindowBase.appCoverTimespan(timewindow);
                else if (item_text.indexOf("Time window:") > -1) appWindowBase.appTimespan(timewindow);
                else console.log("Unknown Time control selection: " + item_text)

                appWindow.popPage()
            }
        }

        VerticalScrollDecorator {}

    }

}

