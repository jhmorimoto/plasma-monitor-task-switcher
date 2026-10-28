import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kwin as KWin
import org.kde.kirigami as Kirigami

KWin.TabBoxSwitcher {
    id: tabBox

    Instantiator {
        active: tabBox.visible
        delegate: PlasmaCore.Dialog {
            location: PlasmaCore.Types.Floating
            visible: true
            flags: Qt.Popup | Qt.X11BypassWindowManagerHint
            x: tabBox.screenGeometry.x + (tabBox.screenGeometry.width - dialogContent.width) / 2
            y: tabBox.screenGeometry.y + (tabBox.screenGeometry.height - dialogContent.height) / 2

            mainItem: FocusScope {
                id: dialogContent
                focus: true
                property var outputs: []
                readonly property int columns: 4
                readonly property int groupSpacing: Kirigami.Units.largeSpacing
                readonly property int groupWidth: columns * 150 + (columns + 1) * groupSpacing
                width: Math.min(tabBox.screenGeometry.width * 0.9,
                                Math.max(groupWidth + 2 * groupSpacing,
                                         outputs.length * (groupWidth + groupSpacing) + groupSpacing))
                height: Math.min(tabBox.screenGeometry.height * 0.45, 320)

                Component.onCompleted: {
                    const screens = Array.from(KWin.Workspace.screens || []);
                    screens.sort((left, right) => left.geometry.y - right.geometry.y ||
                                               left.geometry.x - right.geometry.x);
                    outputs = screens;
                    Qt.callLater(() => dialogContent.ensureSelectionVisible());
                }

                function selectedTile() {
                    for (let screenIndex = 0; screenIndex < screenRepeater.count; ++screenIndex) {
                        const group = screenRepeater.itemAt(screenIndex);
                        const tile = group?.tiles.itemAt(tabBox.currentIndex);
                        if (tile?.visible) {
                            return { group: group, tile: tile };
                        }
                    }
                    return null;
                }

                function ensureSelectionVisible() {
                    const selection = dialogContent.selectedTile();
                    if (!selection) {
                        return;
                    }
                    const group = selection.group;
                    const tile = selection.tile;
                    const groupX = group.mapToItem(monitorRow, 0, 0).x;
                    monitorStrip.contentX = Math.max(0, Math.min(monitorStrip.contentWidth - monitorStrip.width,
                        Math.max(groupX + group.width - monitorStrip.width,
                                 Math.min(monitorStrip.contentX, groupX))));
                    const tileY = tile.mapToItem(group.windowFlow, 0, 0).y;
                    group.viewport.contentY = Math.max(0, Math.min(group.viewport.contentHeight - group.viewport.height,
                        Math.max(tileY + tile.height - group.viewport.height,
                                 Math.min(group.viewport.contentY, tileY))));
                }

                function moveSelection(key) {
                    const selected = dialogContent.selectedTile();
                    let bestIndex = -1;
                    let bestDistance = Infinity;
                    const origin = selected?.tile.mapToItem(dialogContent,
                        selected.tile.width / 2, selected.tile.height / 2);

                    for (let screenIndex = 0; screenIndex < screenRepeater.count; ++screenIndex) {
                        const group = screenRepeater.itemAt(screenIndex);
                        for (let windowIndex = 0; windowIndex < group.tiles.count; ++windowIndex) {
                            const tile = group.tiles.itemAt(windowIndex);
                            if (!tile?.visible || windowIndex === tabBox.currentIndex) {
                                continue;
                            }
                            if (!origin) {
                                tabBox.currentIndex = windowIndex;
                                return;
                            }
                            const point = tile.mapToItem(dialogContent, tile.width / 2, tile.height / 2);
                            const dx = point.x - origin.x;
                            const dy = point.y - origin.y;
                            const forward = key === Qt.Key_Right ? dx : key === Qt.Key_Left ? -dx :
                                            key === Qt.Key_Down ? dy : -dy;
                            if (forward <= 0) {
                                continue;
                            }
                            const lateral = key === Qt.Key_Left || key === Qt.Key_Right ? dy : dx;
                            const distance = forward + 2 * Math.abs(lateral);
                            if (distance < bestDistance) {
                                bestDistance = distance;
                                bestIndex = windowIndex;
                            }
                        }
                    }
                    if (bestIndex >= 0) {
                        tabBox.currentIndex = bestIndex;
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Right ||
                        event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                        moveSelection(event.key);
                        event.accepted = true;
                    }
                }

                Connections {
                    target: tabBox
                    function onCurrentIndexChanged() {
                        Qt.callLater(() => dialogContent.ensureSelectionVisible());
                    }
                }

                Flickable {
                    id: monitorStrip
                    anchors.fill: parent
                    anchors.margins: dialogContent.groupSpacing
                    clip: true
                    contentWidth: monitorRow.implicitWidth
                    contentHeight: height
                    flickableDirection: Flickable.HorizontalFlick

                    Row {
                        id: monitorRow
                        spacing: dialogContent.groupSpacing

                        Repeater {
                            id: screenRepeater
                            model: dialogContent.outputs

                            delegate: Item {
                                id: monitorGroup
                                required property var modelData
                                readonly property var output: modelData
                                property alias tiles: windowRepeater
                                property alias viewport: windowViewport
                                property alias windowFlow: tileFlow
                                readonly property int windowCount: {
                                    let total = 0;
                                    for (let windowIndex = 0; windowIndex < windowRepeater.count; ++windowIndex) {
                                        if (windowRepeater.itemAt(windowIndex)?.visible) {
                                            ++total;
                                        }
                                    }
                                    return total;
                                }
                                width: dialogContent.groupWidth
                                height: monitorStrip.height

                                Rectangle {
                                    anchors.fill: parent
                                    radius: Kirigami.Units.cornerRadius
                                    color: Kirigami.Theme.backgroundColor
                                    border.color: Kirigami.Theme.disabledTextColor
                                }

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: Kirigami.Units.largeSpacing
                                    spacing: Kirigami.Units.largeSpacing

                                    PlasmaComponents3.Label {
                                        id: heading
                                        width: parent.width
                                        text: monitorGroup.output.name
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Flickable {
                                        id: windowViewport
                                        width: parent.width
                                        height: parent.height - heading.height - parent.spacing
                                        clip: true
                                        contentWidth: width
                                        contentHeight: Math.max(height, tileFlow.implicitHeight)
                                        flickableDirection: Flickable.VerticalFlick

                                        Grid {
                                            id: tileFlow
                                            width: windowViewport.width
                                            height: implicitHeight
                                            columns: dialogContent.columns
                                            rowSpacing: Kirigami.Units.largeSpacing
                                            columnSpacing: Kirigami.Units.largeSpacing

                                            Repeater {
                                                id: windowRepeater
                                                model: tabBox.model

                                                delegate: MouseArea {
                                                    id: tile
                                                    readonly property var clientWindow: {
                                                        const windows = KWin.Workspace?.stackingOrder || [];
                                                        return windows.find(window => window.internalId === windowId) || null;
                                                    }
                                                    visible: clientWindow?.output?.name === monitorGroup.output.name
                                                    width: 150
                                                    height: 116
                                                    hoverEnabled: true
                                                    Accessible.name: model.caption
                                                    Accessible.role: Accessible.ListItem
                                                    onClicked: tabBox.model.activate(index)

                                                    Rectangle {
                                                        anchors.fill: parent
                                                        radius: Kirigami.Units.cornerRadius
                                                        color: tile.containsMouse ? Kirigami.Theme.hoverColor : Kirigami.Theme.backgroundColor
                                                        border.width: index === tabBox.currentIndex ? 2 : 1
                                                        border.color: index === tabBox.currentIndex ?
                                                            Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                                                    }

                                                    Item {
                                                        id: preview
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                        anchors.top: parent.top
                                                        anchors.margins: Kirigami.Units.smallSpacing
                                                        height: 82

                                                        Loader {
                                                            anchors.fill: parent
                                                            active: tile.visible
                                                            sourceComponent: KWin.WindowThumbnail {
                                                                wId: windowId
                                                            }
                                                        }

                                                        Kirigami.Icon {
                                                            width: 24
                                                            height: 24
                                                            anchors.left: parent.left
                                                            anchors.bottom: parent.bottom
                                                            source: model.icon
                                                        }
                                                    }

                                                    PlasmaComponents3.Label {
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                        anchors.bottom: parent.bottom
                                                        anchors.margins: Kirigami.Units.smallSpacing
                                                        text: model.caption
                                                        textFormat: Text.PlainText
                                                        elide: Text.ElideRight
                                                    }

                                                    PlasmaComponents3.Button {
                                                        anchors.right: parent.right
                                                        anchors.top: parent.top
                                                        visible: model.closeable && tile.containsMouse &&
                                                                 typeof tabBox.model.close !== "undefined"
                                                        icon.name: "window-close-symbolic"
                                                        onClicked: tabBox.model.close(index)
                                                    }
                                                }
                                            }
                                        }

                                        PlasmaComponents3.Label {
                                            anchors.centerIn: parent
                                            visible: monitorGroup.windowCount === 0
                                            text: "Nenhuma janela"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            onSceneGraphError: () => {}
        }
    }
}