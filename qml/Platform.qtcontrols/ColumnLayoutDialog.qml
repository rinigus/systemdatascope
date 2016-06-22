// http://stackoverflow.com/questions/30735562/qml-dialog-is-broken

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

// A Dialog that resizes properly. The defualt dialog doesn't work very well for this purpose.
AbstractDialog {
    id: root
    default property alias data: defaultContentItem.data
    onVisibilityChanged: if (visible && contentItem) contentItem.forceActiveFocus()

    Rectangle {
        id: content
        property real spacing: 6
        property real outerSpacing: 12
        property real buttonsRowImplicitWidth: minimumWidth
        property bool buttonsInSingleRow: defaultContentItem.width >= buttonsRowImplicitWidth
        property real minimumHeight: implicitHeight
        property real minimumWidth: implicitWidth // Don't hard-code this.
        implicitWidth: Math.min(root.__maximumDimension, Math.max(Screen.pixelDensity * 10, mainLayout.implicitWidth + outerSpacing * 2))
        implicitHeight: Math.min(root.__maximumDimension, Math.max(Screen.pixelDensity * 10, mainLayout.implicitHeight + outerSpacing * 2))
        color: palette.window
        Keys.onPressed: {
            event.accepted = true
            switch (event.key) {
                case Qt.Key_Escape:
                case Qt.Key_Back:
                    reject()
                    break
                case Qt.Key_Enter:
                case Qt.Key_Return:
                    accept()
                    break
                default:
                    event.accepted = false
            }
        }

        SystemPalette { id: palette }

        onMinimumHeightChanged: {
            if (root.height < content.minimumHeight)
                root.height = content.minimumHeight;
        }
        onMinimumWidthChanged: {
            if (root.width < content.minimumWidth)
                root.width = content.minimumWidth;
        }

        // We use layouts rather than anchors because there are no minimum widths/heights
        // with the anchor system.
        ColumnLayout {
            id: mainLayout
            anchors { fill: parent; margins: content.outerSpacing }
            spacing: content.spacing

            // We have to embed another item so that children don't go after the buttons.
            ColumnLayout {
                id: defaultContentItem
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Flow {
                Layout.fillWidth: true

                id: buttonsLeft
                spacing: content.spacing

                Repeater {
                    id: buttonsLeftRepeater
                    Button {
                        text: (buttonsLeftRepeater.model && buttonsLeftRepeater.model[index] ? buttonsLeftRepeater.model[index].text : index)
                        onClicked: root.click(buttonsLeftRepeater.model[index].standardButton)
                    }
                }

                Button {
                    id: moreButton
                    text: qsTr("Show Details...")
                    visible: false
                }
            }

            Flow {
                Layout.fillWidth: true

                id: buttonsRight
                spacing: content.spacing
                layoutDirection: Qt.RightToLeft

                Repeater {
                    id: buttonsRightRepeater
                    // TODO maybe: insert gaps if the button requires it (destructive buttons only)
                    Button {
                        text: (buttonsRightRepeater.model && buttonsRightRepeater.model[index] ? buttonsRightRepeater.model[index].text : index)
                        onClicked: root.click(buttonsRightRepeater.model[index].standardButton)
                    }
                }
            }
        }
    }
    function setupButtons() {
        buttonsLeftRepeater.model = root.__standardButtonsLeftModel()
        buttonsRightRepeater.model = root.__standardButtonsRightModel()
        if (!buttonsRightRepeater.model || buttonsRightRepeater.model.length < 2)
            return;
        var calcWidth = 0;

        function calculateForButton(i, b) {
            var buttonWidth = b.implicitWidth;
            if (buttonWidth > 0) {
                if (i > 0)
                    buttonWidth += content.spacing
                calcWidth += buttonWidth
            }
        }

        for (var i = 0; i < buttonsRight.visibleChildren.length; ++i)
            calculateForButton(i, buttonsRight.visibleChildren[i])
        content.minimumWidth = calcWidth + content.outerSpacing * 2
        for (i = 0; i < buttonsLeft.visibleChildren.length; ++i)
            calculateForButton(i, buttonsLeft.visibleChildren[i])
        content.buttonsRowImplicitWidth = calcWidth + content.spacing
    }
    onStandardButtonsChanged: setupButtons()
    Component.onCompleted: setupButtons()
}
