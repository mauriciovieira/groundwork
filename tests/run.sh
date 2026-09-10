#!/bin/sh
# Structural tests for the groundwork plugin.
#
# The repository is prose and JSON, so these check invariants a reader cannot
# hold in their head: that skills stay host-neutral, that every reference
# resolves, that the manifests agree, and that nothing ships in the wrong
# language or with typography this project bans.
#
# Usage: ./tests/run.sh      (from anywhere; exits non-zero on any failure)
#
# When adding an assertion, break the thing it guards and confirm the suite
# actually goes red. An assertion that cannot fail is worse than none: it reads
# as coverage while guarding nothing. The first draft of this file had eight
# such assertions, all of them piping into check_empty, which put the failure
# counter in a subshell where its increment was thrown away.
set -eu

cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
. tests/lib.sh

skill_dirs() { find skills -mindepth 1 -maxdepth 1 -type d ! -name '_*' | sort; }
tracked_text() { git ls-files '*.md' '*.json' '*.yml' '*.yaml' '*.sh'; }

# ---------------------------------------------------------------- portability

group "Host neutrality"

check_empty "skills and agents name no host environment variable" \
  "$(grep -rn 'CLAUDE_PLUGIN_ROOT\|CLAUDE_SKILL_DIR' skills agents 2>/dev/null || true)"

check_empty "skills and agents use no host slash-command syntax" \
  "$(grep -rn '/groundwork:' skills agents 2>/dev/null || true)"

check_empty "worker dispatch is described in neutral terms" \
  "$(grep -rn 'Agent tool\|subagent_type' skills agents 2>/dev/null || true)"

# ---------------------------------------------------------------- frontmatter

group "Skill frontmatter"

fm() { awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$1"; }

for dir in $(skill_dirs); do
  name=$(basename "$dir")
  file="$dir/SKILL.md"

  if [ ! -f "$file" ]; then
    fail "$name has a SKILL.md"
    continue
  fi

  declared=$(fm "$file" | sed -n 's/^name: *//p' | head -1)
  if [ "$declared" = "$name" ]; then
    pass "$name declares a name matching its directory"
  else
    fail "$name declares name '$declared', expected '$name'"
  fi

  if fm "$file" | grep -q '^description: '; then
    pass "$name has a description"
  else
    fail "$name has no description"
  fi
done

# ------------------------------------------------------------- cross-refs

group "References resolve"

# Every backticked path into skills/ must exist on disk.
check_empty "every referenced skills/ path exists" \
  "$(grep -rho '`skills/[A-Za-z0-9_./-]*`' skills agents README.md 2>/dev/null \
     | tr -d '`' | sort -u \
     | while read -r ref; do [ -e "$ref" ] || echo "missing: $ref"; done || true)"

# Every groundwork:<name> must be a real agent or a real skill.
check_empty "every groundwork:<name> resolves to an agent or a skill" \
  "$(grep -rho 'groundwork:[a-z][a-z-]*' skills agents 2>/dev/null \
     | sed 's/^groundwork://' | sort -u \
     | while read -r n; do
         [ -f "agents/$n.md" ] || [ -f "skills/$n/SKILL.md" ] || echo "unresolved: groundwork:$n"
       done || true)"

# ---------------------------------------------------------------- manifests

group "Manifests"

for m in .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json; do
  if jq -e . "$m" >/dev/null 2>&1; then
    pass "$m is valid JSON"
  else
    fail "$m is not valid JSON"
  fi
done

v_claude=$(jq -r '.version' .claude-plugin/plugin.json)
v_market=$(jq -r '.plugins[0].version' .claude-plugin/marketplace.json)
v_codex=$(jq -r '.version' .codex-plugin/plugin.json)
if [ "$v_claude" = "$v_market" ] && [ "$v_claude" = "$v_codex" ]; then
  pass "all three manifests report version $v_claude"
else
  fail "manifest versions differ: claude=$v_claude marketplace=$v_market codex=$v_codex"
fi

# The Codex manifest schema requires these; a missing one fails ingestion.
for field in name version description author.name interface.displayName \
             interface.shortDescription interface.longDescription \
             interface.developerName interface.category interface.capabilities; do
  if jq -e ".$field" .codex-plugin/plugin.json >/dev/null 2>&1; then
    pass "codex manifest has $field"
  else
    fail "codex manifest is missing required field $field"
  fi
done

# The release workflow must bump and stage every manifest carrying a version.
for m in '.claude-plugin/plugin.json' '.claude-plugin/marketplace.json' '.codex-plugin/plugin.json'; do
  if grep -q "git add.*$m" .github/workflows/release.yml; then
    pass "release stages $m"
  else
    fail "release does not stage $m - its version would drift"
  fi
done

# ---------------------------------------------------------------- typography

group "Typography"

# This project bans the punctuation glyphs that mark machine-written prose.
# The glyphs are named by codepoint rather than pasted, so this file does not
# trip its own check. -CSD is required: without it perl reads bytes and a
# chr() above 255 can never match.
GLYPHS=$(perl -CSD -ne '
  my @bad = (
    [0x2014,"em dash"], [0x2013,"en dash"], [0x2011,"non-breaking hyphen"],
    [0x201C,"left curly quote"], [0x201D,"right curly quote"],
    [0x2018,"left curly apostrophe"], [0x2019,"right curly apostrophe"],
    [0x2026,"ellipsis"], [0x00A0,"non-breaking space"], [0x2009,"thin space"],
    [0x200B,"zero-width space"], [0x2022,"bullet"], [0x00B7,"middle dot"],
    [0x2192,"right arrow"], [0x21D2,"double arrow"],
  );
  for my $b (@bad) {
    print "$ARGV:$.: $b->[1]\n" if index($_, chr($b->[0])) >= 0;
  }
' $(tracked_text) 2>/dev/null || true)
check_empty "no banned punctuation glyphs in tracked files" "$GLYPHS"

# ------------------------------------------------------------------ language

group "Language"

# Everything versioned here is English. Artifacts groundwork generates at
# runtime follow the conversation's language, but those are not in this repo.
# High-signal Portuguese words only, to keep false positives near zero.
check_empty "no Portuguese in tracked files" \
  "$(grep -rniwE 'n(a|A)o|voc(e|E)|s(a|A)o|est(a|A)|ent(a|A)o|tamb(e|E)m|porqu(e|E)|isso|aquilo' \
     $(tracked_text) 2>/dev/null || true)"

check_empty "no Portuguese word endings in tracked files" \
  "$(perl -CSD -ne 'print "$ARGV:$.: $&\n" if /\w+(\x{e7}\x{e3}o|\x{e7}\x{f5}es|\x{e3}o|\x{f5}es)/' \
     $(tracked_text) 2>/dev/null || true)"

# --------------------------------------------------------------------- README

group "README stays in step"

# Disciplines are covered in prose, not the command table; everything else
# must be listed, or a reader cannot discover it.
for dir in $(skill_dirs); do
  name=$(basename "$dir")
  case "$name" in interview-loop|tdd|worktree) continue ;; esac
  if grep -q "\`/groundwork:$name\`" README.md; then
    pass "README lists $name in the command table"
  else
    fail "README does not list $name"
  fi
done

report
