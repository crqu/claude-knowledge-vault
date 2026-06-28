# Architecture

## How Claude Code Stores Memories

Claude Code maintains per-project memory files at:

```
~/.claude/projects/<project-path>/memory/
```

Each project directory gets its own memory store. Memory files are Markdown with YAML frontmatter:

```yaml
---
name: short-kebab-slug
description: one-line summary
metadata:
  type: user | feedback | project | reference
---

Memory content with [[wikilinks]] to related memories.
```

### Memory Types

| Type | Purpose |
|------|---------|
| `user` | User's role, preferences, expertise |
| `feedback` | Guidance on approach — corrections and confirmations |
| `project` | Ongoing work, goals, decisions, context |
| `reference` | Pointers to external resources |

Each project also has a `MEMORY.md` index file listing all memories with one-line descriptions.

## The Sync Pipeline

```
Claude Code sessions
    writes to ~/.claude/projects/*/memory/*.md
            |
    sync-claude-memories.sh (polls every 60s)
            |
            v
    ~/obsidian-vault/claude-memories/<project>/
            |
    Syncthing (optional, real-time bidirectional)
            |
            v
    ~/obsidian-vault/ on another machine
            |
    Obsidian reads the vault
```

### Sync Script

`sync-claude-memories.sh` uses `rsync` to copy memory files:

- Scans all project directories under `~/.claude/projects/`
- For each project with a `memory/` subdirectory, rsyncs `*.md` files
- Uses `--update` to only copy newer files and `--delete` to remove stale ones
- In `--watch` mode: uses `inotifywait` for filesystem events, falls back to 60-second polling

### Systemd Services

Two user-level systemd services keep things running:

- **sync-claude-memories.service** — runs the sync script in watch mode
- **syncthing.service** — (optional) runs Syncthing for multi-device sync

Both are installed under `~/.config/systemd/user/` and start automatically on login.

## Vault Structure

```
obsidian-vault/
├── Home.md                    # Dashboard with Dataview queries
├── claude-memories/           # Auto-synced from Claude Code
│   ├── README.md
│   └── <project-name>/       # One folder per project
│       ├── MEMORY.md          # Index of memories
│       └── *.md               # Individual memory files
├── projects/                  # Manual project notes
│   └── README.md
├── daily/                     # Daily notes
└── bin/
    └── sync-claude-memories.sh
```

### Why Obsidian?

Claude Code's memory format — Markdown with YAML frontmatter and `[[wikilinks]]` — is natively compatible with Obsidian. No conversion needed. Memories become first-class notes in your knowledge graph, with full-text search, backlinks, and the graph view connecting related knowledge across projects.
