#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

print_banner() {
    echo ""
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║     Claude Remote Vault           ║"
    echo "  ║     Installer v1.0                   ║"
    echo "  ╚══════════════════════════════════════╝"
    echo ""
}

print_banner

# --- Step 1: Vault path ---
DEFAULT_VAULT="$HOME/obsidian-vault"
read -r -p "Vault path [$DEFAULT_VAULT]: " VAULT_PATH
VAULT_PATH="${VAULT_PATH:-$DEFAULT_VAULT}"
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

echo ""
echo "Using vault path: $VAULT_PATH"

# --- Step 2: Write config ---
CONFIG_DIR="$HOME/.config/claude-remote-vault"
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/config" <<EOF
CLAUDE_VAULT_PATH="$VAULT_PATH"
EOF
echo "[ok] Config written to $CONFIG_DIR/config"

# --- Step 3: Create vault structure ---
if [[ -d "$VAULT_PATH" ]]; then
    echo "[ok] Vault directory already exists, preserving existing files"
else
    mkdir -p "$VAULT_PATH"
    echo "[ok] Created vault directory"
fi

mkdir -p "$VAULT_PATH"/{claude-memories,projects,daily}

for tmpl_file in "$REPO_DIR"/templates/vault/*.md; do
    [[ -f "$tmpl_file" ]] || continue
    dest_file="$VAULT_PATH/$(basename "$tmpl_file")"
    if [[ ! -f "$dest_file" ]]; then
        cp "$tmpl_file" "$dest_file"
    fi
done

for subdir in claude-memories projects .obsidian; do
    if [[ -d "$REPO_DIR/templates/vault/$subdir" ]]; then
        for tmpl_file in "$REPO_DIR/templates/vault/$subdir"/*; do
            [[ -f "$tmpl_file" ]] || continue
            mkdir -p "$VAULT_PATH/$subdir"
            dest_file="$VAULT_PATH/$subdir/$(basename "$tmpl_file")"
            if [[ ! -f "$dest_file" ]]; then
                cp "$tmpl_file" "$dest_file"
            fi
        done
    fi
done

echo "[ok] Vault structure ready"

# --- Step 4: Install sync script ---
mkdir -p "$VAULT_PATH/bin"
cp "$REPO_DIR/scripts/sync-claude-memories.sh" "$VAULT_PATH/bin/"
chmod +x "$VAULT_PATH/bin/sync-claude-memories.sh"
echo "[ok] Sync script installed to $VAULT_PATH/bin/"

# --- Step 5: Install systemd services (Linux only) ---
if [[ "$(uname -s)" == "Linux" ]] && command -v systemctl &>/dev/null; then
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"

    # sync-claude-memories service
    sed "s|{{VAULT_PATH}}|$VAULT_PATH|g" \
        "$REPO_DIR/templates/systemd/sync-claude-memories.service" \
        > "$SYSTEMD_DIR/sync-claude-memories.service"

    # syncthing service (optional)
    SYNCTHING_BIN=""
    if command -v syncthing &>/dev/null; then
        SYNCTHING_BIN="$(command -v syncthing)"
        sed "s|{{SYNCTHING_BIN}}|$SYNCTHING_BIN|g" \
            "$REPO_DIR/templates/systemd/syncthing.service" \
            > "$SYSTEMD_DIR/syncthing.service"
    fi

    systemctl --user daemon-reload

    systemctl --user enable sync-claude-memories.service 2>/dev/null
    echo "[ok] Systemd service: sync-claude-memories enabled"

    if [[ -n "$SYNCTHING_BIN" ]]; then
        systemctl --user enable syncthing.service 2>/dev/null
        echo "[ok] Systemd service: syncthing enabled"
    fi

    echo ""
    read -r -p "Start services now? [Y/n]: " START_SERVICES
    START_SERVICES="${START_SERVICES:-Y}"
    if [[ "$START_SERVICES" =~ ^[Yy] ]]; then
        systemctl --user start sync-claude-memories.service
        echo "[ok] sync-claude-memories service started"
        if [[ -n "$SYNCTHING_BIN" ]]; then
            systemctl --user start syncthing.service
            echo "[ok] syncthing service started"
        fi
    fi
else
    echo "[--] Systemd not available (non-Linux or no systemctl)"
    echo "     You can run the sync manually:"
    echo "     $VAULT_PATH/bin/sync-claude-memories.sh --watch &"
fi

# --- Step 6: Install Claude Code slash commands ---
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS_DIR"

for cmd_file in "$REPO_DIR"/commands/*.md; do
    [[ -f "$cmd_file" ]] || continue
    dest_file="$CLAUDE_COMMANDS_DIR/$(basename "$cmd_file")"
    sed "s|\\\$VAULT_PATH|$VAULT_PATH|g" "$cmd_file" > "$dest_file"
done
echo "[ok] Claude Code commands installed to $CLAUDE_COMMANDS_DIR"

# --- Step 7: Initial sync ---
echo ""
echo "Running initial memory sync..."
"$VAULT_PATH/bin/sync-claude-memories.sh" || true

# --- Step 8: Summary ---
echo ""
echo "  ════════════════════════════════════════"
echo "  Installation complete!"
echo ""
echo "  Vault:     $VAULT_PATH"
echo "  Config:    $CONFIG_DIR/config"
echo "  Commands:  /sync-knowledge, /vault-note"
echo ""
echo "  Next steps:"
echo "  1. Open $VAULT_PATH in Obsidian"
echo "  2. Use /sync-knowledge in any Claude Code session"
echo "  3. For multi-device sync, see docs/SYNC-GUIDE.md"
echo "  ════════════════════════════════════════"
echo ""
