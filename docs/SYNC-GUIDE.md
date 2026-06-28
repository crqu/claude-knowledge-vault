# Multi-Device Sync Guide

This guide covers setting up real-time bidirectional sync between machines so your vault stays in sync everywhere.

## Recommended: Syncthing

[Syncthing](https://syncthing.net/) is a free, open-source, peer-to-peer file sync tool. No cloud account needed — devices connect directly (or via relays when behind NAT).

### Install Syncthing

**Linux (Homebrew):**
```bash
brew install syncthing
```

**Linux (apt):**
```bash
sudo apt install syncthing
```

**macOS:**
```bash
brew install syncthing
brew services start syncthing
```

**Windows:**
Download from [syncthing.net](https://syncthing.net/downloads/) or use:
```powershell
winget install Syncthing.Syncthing
```

### Start the Service

**Linux (systemd):**

If you ran `install.sh`, the Syncthing service is already set up. Otherwise:

```bash
# Copy the service template
cp templates/systemd/syncthing.service ~/.config/systemd/user/
# Edit to set the correct syncthing binary path
sed -i "s|{{SYNCTHING_BIN}}|$(which syncthing)|g" \
    ~/.config/systemd/user/syncthing.service

systemctl --user daemon-reload
systemctl --user enable --now syncthing.service
```

**macOS:**
```bash
brew services start syncthing
```

### Pair Two Machines

Syncthing uses Device IDs (long alphanumeric strings) to identify machines. Here's how to pair them:

#### 1. Get each machine's Device ID

On **Machine A** (e.g., your remote server), access the Syncthing web GUI:
- Local: `http://127.0.0.1:8384`
- Remote (via SSH tunnel): `ssh -L 9384:127.0.0.1:<syncthing-gui-port> user@server`, then open `http://127.0.0.1:9384`

Find the Device ID under **Actions > Show ID**.

On **Machine B** (e.g., your laptop), open `http://127.0.0.1:8384`.

#### 2. Add each machine to the other

On Machine A's GUI:
- Click **"Add Remote Device"**
- Paste Machine B's Device ID
- Give it a recognizable name
- Click **Save**

Repeat on Machine B with Machine A's Device ID.

#### 3. Accept the device

Each side will show a notification asking to confirm the new device. Accept it.

#### 4. Share the vault folder

On the machine where the vault already exists:
- Click the vault folder → **Edit** → **Sharing** tab
- Check the other device
- Click **Save**

The other machine will receive a notification to accept the shared folder. Accept it and choose where to store the files locally (e.g., `~/Documents/ObsidianVault`).

### Done

Files now sync automatically. Syncthing handles:
- Real-time sync (sub-second latency on local networks)
- Conflict resolution (creates `.sync-conflict-*` files)
- NAT traversal via relay servers
- Encryption in transit

The SSH tunnel is **only needed for the initial web GUI pairing**. After that, Syncthing communicates independently.

### Verify sync status

```bash
# Check service status
systemctl --user status syncthing

# Check connection via API (replace API_KEY and PORT)
curl -s -H "X-API-Key: YOUR_API_KEY" \
    http://127.0.0.1:PORT/rest/system/connections
```

---

## Alternative Sync Methods

### Git-based sync

Good for version history and offline access. Set up a private repo:

```bash
cd ~/obsidian-vault
git init
echo '.stfolder' >> .gitignore
echo '.stversions/' >> .gitignore
echo '.obsidian/workspace.json' >> .gitignore
git add -A && git commit -m "Initial vault"
git remote add origin git@github.com:you/your-vault.git
git push -u origin main
```

Automate with a cron job:
```bash
# Every 5 minutes, commit and push changes
*/5 * * * * cd ~/obsidian-vault && git add -A && git diff --cached --quiet || git commit -m "auto-sync $(date +\%F-\%H\%M)" && git push
```

On the other machine, pull periodically or use the [Obsidian Git](https://github.com/denolehov/obsidian-git) plugin.

### rsync + cron

Simple one-directional sync:

```bash
# Pull from remote every 5 minutes (run on local machine)
*/5 * * * * rsync -avz --delete user@server:~/obsidian-vault/ ~/ObsidianVault/
```

### Cloud storage

If you use iCloud, Dropbox, or Google Drive, place the vault folder inside the synced directory. On macOS, the default iCloud path is:

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/
```

### Obsidian Sync (paid)

Obsidian's built-in sync service ($4/mo). End-to-end encrypted. Works across all platforms including mobile. Set up via **Settings > Sync** in Obsidian.
