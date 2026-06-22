#!/usr/bin/env bash
# Toggle process monitoring

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if monitoring is enabled
MONITORING_FILE="$CURRENT_DIR/../.monitoring_enabled"

if [[ -f "$MONITORING_FILE" ]]; then
	rm "$MONITORING_FILE"
	tmux display-message "Process monitoring disabled"
else
	touch "$MONITORING_FILE"
	tmux display-message "Process monitoring enabled"
fi
