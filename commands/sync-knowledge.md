Sync all Claude Code memories into the Obsidian vault and provide a summary.

Do the following steps:

1. Run `$VAULT_PATH/bin/sync-claude-memories.sh` to force an immediate sync of all Claude Code memories from every project into the vault.

2. Read the vault index at `$VAULT_PATH/claude-memories/` — list which projects have memories and how many files each has.

3. For each project's memory directory, read the `MEMORY.md` index file if it exists to understand what knowledge is stored.

4. Provide a concise summary organized by project:
   - Project name (derived from the directory name)
   - Number of memory files
   - Key topics covered (from MEMORY.md entries)
   - Any memories that were newly synced in this run

5. If the user provided arguments with this command (e.g., a topic or question), search across all memory files for relevant content and surface matching notes.

The vault lives at `$VAULT_PATH`. Memory files use YAML frontmatter with `name`, `description`, and `metadata.type` fields. The type can be: user, feedback, project, or reference.
