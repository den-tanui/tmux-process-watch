#!/usr/bin/env bash
# Handle process completion messages from zsh plugin

PANE_ID="$1"
DURATION="$2"
CMD="$3"

# Configuration - can be overridden by tmux options
NOTIFY_CMD="$(tmux show-options -gqv @process-watch-notify 2>/dev/null || echo "notify-send")"
MIN_DURATION="$(tmux show-options -gqv @process-watch-min-duration 2>/dev/null || echo "5")"

# Only notify if duration meets minimum
if [[ "$DURATION" -ge "$MIN_DURATION" ]]; then
	# Send notification
	if [[ "$NOTIFY_CMD" == "notify-send" ]]; then
		notify-send "Process completed" "Command: $CMD\nDuration: ${DURATION}s\nPane: $PANE_ID"
	else
		# Execute custom notification command
		eval "$NOTIFY_CMD" "Process completed" "$CMD (${DURATION}s)"
	fi

	# Also trigger tmux visual bell
	tmux display-message "Process completed: $CMD (${DURATION}s)"
fi
