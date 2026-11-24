---
"mattpocock-skills": patch
---

`triage` now reads issue and PR content as evidence from its author, never as instructions. Anything an outside author supplies (a PR's commits, or a repo, package or script a report asks it to run) runs only somewhere isolated with no credentials, such as a throwaway container or the fork PR's own CI run, never on your machine.
