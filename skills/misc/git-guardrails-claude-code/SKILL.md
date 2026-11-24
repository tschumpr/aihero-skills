---
name: git-guardrails-claude-code
description: Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in Claude Code.
---

# Setup Git Guardrails

Sets up a PreToolUse hook that intercepts and blocks dangerous git commands before Claude executes them, from both the Bash and PowerShell tools.

## What Gets Blocked

- `git push` (all variants including `--force`)
- `git reset --hard` (also shortened, like `--har`)
- `git clean` with `-f` in any flag group (`-f`, `-fd`, `-xdf`) or `--force` (also shortened)
- `git branch -D`
- `git checkout .` / `git checkout -- .` / `git restore .`

Before matching, the hook reads `git.exe` as `git`, joins `\` line continuations, squeezes whitespace, and drops git's global options (`-C`, `-c`, `--git-dir`, `--work-tree`, `--namespace`, `--no-pager` and the like, quoted values included). When blocked, Claude sees a message telling it that it does not have authority to access these commands.

The hook fails closed: when `jq` is missing, the input won't parse, or a pattern is invalid, it blocks every command with a message saying why.

It guards against accidents, not a determined agent: an alias, a script, `sh -c`, or any spelling not listed above still gets past it. Tell the user that, and that branch protection on the server is what really stops a push to an important branch.

## Steps

### 1. Ask scope

Ask the user: install for **this project only** (`.claude/settings.json`) or **all projects** (`~/.claude/settings.json`)?

### 2. Copy the hook script

The bundled script is at: [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh)

Copy it to the target location based on scope:

- **Project**: `.claude/hooks/block-dangerous-git.sh`
- **Global**: `~/.claude/hooks/block-dangerous-git.sh`

Make it executable with `chmod +x`.

### 3. Add hook to settings

Add to the appropriate settings file:

**Project** (`.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|PowerShell",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

**Global** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|PowerShell",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

If the settings file already exists, merge the hook into the existing `hooks.PreToolUse` array. Don't overwrite other settings.

### 4. Ask about customization

Ask if user wants to add or remove any patterns from the blocked list. Edit the copied script accordingly. Patterns are extended regular expressions matched against the normalized command, so an unbalanced `(` blocks everything: the step 5 test catches it.

### 5. Verify

Run a quick test:

```bash
echo '{"tool_input":{"command":"git -C . push origin main"}}' | <path-to-script>; echo "exit $?"
echo '{"tool_input":{"command":"git status"}}' | <path-to-script>; echo "exit $?"
```

The first should exit with code 2 and print a BLOCKED message to stderr; the second should exit 0. If both exit 2 with "Is jq installed?", install `jq` first.
