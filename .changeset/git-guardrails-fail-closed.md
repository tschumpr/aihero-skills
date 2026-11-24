---
"mattpocock-skills": patch
---

The `git-guardrails-claude-code` hook now fails closed (when `jq` is missing, the input won't parse, or a pattern is invalid), covers the PowerShell tool, and catches more spellings: `git.exe`, global options like `-C` and `--work-tree`, line continuations, and shortened options like `--har`.
