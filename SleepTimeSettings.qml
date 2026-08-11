pragma ComponentBehavior: Bound

import "./dms-common"
import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Services
import qs.Modules.Plugins

PluginSettings {
    id: page

    pluginId: "sleepTime"

    // ── Enable ──────────────────────────────────────────────────────────
    SettingsCard {
        title: I18n.tr("General")
        subtitle: I18n.tr("Block the screen during quiet hours")

        ToggleSettingPlus {
            text: I18n.tr("Enable Sleep Time")
            subtitle: I18n.tr("When off, the overlay never shows")
            checked: pluginData.enabled ?? false
            onCheckedChanged: pluginService.setPluginSetting("sleepTime", "enabled", checked)
        }
    }

    // ── Quiet hours window ─────────────────────────────────────────────
    SettingsCard {
        title: I18n.tr("Quiet Hours")
        subtitle: I18n.tr("Screen blocks between start and end time")

        SliderSettingPlus {
            text: I18n.tr("Start hour")
            subtitle: I18n.tr("When the block begins")
            value: pluginData.startHour ?? 20
            from: 0
            to: 23
            step: 1
            suffix: "h"
            onValueChanged: pluginService.setPluginSetting("sleepTime", "startHour", value)
        }

        SliderSettingPlus {
            text: I18n.tr("Start minute")
            value: pluginData.startMinute ?? 0
            from: 0
            to: 59
            step: 5
            suffix: "m"
            onValueChanged: pluginService.setPluginSetting("sleepTime", "startMinute", value)
        }

        SliderSettingPlus {
            text: I18n.tr("End hour")
            subtitle: I18n.tr("When the block lifts")
            value: pluginData.endHour ?? 6
            from: 0
            to: 23
            step: 1
            suffix: "h"
            onValueChanged: pluginService.setPluginSetting("sleepTime", "endHour", value)
        }

        SliderSettingPlus {
            text: I18n.tr("End minute")
            value: pluginData.endMinute ?? 30
            from: 0
            to: 59
            step: 5
            suffix: "m"
            onValueChanged: pluginService.setPluginSetting("sleepTime", "endMinute", value)
        }
    }

    // ── Info ─────────────────────────────────────────────────────────────
    SettingsCard {
        title: I18n.tr("Notes")
        SettingsDivider {}
        StatusDisplay {
            text: I18n.tr("During quiet hours the entire screen is blocked with a non-dismissable overlay. No skip or close button — it lifts automatically at the end time.")
            wrap: true
        }
    }
}
