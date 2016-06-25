import QtQuick 2.0
import "Platform"

PagePL {

    property var graphDefs: []
    property string pageTitle: qsTr("Undefined")

    property int graphsModel: 0

    Component {
        id: graphPlotDelegate

        Image {
            id: image

            property int myCallbackId: -1
            //property string image_fname: ""
            property bool update_skipped_since_invisible: false

            source: "" //image_fname

            anchors.left: parent.left
            anchors.right: parent.right

            function askImage() {
                // continue only if we are active
                if ( appWindow.isActive() ) {
                    if (myCallbackId <= 0)
                        myCallbackId = appWindow.getCallbackId()

                    grapher.getImage(myCallbackId, graphDefs.plots[index].type, settings.timewindow_from, settings.timewindow_duration,
                                     Qt.size(width,settings.graph_base_height), false )
                }
            }

            Connections {
                target: appWindow
                onUpdateGraphs: {
                    if ( visible ) askImage()
                    else image.update_skipped_since_invisible = true
                }
            }

            Connections {
                target: grapher
                onNewImage: {
                    if (imageFor == image.myCallbackId)
                    {
                        console.log("Image received: ", imageFor, fname)
                        source = fname
                    }
                }
            }

            onWidthChanged: {
                askImage()
            }

            onHeightChanged: {
                askImage()
            }

            Component.onCompleted: {
                askImage()
            }

            onVisibleChanged: {
                if (visible && update_skipped_since_invisible)
                {
                    update_skipped_since_invisible = false
                    askImage()
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.LeftButton && graphDefs.plots[index].subplots)
                    {
                        appWindow.pushPage( Qt.resolvedUrl("GraphList.qml"),
                                           { graphDefs: graphDefs.plots[index].subplots }
                                           )
                        return
                    }

                    if (mouse.button == Qt.RightButton)
                    {
                        appWindow.popPage()
                    }
                }
            }
        }
    }


    ListViewPL {
        anchors.fill: parent
        model: graphsModel
        delegate: graphPlotDelegate
        header_text: pageTitle

        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        focus: true
        clip: true
    }

    // Fill model
    function fillModel() {
        if ( !graphDefs.title ) return;

        pageTitle = graphDefs.title
        graphsModel = graphDefs.plots.length
    }

    onGraphDefsChanged: {
        fillModel()
    }
    Component.onCompleted: {
        fillModel()
    }
}
