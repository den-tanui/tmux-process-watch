#!/usr/bin/env bash
# tmux-process-watch - PID-based process tracing for tmux

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Bind key to start tracing current pane
tmux bind-key p run-shell "$CURRENT_DIR/scripts/start-tracing.sh"

echo "tmux-process-watch loaded - press prefix+p to trace current command by PID"
