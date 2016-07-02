import QtQuick 2.0
import "Platform"

PagePL {

    property var graphDefs: []
    property string pageTitle: qsTr("Welcome")

    property int graphsModel: 1
    property bool showGraphs: false //true

    Component {
        id: graphPlotDelegate

        Item {
            id: container

            anchors.left: parent.left
            anchors.right: parent.right
            height: showGraphs ? image.height : helpMessage.height

            Image {
                id: image
                visible: showGraphs

                property int myCallbackId: -1
                property bool update_skipped_since_invisible: false

                source: ""

                anchors.left: parent.left
                anchors.right: parent.right

                function askImage() {
                    // continue only if we are active
                    if ( appWindow.isActive() && showGraphs ) {
                        if (myCallbackId <= 0)
                            myCallbackId = appWindow.getCallbackId()

                        grapher.getImage(myCallbackId, graphDefs.plots[index].type, settings.timewindow_from, settings.timewindow_duration,
                                         Qt.size(width,settings.graph_base_height), false )
                    }
                }

                Connections {
                    target: appWindow
                    onUpdateGraphs: {
                        if ( visible && showGraphs ) image.askImage()
                        else image.update_skipped_since_invisible = true
                    }
                }

                Connections {
                    target: grapher
                    onNewImage: {
                        if (imageFor == image.myCallbackId)
                        {
                            console.log("Image received: ", imageFor, fname)
                            image.source = fname

                            //                            var sh = image.sourceSize.height
                            //                            if (container.height != sh)
                            //                                container.height = sh

                            if (graphDefs.plots[index].subplots) indicator.visible = true
                            else indicator.visible = false
                        }
                    }
                }

                onWidthChanged: {
                    image.askImage()
                }

                // don't need it since height is already according to current image
                //                onHeightChanged: {
                //                    image.askImage()
                //                }

                Component.onCompleted: {
                    if (showGraphs)
                        image.askImage()
                }

                onVisibleChanged: {
                    if (visible && update_skipped_since_invisible)
                    {
                        update_skipped_since_invisible = false
                        image.askImage()
                    }
                }
            }

            IndicatorPL {
                id: indicator
                anchors.verticalCenter: image.verticalCenter
                anchors.right: image.right
                visible: false
            }

            HelpText {
                id: helpMessage
                asHelp: false
                anchors.left: parent.left
                anchors.right: parent.right
                visible: !showGraphs
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (!showGraphs) return

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


            Keys.onReturnPressed: {
                if ( graphDefs.plots[index].subplots )
                {
                    appWindow.pushPage( Qt.resolvedUrl("GraphList.qml"),
                                       { graphDefs: graphDefs.plots[index].subplots }
                                       )
                }
            }

            Keys.onEscapePressed: { appWindow.popPage() }
        }
    }


    ListViewPL {
        id: mainList
        anchors.fill: parent
        model: graphsModel
        delegate: graphPlotDelegate
        header_text: pageTitle
    }

    // Fill model
    function fillModel() {
        if ( !graphDefs.title )
        {
            showGraphs = false
            graphsModel = 1
            return;
        }

        pageTitle = graphDefs.title
        graphsModel = graphDefs.plots.length

        if (graphsModel > 0) showGraphs = true
        else showGraphs = false
    }

    onGraphDefsChanged: {
        fillModel()
    }

    Component.onCompleted: {
        fillModel()
    }
}
