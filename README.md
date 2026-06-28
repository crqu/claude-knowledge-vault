# Claude Remote Vault

[English](README.md) | [中文](README_CN.md)

Turn Claude Code's scattered, invisible memories into a persistent, searchable knowledge base — powered by Obsidian.

## The Problem

Every time Claude Code learns your preferences, build toolchains, writing style, or project context, it stores them as memory files buried in `~/.claude/projects/*/memory/`. These files are:

- **Scattered** across project directories with no central view
- **Invisible** to you — there's no built-in way to browse or search them
- **Disconnected** from your note-taking workflow
- **Trapped** on one machine with no multi-device access

If you work on remote servers — GPU clusters, cloud VMs, shared dev boxes — the problem is even worse. Your hard-earned knowledge lives on a machine you don't carry with you, inaccessible from your laptop, phone, or any other device.

You're building up a valuable knowledge base without knowing it, and you can't use it.

## The Solution

Claude Remote Vault continuously syncs all Claude Code memories into an [Obsidian](https://obsidian.md/) vault where you can browse, search, link, and build on them. Every feedback preference, project decision, and reference doc Claude stores becomes a first-class note in your knowledge graph.

**Built for remote workflows:** If you develop on a remote server, this tool bridges the gap. A background service on the server aggregates memories into a vault, and Syncthing automatically syncs it to your local machine in real time — no manual steps, no SSH tunnels after initial setup. Your knowledge follows you, not the other way around.

```
Claude Code sessions
    -> writes memories to ~/.claude/projects/*/memory/
            |
    sync service (watches for changes)
            |
            v
    ~/obsidian-vault/claude-memories/
            |
    Syncthing (optional, real-time)
            |
            v
    Obsidian on your laptop / phone / tablet
```

## What You Get

- **Automatic sync** — a background service watches for new memories and copies them into your vault, organized by project
- **Remote-to-local sync** — seamlessly bridge remote servers and local machines with Syncthing; your knowledge arrives on your laptop in real time, no manual transfer needed
- **Slash commands** — `/sync-knowledge` to force-sync and get a summary; `/vault-note` to save notes from any Claude session
- **Obsidian dashboard** — a home page with Dataview queries showing recent changes across all projects
- **Multi-device access** — optional Syncthing setup for real-time bidirectional sync to any machine
- **Zero lock-in** — everything is plain Markdown. No proprietary formats, no cloud dependency

## Quick Start

```bash
git clone https://github.com/crqu/claude-remote-vault.git
cd claude-remote-vault
./scripts/install.sh
```

The installer will:
1. Ask for your vault path (default: `~/obsidian-vault`)
2. Create the vault with an Obsidian-ready structure
3. Install a background sync service (Linux systemd)
4. Register `/sync-knowledge` and `/vault-note` in Claude Code
5. Run an initial sync of existing memories

## Slash Commands

### `/sync-knowledge [topic]`

Force-sync all Claude Code memories and get a summary organized by project. Pass a topic to search across all stored knowledge.

```
> /sync-knowledge

Synced memories from 3 project(s):

**web-app** (5 files)
  - User prefers Tailwind over styled-components
  - API rate limiting set to 100 req/min
  - Deploy pipeline uses GitHub Actions → AWS ECS

**ml-pipeline** (3 files)
  - Training uses A100 GPUs, batch size 256
  - Checkpoint format: dict with 'model_state_dict' key

**docs-site** (2 files)
  - Content uses MDX with custom components
```

### `/vault-note <content>`

Save a note directly to the vault from any Claude Code session:

```
> /vault-note Key finding: the RQE loss converges 2x faster with cosine warmup

Created: projects/ml-pipeline/rqe-loss-warmup-finding.md
```

## Multi-Device Sync

Want your vault on your laptop, phone, or tablet? See [docs/SYNC-GUIDE.md](docs/SYNC-GUIDE.md) for setting up Syncthing (free, P2P) or alternative sync methods (Git, rsync, iCloud, Obsidian Sync).

## How It Works

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details on:
- Claude Code's memory format and storage
- The sync pipeline
- Vault structure
- Why Obsidian is a natural fit (compatible Markdown + YAML frontmatter + wikilinks)

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (any version with slash command support)
- `rsync` (pre-installed on macOS and most Linux distros)
- **Optional:** [Obsidian](https://obsidian.md/) for browsing the vault
- **Optional:** [Syncthing](https://syncthing.net/) for multi-device sync
- **Optional:** `inotify-tools` for filesystem-level watching on Linux (falls back to polling)

## Uninstall

```bash
./scripts/uninstall.sh
```

Stops services, removes commands and config. Asks before touching your vault (default: keep it).

## License

MIT
