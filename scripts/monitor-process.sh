#!/usr/bin/env bash
# Monitor a process by PID and notify when it completes

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANE_ID="$1"
TARGET_PID="$2"

TRACING_DIR="$CURRENT_DIR/../.tracing"
START_FILE="$TRACING_DIR/${PANE_ID}.start"

# Wait for process to complete
while [[ -d "/proc/$TARGET_PID" ]]; do
	sleep 1
done

# Process completed - calculate duration
if [[ -f "$START_FILE" ]]; then
	START_TIME=$(cat "$START_FILE")
	DURATION=$((EPOCHSECONDS - START_TIME))
	CURRENT_CMD=$(cat "$TRACING_DIR/${PANE_ID}.cmd" 2>/dev/null || echo "unknown")

	# Send notification
	NOTIFY_CMD="$(tmux show-options -gqv @process-watch-notify 2>/dev/null || echo "notify-send")"

	if [[ "$NOTIFY_CMD" == "notify-send" ]]; then
		notify-send "Process completed" "$CURRENT_CMD\nPID: $TARGET_PID\nDuration: ${DURATION}s"
	else
		eval "$NOTIFY_CMD" "Process completed" "$CURRENT_CMD (${DURATION}s)"
	fi

	# Clean up
	rm -f "$START_FILE" "$TRACING_DIR/${PANE_ID}.pid" "$TRACING_DIR/${PANE_ID}.cmd"
	tmux display-message "Process completed: $CURRENT_CMD (${DURATION}s)"
fi
