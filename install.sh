#!/bin/sh
# Install groundwork's skills where non-Claude agents look for them.
#
# Claude Code users do not need this: install the plugin from the marketplace
# instead. This script is for Codex, opencode, Prime Agent, Gemini CLI, and
# anything else that reads ~/.agents/skills.
#
# Usage:
#   ./install.sh              symlink every skill into ~/.agents/skills
#   ./install.sh --dry-run    print what would happen, change nothing
#   ./install.sh --uninstall  remove only the symlinks pointing back here
set -eu

SRC=$(CDPATH= cd -- "$(dirname -- "$0")/skills" && pwd)
DEST="${GROUNDWORK_SKILLS_DIR:-$HOME/.agents/skills}"
DRY=0
MODE=install

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    --uninstall) MODE=uninstall ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

say() { [ "$DRY" -eq 1 ] && echo "would $*" || echo "$*"; }

installed=0
skipped=0
shared=0

for dir in "$SRC"/*/; do
  name=$(basename "$dir")
  target="$DEST/$name"

  # Underscore directories are not skills - they hold shared references the
  # skills point at as ../_runtime/ and ../_shared/. They still have to be
  # linked: an agent that resolves that path textually looks for a sibling of
  # the installed skill, and finds nothing if only skills were linked. Counted
  # apart so the summary does not call them skills.
  is_shared=0
  case "$name" in _*) is_shared=1 ;; esac

  if [ "$MODE" = uninstall ]; then
    if [ -L "$target" ] && [ "$(readlink "$target")" = "${dir%/}" ]; then
      say "remove $target"
      [ "$DRY" -eq 1 ] || rm "$target"
      installed=$((installed + 1))
    fi
    continue
  fi

  if [ -L "$target" ]; then
    current=$(readlink "$target")
    if [ "$current" = "${dir%/}" ]; then
      skipped=$((skipped + 1))
      continue
    fi
    echo "skip $name: symlink already points elsewhere ($current)" >&2
    skipped=$((skipped + 1))
    continue
  fi

  if [ -e "$target" ]; then
    echo "skip $name: a real file or directory is already there - not overwriting" >&2
    skipped=$((skipped + 1))
    continue
  fi

  say "link $target -> ${dir%/}"
  if [ "$DRY" -eq 0 ]; then
    mkdir -p "$DEST"
    ln -s "${dir%/}" "$target"
  fi
  if [ "$is_shared" -eq 1 ]; then
    shared=$((shared + 1))
  else
    installed=$((installed + 1))
  fi
done

if [ "$MODE" = uninstall ]; then
  echo "removed $installed symlink(s) from $DEST"
else
  echo "linked $installed skill(s) into $DEST, skipped $skipped"
  [ "$shared" -gt 0 ] && echo "plus $shared shared reference director(ies) the skills point at"
  echo "_runtime/RUNTIMES.md documents what groundwork needs from a runtime."
fi
