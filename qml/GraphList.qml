import QtQuick 2.0
import "Platform"

PagePL {

    property var graphDefs: []
    property string pageTitle: qsTr("Welcome")

    property int graphsModel: 1

    property var graphHeightCache: []

    Component {
        id: graphPlotDelegate

        Item {
            id: container

            anchors.left: parent.left
            anchors.right: parent.right
            height: image.myHeight + ((index == graphsModel-1)? mainList.pl_margin_bottom : 0)

            Image {
                id: image

                property int myCallbackId: -1
                property bool update_skipped_since_invisible: false
                property int myHeight: 0
                property int imageIndex: -1

                source: ""

                anchors.left: parent.left
                anchors.right: parent.right

                function askImage() {
                    // continue only if we are active
                    if ( appWindow.isActive() ) {
                        if (myCallbackId <= 0)
                            myCallbackId = appWindow.getCallbackId()

                        grapher.getImage(myCallbackId, graphDefs.plots[index].type, settings.timewindow_from, settings.timewindow_duration,
                                         Qt.size(width,settings.graph_base_height), false, imageIndex )
                    }
                }

                Connections {
                    target: appWindow
                    onUpdateGraphs: {
                        if ( visible ) image.askImage()
                        else image.update_skipped_since_invisible = true
                    }
                }

                Connections {
                    target: grapher
                    onNewImage: {
                        if (imageFor == image.myCallbackId)
                        {
                            console.log("Image received: ", imageFor, iIndex)
                            image.source = fname
                            image.imageIndex = iIndex

                            var sh = iRealSize.height
                            if (image.myHeight != sh)
                            {
                                console.log("Changing height " + imageFor + ": " + image.myHeight + " -> " + sh)
                                image.myHeight = sh
                                graphHeightCache[index] = sh
                            }

                            if (graphDefs.plots[index].subplots) indicator.visible = true
                            else indicator.visible = false

                            // ask for new image if the width doesn't match
                            if (iRealSize.width != width) {
                                console.log("onNI: " + graphDefs.plots[index].type + " width difference " + width + " " + iRealSize.width)
                                image.askImage()
                            }
                        }
                    }
                }

                onWidthChanged: {
                    if ( visible ) image.askImage()
                    else image.update_skipped_since_invisible = true
                }

                Component.onCompleted: {
                    if (graphHeightCache.length > index && graphHeightCache[index] != null)
                        image.myHeight = graphHeightCache[index]

                    image.askImage()
                }

                onVisibleChanged: {
                    if (visible && (update_skipped_since_invisible || sourceSize.width != width))
                    {
                        // console.log("onVC: " + graphDefs.plots[index].type + " " + width + " " + image.sourceSize.width)
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

            function goIn() {
                if ( graphDefs.plots[index].subplots )
                {
                    appWindow.pushPage( Qt.resolvedUrl("GraphList.qml"),
                                       { graphDefs: graphDefs.plots[index].subplots }
                                       )
                }
            }

            function goOut() { appWindow.popPage() }

            Keys.onReturnPressed: { goIn() }
            Keys.onRightPressed: { goIn() }

            Keys.onEscapePressed: { goOut() }
            Keys.onLeftPressed: { goOut() }

            Keys.onPressed: {
                if (event.key == Qt.Key_Home )
                    mainList.currentIndex = 0
                else if (event.key == Qt.Key_End )
                    mainList.currentIndex = graphsModel-1
                else if (event.key == Qt.Key_PageUp)
                    mainList.currentIndex = Math.max(mainList.currentIndex - 3, 0);
                else if (event.key == Qt.Key_PageDown)
                    mainList.currentIndex = Math.min(mainList.currentIndex + 3, graphsModel-1);
            }
        }
    }


    ListViewPL {
        id: mainList
        anchors.fill: parent
        model: graphsModel
        delegate: graphPlotDelegate
        header_text: pageTitle

        Component.onCompleted: {
            // console.log("Cache buffer old: " + cacheBuffer)

            // Allocate significant cacheBuffer (in pixels) to keep more off-page images intact
            // and avoid reloading them
            var ncache = 1600
            if (cacheBuffer < ncache) cacheBuffer = ncache
        }
    }

    // Fill model
    function fillModel() {
        if ( !graphDefs.title )
        {
            graphsModel = 0
            pageTitle = qsTr("Empty page with undefined title")
            return;
        }

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
