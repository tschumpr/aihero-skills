---
"mattpocock-skills": patch
---

The GitHub and GitLab issue-tracker templates from `setup-matt-pocock-skills` now have the agent write issue titles, bodies and comments to temp files and pass the files, instead of typing the text into a shell command, so backticks, `$(...)` or quotes in issue text can no longer run as commands. The GitLab template also quotes outside text as a blockquote, so a line like `/merge` from a reporter can't run as a quick action. Re-run setup to refresh `docs/agents/issue-tracker.md`.
