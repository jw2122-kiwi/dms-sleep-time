import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool enabled: pluginData.enabled ?? false
    property int startHour: pluginData.startHour ?? 20
    property int startMinute: pluginData.startMinute ?? 0
    property int endHour: pluginData.endHour ?? 6
    property int endMinute: pluginData.endMinute ?? 30

    property bool isActiveInstance: false
    property bool isSleepActive: false

    pluginId: "sleepTime"
    pluginService: PluginService

    // ── Time check ──────────────────────────────────────────────────────
    function isInQuietHours() {
        const now = new Date();
        const cur = now.getHours() * 60 + now.getMinutes();
        const start = root.startHour * 60 + root.startMinute;
        const end = root.endHour * 60 + root.endMinute;
        if (start <= end) {
            // same-day window (e.g. 09:00–17:00)
            return cur >= start && cur < end;
        } else {
            // wraps midnight (e.g. 20:00–06:30)
            return cur >= start || cur < end;
        }
    }

    function updateSleepState() {
        if (!root.enabled) {
            root.isSleepActive = false;
            return;
        }
        root.isSleepActive = root.isInQuietHours();
    }

    // ── Daemon instance election (global-var mutex, not parent!==null) ──
    Component.onCompleted: {
        if (pluginId !== "" && !PluginService.getGlobalVar(pluginId, "instance")) {
            PluginService.setGlobalVar(pluginId, "instance", root);
            root.isActiveInstance = true;
        }
        if (root.isActiveInstance) {
            root.updateSleepState();
        }
    }

    onPluginIdChanged: {
        if (root.isActiveInstance && pluginId !== "") {
            PluginService.setGlobalVar(pluginId, "instance", root);
        }
    }

    // ── Settings change → re-evaluate ──────────────────────────────────
    onEnabledChanged: if (root.isActiveInstance) root.updateSleepState()
    onStartHourChanged: if (root.isActiveInstance) root.updateSleepState()
    onStartMinuteChanged: if (root.isActiveInstance) root.updateSleepState()
    onEndHourChanged: if (root.isActiveInstance) root.updateSleepState()
    onEndMinuteChanged: if (root.isActiveInstance) root.updateSleepState()

    // ── Poll every 30s ─────────────────────────────────────────────────
    Timer {
        id: checkTimer
        interval: 30000
        repeat: true
        running: root.isActiveInstance
        onTriggered: root.updateSleepState()
    }

    // ── Control Center widget ──────────────────────────────────────────
    ccWidgetIcon: "bedtime"
    ccWidgetPrimaryText: I18n.tr("Sleep Time")
    ccWidgetSecondaryText: root.enabled
        ? (root.isSleepActive ? I18n.tr("Active — quiet hours") : I18n.tr("Enabled · " + root.startHour + ":" + (root.startMinute < 10 ? "0" : "") + root.startMinute + "–" + root.endHour + ":" + (root.endMinute < 10 ? "0" : "") + root.endMinute))
        : I18n.tr("Disabled")

    // ── Overlay (non-dismissable) ─────────────────────────────────────
    SleepTimeOverlay {
        id: sleepOverlay
        pluginRoot: root
        visible: root.isSleepActive
    }
}
