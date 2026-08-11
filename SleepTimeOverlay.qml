import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common
import qs.Widgets

Item {
    id: rootOverlay
    property var pluginRoot

    property string wakeupText: {
        if (!pluginRoot) return "";
        const h = pluginRoot.endHour;
        const m = pluginRoot.endMinute;
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
    }

    Repeater {
        model: Quickshell.screens

        delegate: PanelWindow {
            required property var modelData
            screen: modelData
            visible: rootOverlay.visible

            anchors {
                top: true; bottom: true; left: true; right: true
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore

            color: Theme.surface

            Item {
                anchors.fill: parent

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingL
                    width: Math.min(parent.width * 0.8, 600)

                    DankIcon {
                        name: "bedtime"
                        size: 96
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Theme.primary
                    }

                    Text {
                        text: I18n.tr("Schlafenszeit")
                        font.pixelSize: 42
                        font.bold: true
                        color: Theme.surfaceText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: I18n.tr("Ruhezeit ist aktiv. Bis morgen um %1 Uhr.").arg(rootOverlay.wakeupText)
                        font.pixelSize: 20
                        color: Theme.surfaceVariantText
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                    }

                    Text {
                        text: I18n.tr("Lege das Gerät weg und schlaf gut. 🌙")
                        font.pixelSize: 16
                        color: Theme.surfaceVariantText
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
