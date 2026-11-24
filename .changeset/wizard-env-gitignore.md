---
"mattpocock-skills": patch
---

Wizards from `wizard` now stop before writing to a `.env` that git would commit, including through a symlink or when git can't tell. They no longer copy `.env` (secrets included) to a temp file while updating it, and they stop rather than lose saved values when `.env` holds unusual bytes or can't be read.
