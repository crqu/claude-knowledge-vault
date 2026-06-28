#!/usr/bin/env bash
#
# Sync Claude Code memory files from all projects into the Obsidian vault.
# Safe to run repeatedly — uses rsync to only copy changed files.
#
# Usage:
#   sync-claude-memories.sh           # one-shot sync
#   sync-claude-memories.sh --watch   # continuous watch mode

set -euo pipefail

CONFIG_FILE="$HOME/.config/claude-remote-vault/config"
if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
VAULT_DIR="${CLAUDE_VAULT_PATH:-$HOME/obsidian-vault}"
VAULT_MEMORIES_DIR="$VAULT_DIR/claude-memories"

sync_all() {
    if [[ ! -d "$CLAUDE_PROJECTS_DIR" ]]; then
        echo "No Claude projects directory found at $CLAUDE_PROJECTS_DIR"
        exit 0
    fi

    local count=0
    for project_dir in "$CLAUDE_PROJECTS_DIR"/*/; do
        local memory_dir="${project_dir}memory"
        [[ -d "$memory_dir" ]] || continue

        local project_name
        project_name=$(basename "$project_dir")
        local dest_dir="$VAULT_MEMORIES_DIR/$project_name"
        mkdir -p "$dest_dir"

        rsync -a --update --delete \
            --include='*.md' \
            --exclude='*' \
            "$memory_dir/" "$dest_dir/"

        count=$((count + 1))
    done

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Synced memories from $count project(s) to $VAULT_DIR"
}

if [[ "${1:-}" == "--watch" ]]; then
    if ! command -v inotifywait &>/dev/null; then
        echo "inotifywait not found. Falling back to polling every 60 seconds..."
        while true; do
            sync_all
            sleep 60
        done
    else
        echo "Watching for changes in $CLAUDE_PROJECTS_DIR ..."
        sync_all
        while true; do
            inotifywait -r -q -e modify,create,delete,move \
                --timeout 300 \
                "$CLAUDE_PROJECTS_DIR" 2>/dev/null || true
            sync_all
        done
    fi
else
    sync_all
fi
