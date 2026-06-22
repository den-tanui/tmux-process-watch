#!/usr/bin/env bash
# Start tracing the currently running command using PID

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANE_ID="${1:-#{pane_id}}"

# Get the pane PID
PANE_PID=$(tmux display-message -p -t "$PANE_ID" -F "#{pane_pid}")

# Get the current foreground process group
FG_PID=$(ps -o pgid= -p "$PANE_PID" 2>/dev/null | tr -d ' ' || echo "$PANE_PID")

# Get the actual running command (not shell)
CURRENT_CMD=""
if [[ -d "/proc/$FG_PID" ]]; then
	CURRENT_CMD=$(cat "/proc/$FG_PID/cmdline" 2>/dev/null | tr '\0' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	if [[ -z "$CURRENT_CMD" ]]; then
		CURRENT_CMD=$(ps -p "$FG_PID" -o comm= 2>/dev/null || echo "unknown")
	fi
fi

# Store tracing info
TRACING_DIR="$CURRENT_DIR/../.tracing"
mkdir -p "$TRACING_DIR"
echo "$EPOCHSECONDS" >"$TRACING_DIR/${PANE_ID}.start"
echo "$FG_PID" >"$TRACING_DIR/${PANE_ID}.pid"
echo "$CURRENT_CMD" >"$TRACING_DIR/${PANE_ID}.cmd"

if [[ "$FG_PID" == "$PANE_PID" ]]; then
	tmux display-message "Tracing shell (no foreground process)"
else
	tmux display-message "Tracing PID $FG_PID: $CURRENT_CMD"
fi

# Start monitoring in background
tmux start-server \; run-shell -b "$CURRENT_DIR/monitor-process.sh $PANE_ID $FG_PID"
