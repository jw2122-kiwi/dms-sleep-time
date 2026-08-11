pragma ComponentBehavior: Bound

import "./dms-common"
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services

PluginComponent {
    id: root

    property bool enabled: pluginData.enabled ?? false
    property int startHour: pluginData.startHour ?? 20
    property int startMinute: pluginData.startMinute ?? 0
    property int endHour: pluginData.endHour ?? 6
    property int endMinute: pluginData.endMinute ?? 30

    property bool isActiveInstance: false
    property bool isSteakActive: false

    pluginId: "takeAsteak"
    pluginService: PluginService

    // ── Time helpers ─────────────────────────────────────────────────────
    function toMin(h, m) { return h * 60 + m; }

    function isInSteakHours() {
        const now = new Date();
        const cur = now.getHours() * 60 + now.getMinutes();
        const start = toMin(root.startHour, root.startMinute);
        const end = toMin(root.endHour, root.endMinute);
        if (start <= end) return cur >= start && cur < end;
        return cur >= start || cur < end; // wraps midnight
    }

    function updateSteakState() {
        if (!root.enabled) { root.isSteakActive = false; return; }
        root.isSteakActive = root.isInSteakHours();
    }

    function msUntilNextBoundary() {
        if (!root.enabled) return 60000;
        const now = new Date();
        const curSec = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds();
        const startSec = toMin(root.startHour, root.startMinute) * 60;
        const endSec = toMin(root.endHour, root.endMinute) * 60;
        const cands = [startSec, startSec + 86400, endSec, endSec + 86400];
        let next = -1;
        for (const c of cands) {
            let diff = c - curSec;
            if (diff <= 0) diff += 86400;
            if (next === -1 || diff < next) next = diff;
        }
        return Math.max(next * 1000 + 2000, 1000);
    }

    function reschedule() {
        checkTimer.interval = root.msUntilNextBoundary();
        checkTimer.restart();
    }

    // ── Daemon instance election (global-var mutex) ─────────────────────
    Component.onCompleted: {
        if (pluginId !== "") {
            const registered = PluginService.getGlobalVar(pluginId, "instance");
            if (!registered) {
                PluginService.setGlobalVar(pluginId, "instance", root);
                root.isActiveInstance = true;
            } else if (registered === root) {
                root.isActiveInstance = true;
            }
        }
        if (root.isActiveInstance) {
            root.updateSteakState();
            root.reschedule();
        }
    }

    onPluginIdChanged: {
        if (root.isActiveInstance && pluginId !== "") {
            PluginService.setGlobalVar(pluginId, "instance", root);
        }
    }

    onEnabledChanged: if (root.isActiveInstance) { root.updateSteakState(); root.reschedule(); }
    onStartHourChanged: if (root.isActiveInstance) { root.updateSteakState(); root.reschedule(); }
    onStartMinuteChanged: if (root.isActiveInstance) { root.updateSteakState(); root.reschedule(); }
    onEndHourChanged: if (root.isActiveInstance) { root.updateSteakState(); root.reschedule(); }
    onEndMinuteChanged: if (root.isActiveInstance) { root.updateSteakState(); root.reschedule(); }

    // ── Single-shot timer, rescheduled to next boundary ─────────────────
    Timer {
        id: checkTimer
        interval: 60000
        repeat: false
        running: root.isActiveInstance && root.enabled
        onTriggered: { root.updateSteakState(); root.reschedule(); }
    }

    // ── Control Center widget ───────────────────────────────────────────
    ccWidgetIcon: "restaurant"
    ccWidgetPrimaryText: I18n.tr("Take a Steak")
    ccWidgetSecondaryText: root.enabled
        ? (root.isSteakActive ? I18n.tr("Active — quiet hours") : I18n.tr("Enabled · " + root.startHour + ":" + (root.startMinute < 10 ? "0" : "") + root.startMinute + "–" + root.endHour + ":" + (root.endMinute < 10 ? "0" : "") + root.endMinute))
        : I18n.tr("Disabled")

    // ── Overlay (non-dismissable) ──────────────────────────────────────
    TakeAsteakOverlay {
        id: sleepOverlay
        pluginRoot: root
        visible: root.isSteakActive
    }
}
