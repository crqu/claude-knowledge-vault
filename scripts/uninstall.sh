#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/claude-knowledge-vault/config"
VAULT_PATH="$HOME/obsidian-vault"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    VAULT_PATH="${CLAUDE_VAULT_PATH:-$VAULT_PATH}"
fi

echo ""
echo "  Claude Knowledge Vault — Uninstaller"
echo ""

# --- Step 1: Stop and disable services ---
if [[ "$(uname -s)" == "Linux" ]] && command -v systemctl &>/dev/null; then
    for svc in sync-claude-memories syncthing; do
        if systemctl --user is-active "$svc.service" &>/dev/null; then
            systemctl --user stop "$svc.service"
            echo "[ok] Stopped $svc"
        fi
        if systemctl --user is-enabled "$svc.service" &>/dev/null; then
            systemctl --user disable "$svc.service" 2>/dev/null
            echo "[ok] Disabled $svc"
        fi
        rm -f "$HOME/.config/systemd/user/$svc.service"
    done
    systemctl --user daemon-reload 2>/dev/null
    echo "[ok] Systemd services removed"
fi

# --- Step 2: Remove Claude Code commands ---
for cmd in sync-knowledge vault-note; do
    if [[ -f "$HOME/.claude/commands/$cmd.md" ]]; then
        rm "$HOME/.claude/commands/$cmd.md"
        echo "[ok] Removed /$cmd command"
    fi
done

# --- Step 3: Remove config ---
if [[ -d "$HOME/.config/claude-knowledge-vault" ]]; then
    rm -rf "$HOME/.config/claude-knowledge-vault"
    echo "[ok] Removed config"
fi

# --- Step 4: Ask about vault ---
echo ""
echo "  Vault location: $VAULT_PATH"
read -r -p "  Remove the vault and all its notes? [y/N]: " REMOVE_VAULT
if [[ "$REMOVE_VAULT" =~ ^[Yy] ]]; then
    rm -rf "$VAULT_PATH"
    echo "[ok] Vault removed"
else
    echo "[ok] Vault preserved at $VAULT_PATH"
fi

echo ""
echo "  Uninstall complete."
echo ""
