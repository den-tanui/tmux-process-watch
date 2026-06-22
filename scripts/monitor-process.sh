#!/usr/bin/env bash
# Monitor a process by PID and notify when it completes

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANE_ID="$1"
TARGET_PID="$2"

TRACING_DIR="$CURRENT_DIR/../.tracing"
START_FILE="$TRACING_DIR/${PANE_ID}.start"

# Debug logging
exec 2>>"$TRACING_DIR/debug.log"
echo "Starting monitor for PID $TARGET_PID" >>"$TRACING_DIR/debug.log"

# Wait for process to complete
while [[ -d "/proc/$TARGET_PID" ]]; do
	sleep 1
done

echo "Process $TARGET_PID exited" >>"$TRACING_DIR/debug.log"

# Process completed - calculate duration
if [[ -f "$START_FILE" ]]; then
	START_TIME=$(cat "$START_FILE")
	DURATION=$((EPOCHSECONDS - START_TIME))
	CURRENT_CMD=$(cat "$TRACING_DIR/${PANE_ID}.cmd" 2>/dev/null || echo "unknown")

	# Always show tmux message first (most reliable)
	tmux display-message "Process completed: $CURRENT_CMD (${DURATION}s)"

	# Try notify-send with proper DBUS session
	NOTIFY_CMD="$(tmux show-options -gqv @process-watch-notify 2>/dev/null || echo "notify-send")"

	if [[ "$NOTIFY_CMD" == "notify-send" ]]; then
		# Try to find a valid DBUS session
		DBUS_SESSION=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/*/environ 2>/dev/null | cut -d/ -f3 | head -1)
		if [[ -n "$DBUS_SESSION" && -f "/proc/$DBUS_SESSION/environ" ]]; then
			DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$DBUS_SESSION/environ 2>/dev/null | tr '\0' '\n')
			export DBUS_SESSION_BUS_ADDRESS
			notify-send "Process completed" "$CURRENT_CMD\nDuration: ${DURATION}s" 2>>"$TRACING_DIR/debug.log" || true
		else
			# Fallback: trigger notification via tmux
			tmux run-shell "notify-send 'Process completed' '$CURRENT_CMD\\nDuration: ${DURATION}s'" 2>/dev/null || true
		fi
	else
		# Custom notification command via tmux
		tmux run-shell "$NOTIFY_CMD 'Process completed' '$CURRENT_CMD (${DURATION}s)'" 2>/dev/null || true
	fi

	# Clean up
	rm -f "$START_FILE" "$TRACING_DIR/${PANE_ID}.pid" "$TRACING_DIR/${PANE_ID}.cmd"
fi
