pragma ComponentBehavior: Bound

import "./dms-common"
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services

PluginSettings {
    id: rootSettings
    pluginId: "sleepTime"

    property var livePlugin: null

    Timer {
        interval: 1000
        running: livePlugin === null
        repeat: true
        onTriggered: {
            livePlugin = PluginService.getGlobalVar("sleepTime", "instance");
        }
    }

    Component.onCompleted: {
        livePlugin = PluginService.getGlobalVar("sleepTime", "instance");
        PluginService.globalVarChanged.connect((pid, vname) => {
            if (pid === "sleepTime" && vname === "instance") {
                livePlugin = PluginService.getGlobalVar("sleepTime", "instance");
            }
        });
    }

    SettingsCard {
        title: I18n.tr("General")
        subtitle: I18n.tr("Block the screen during quiet hours")

        ToggleSettingPlus {
            settingKey: "enabled"
            label: I18n.tr("Enable Sleep Time")
            description: I18n.tr("When off, the overlay never shows")
            defaultValue: false
        }
    }

    SettingsCard {
        title: I18n.tr("Quiet Hours")
        subtitle: I18n.tr("Screen blocks between start and end time")

        SliderSettingPlus {
            settingKey: "startHour"
            label: I18n.tr("Start hour")
            description: I18n.tr("When the block begins")
            defaultValue: 20
            minimum: 0
            maximum: 23
            unit: "h"
        }
        SliderSettingPlus {
            settingKey: "startMinute"
            label: I18n.tr("Start minute")
            defaultValue: 0
            minimum: 0
            maximum: 55
            unit: "m"
        }
        SliderSettingPlus {
            settingKey: "endHour"
            label: I18n.tr("End hour")
            description: I18n.tr("When the block lifts")
            defaultValue: 6
            minimum: 0
            maximum: 23
            unit: "h"
        }
        SliderSettingPlus {
            settingKey: "endMinute"
            label: I18n.tr("End minute")
            defaultValue: 30
            minimum: 0
            maximum: 55
            unit: "m"
        }
    }

    SettingsCard {
        title: I18n.tr("Notes")
        StatusDisplay {
            text: I18n.tr("During quiet hours the entire screen is blocked with a non-dismissable overlay. No skip or close button — it lifts automatically at the end time.")
            wrap: true
        }
    }

    PluginAbout {
        repoUrl: "https://github.com/jw2122-kiwi/dms-sleep-time"
    }
}
