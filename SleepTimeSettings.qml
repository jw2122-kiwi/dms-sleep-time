import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Services
import qs.Modules.Plugins

PluginSettingsPage {
    id: page

    pluginId: "sleepTime"

    // ── Enable toggle ──────────────────────────────────────────────────
    SettingGroup {
        title: I18n.tr("General")

        SettingToggle {
            text: I18n.tr("Enable Sleep Time")
            subtitle: I18n.tr("Block the screen during quiet hours")
            checked: pluginData.enabled ?? false
            onCheckedChanged: pluginService.setPluginSetting("sleepTime", "enabled", checked)
        }
    }

    // ── Time window ────────────────────────────────────────────────────
    SettingGroup {
        title: I18n.tr("Quiet Hours")

        SettingTimePicker {
            text: I18n.tr("Start time")
            subtitle: I18n.tr("When the screen blocks")
            value: new Date(0, 0, 0, pluginData.startHour ?? 20, pluginData.startMinute ?? 0)
            onValueChanged: {
                pluginService.setPluginSetting("sleepTime", "startHour", value.getHours());
                pluginService.setPluginSetting("sleepTime", "startMinute", value.getMinutes());
            }
        }

        SettingTimePicker {
            text: I18n.tr("End time")
            subtitle: I18n.tr("When the block lifts")
            value: new Date(0, 0, 0, pluginData.endHour ?? 6, pluginData.endMinute ?? 30)
            onValueChanged: {
                pluginService.setPluginSetting("sleepTime", "endHour", value.getHours());
                pluginService.setPluginSetting("sleepTime", "endMinute", value.getMinutes());
            }
        }
    }

    // ── Info ───────────────────────────────────────────────────────────
    SettingGroup {
        title: I18n.tr("Notes")
        SettingText {
            text: I18n.tr("During quiet hours the entire screen is blocked with a non-dismissable overlay. There is no skip or close button — it lifts automatically at the end time.")
            wrap: true
        }
    }
}
