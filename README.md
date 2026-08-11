# Sleep Time

A DMS (DankMaterialShell) plugin that blocks your screen during quiet hours with a **non-dismissable full-screen overlay**. No skip, no close — it lifts automatically when the quiet window ends.

## Features

- **Quiet hours block:** Screen is fully locked during the configured window (default **20:00 – 06:30**).
- **Non-dismissable overlay:** Full opaque surface, exclusive keyboard focus, no buttons to bypass.
- **Configurable:** Enable/disable toggle + start/end time in settings.
- **Auto-lift:** Overlay disappears on its own at the end time.

## Install (local)

```bash
git clone https://github.com/jw2122-kiwi/dms-sleep-time.git
cd dms-sleep-time

# Symlink into DMS plugins dir (path depends on your setup):
ln -s "$(pwd)" ~/.config/dankmaterialshell/plugins/sleepTime
#   or (older setups):
# ln -s "$(pwd)" ~/.config/DankMaterialShell/plugins/sleepTime

# Restart DMS (Command Palette → "Restart Shell")
```

Then enable it in the Sleep Time settings page and set your quiet hours.

## How it works

- Daemon instance elected via `PluginService` global-var mutex (framework-supported, no `parent !== null` anti-pattern).
- Polls every 30s; when current time is inside the window and the plugin is enabled, the overlay shows.
- Overlay uses `WlrLayer.Overlay` + `WlrKeyboardFocus.Exclusive` so it cannot be clicked away or focused past.

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| Enable | off | Master toggle |
| Start time | 20:00 | Quiet hours begin |
| End time | 06:30 | Quiet hours end |

## License

MIT
