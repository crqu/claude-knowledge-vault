Save a note directly to the Obsidian vault.

The user's input after the command is the note content or topic. Do the following:

1. Parse the user's input to determine:
   - The note title/topic
   - The content to save
   - Which subfolder it belongs in (default: `projects/`)

2. Create a markdown file in `$VAULT_PATH/` with proper Obsidian-compatible frontmatter:

```markdown
---
tags: [relevant, tags]
created: YYYY-MM-DD
source: claude-code-session
project: <current working directory basename>
---

<note content>
```

3. Use a kebab-case filename derived from the title.

4. If the note relates to an existing memory or vault file, add `[[wikilinks]]` to connect them.

5. Confirm the file was created and its path.

The vault lives at `$VAULT_PATH`. Prefer `projects/<project-name>/` for project-specific notes, `daily/` for daily entries, or the vault root for general notes.
