# tmux-process-watch

On-demand process tracing for tmux - trace already-running commands with a keypress.

## Features

- **On-demand tracing**: Press a key to start tracing the currently running command
- **Trace existing commands**: Works with commands already running, not just new ones
- **tmux integration**: Pure tmux solution, no shell plugin required
- **Extensible notifications**: Supports notify-send, custom commands, or any notification system
- **Automatic completion detection**: Detects when traced command finishes

## Installation

### Via TPM (recommended)

Add to your `.tmux.conf`:

```tmux
set -g @plugin 'den-tanui/tmux-process-watch'
```

### Manual

Clone this repository to your tmux plugins directory.

## Configuration

### Zsh Setup

Add to your `.zshrc`:

```zsh
source /path/to/tmux-process-watch.plugin.zsh
```

### tmux Configuration

Add to your `.tmux.conf`:

```tmux
# Enable the plugin
set -g @plugin 'path/to/tmux-process-watch'

# Optional settings
set -g @process-watch-notify 'notify-send'  # or your custom command
set -g @process-watch-min-duration '10'     # minimum seconds to notify
```

## Usage

1. **Start tracing**: Press `prefix + p` while a command is running
2. **Automatic notification**: Get notified when the command completes
3. **That's it!** No shell configuration needed

## Customization

### Notification Command

Set any command for notifications:

```tmux
set -g @process-watch-notify 'your-notification-command'
```

### Ignore Commands

Set commands to ignore in zsh plugin:

```zsh
export TMUX_PROCESS_WATCH_IGNORE="cd,ls,clear,exit,vim"
```

## How It Works

1. **Start tracing**: Press `prefix + p` to capture the PID of the currently running command
2. **PID monitoring**: Watches the actual process tree (not pane output)
3. **Notify**: Sends notification when the process completes

Uses `/proc` filesystem for reliable process tracking - no brittle output parsing!

## Requirements

- zsh (for shell integration)
- tmux 2.9+
- notify-send (or custom notification command)

## Troubleshooting

### Notifications not showing?

1. **Check debug log**: Look in `.tracing/debug.log` for errors
2. **DBUS issues**: If using Wayland, ensure `DBUS_SESSION_BUS_ADDRESS` is set
3. **Fallback**: tmux display-message always shows completion

### Process not detected?

- Make sure you press `prefix + p` while the command is actually running
- Some commands run in subshells - trace the parent process instead

## License

MIT
