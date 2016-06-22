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
            property string image_fname: ""
            property bool update_skipped_since_invisible: false

            source: image_fname

            anchors.left: parent.left
            anchors.right: parent.right

            function askImage() {
                grapher.getImage(image, graphDefs.plots[index].type, settings.timewindow_from, settings.timewindow_duration,
                                 Qt.size(width,settings.graph_base_height), false )
            }

            Connections {
                target: appWindow
                onUpdateGraphs: {
                    if ( visible ) askImage()
                    else image.update_skipped_since_invisible = true
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


    FlickablePL {
        anchors.fill: parent

        ListViewPL {
            anchors.fill: parent
            model: graphsModel
            delegate: graphPlotDelegate
            header_text: pageTitle

//            header: PageHeader {
//                text: pageTitle
//                menu : TopMenu {
//                            MenuItem {
//                                text : "option 1"
//                                onClicked : {console.log("1 clicked!")}
//                            }
//                            MenuItem {
//                                text : "option 2"
//                                onClicked : {console.log("2 clicked!")}
//                            }
//                        }
//            }
        }
    }

    // Fill model
    function fillModel() {
        if ( !graphDefs.title ) return;

        pageTitle = graphDefs.title

        graphsModel = graphDefs.plots.length
//        for (var i=0; i < graphDefs.plots.length; i++)
//        {
//            var o = graphDefs.plots[i]
//            console.log(i + " " + JSON.stringify(o))
//            graphsModel.append({command: o.command, type: o.type})
//        }
    }

    onGraphDefsChanged: {
        fillModel()
    }
    Component.onCompleted: {
        fillModel()
    }
}
