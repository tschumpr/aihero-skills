#!/bin/bash
# PreToolUse hook that blocks destructive git commands. It catches accidents,
# not a determined agent (aliases, scripts and odd spellings get past it), so
# protect important branches on the server too. Any failure blocks the command.
set -o pipefail

block() {
  echo "BLOCKED: $1" >&2
  exit 2
}

COMMAND=$(jq -er '.tool_input.command' 2>/dev/null) ||
  block "block-dangerous-git.sh could not read the command. Is jq installed?"

# Join line continuations, squeeze whitespace, and drop git's global options, so
# `"git.exe" -C "my dir" --no-pager \<newline> push` reads as `git push`.
BSNL=$'\\\n'
VALUE="(\"[^\"]*\"|'[^']*'|[^ ]+)"
TAKES_VALUE='-[Cc]|--(git-dir|work-tree|namespace|config-env|attr-source)'
NORMALIZED=$(printf '%s' "${COMMAND//"$BSNL"/ }" | tr -s '[:space:]' ' ' |
  sed -E "s/git(\\.exe)?[\"']?( ($TAKES_VALUE) $VALUE| -[^ ]+)*/git/g") ||
  block "block-dangerous-git.sh could not normalize the command."

ARGS='( [^ ;&|]+)*' # any arguments of one command, never past a ; & or |
END='([ ;&|]|$)'    # end of an option; git also accepts unique prefixes like --har

DANGEROUS_PATTERNS=(
  "git push"
  "git reset$ARGS --h(a(rd?)?)?$END"
  "git clean$ARGS (-[a-zA-Z]*f|--f(o(r(ce?)?)?)?$END)"
  "git branch$ARGS -D"
  "git (checkout|restore)$ARGS \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  rc=0
  grep -qE -- "$pattern" <<< "$NORMALIZED" || rc=$?
  (( rc == 0 )) && block "'$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this."
  (( rc == 1 )) || block "pattern '$pattern' in block-dangerous-git.sh is invalid, so every command is blocked until it's fixed."
done

exit 0
