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
# Every tracked file, not a list of extensions: NOTICE, LICENSE, .gitignore and
# skills/verify/templates/control (a shebang script with no .sh suffix) are all
# tracked text that an extension list silently excused from every check below.
# Binary files are skipped rather than assumed absent.
tracked_text() {
  git ls-files | while IFS= read -r f; do
    [ -f "$f" ] && perl -e 'exit(-B $ARGV[0] ? 1 : 0)' "$f" && printf '%s\n' "$f"
  done
}

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
# Relative sibling references (../_runtime/, ../_shared/) resolve against the
# directory of the file citing them, which is what makes them work both inside
# a plugin tree and in a flat ~/.agents/skills install.
check_empty "every ../ sibling reference resolves from its own file" \
  "$(grep -rno '`\.\./_[A-Za-z0-9_./-]*`' skills 2>/dev/null \
     | while IFS=: read -r file _ ref; do
         ref=$(printf '%s' "$ref" | tr -d '`')
         dir=$(dirname "$file")
         [ -e "$dir/$ref" ] || echo "missing: $ref (cited by $file)"
       done || true)"

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

# --------------------------------------------------------------------- verify

group "Verification templates"

for f in verify-README.md features-README.md feature.md control; do
  if [ -f "skills/verify/templates/$f" ]; then
    pass "verify ships a $f template"
  else
    fail "verify is missing its $f template"
  fi
done

if [ -x skills/verify/templates/control ]; then
  pass "the control template is executable"
else
  fail "the control template is not executable - the copy would lose the bit"
fi

if sh -n skills/verify/templates/control 2>/dev/null; then
  pass "the control template parses as sh"
else
  fail "the control template does not parse"
fi

# The skeleton is useless if a subcommand named in SKILL.md has no branch in it.
for cmd in launch doctor drive prove clean; do
  if grep -q "^  $cmd)" skills/verify/templates/control; then
    pass "control handles $cmd"
  else
    fail "control has no branch for $cmd, which SKILL.md requires"
  fi
done

# An unimplemented subcommand must fail loudly. A branch that falls through and
# exits 0 reports success for work nobody did - the exact failure this skill
# exists to prevent, shipped inside its own template.
# Match the "not implemented" die specifically, not any die: drive and prove
# also carry an argument guard, and grepping for a bare `die` would accept a
# branch whose terminal failure had been deleted.
for cmd in launch doctor drive prove clean; do
  if awk "/^  $cmd\\)/,/^    ;;/" skills/verify/templates/control \
     | grep -q "$cmd is not implemented yet"; then
    pass "control's $cmd branch fails loudly until implemented"
  else
    fail "control's $cmd branch can exit 0 without doing anything"
  fi
done

# ------------------------------------------------------------------- the loop

group "The verification loop is wired"

# to-issues has to emit the two fields build reads, or build has nothing to act on.
for field in "Finish-condition" "Verifies"; do
  if grep -q "$field" skills/to-issues/SKILL.md; then
    pass "to-issues defines $field"
  else
    fail "to-issues does not define $field, which build reads"
  fi
done

for field in "Finish-condition" "Verifies"; do
  if grep -q "$field" skills/build/SKILL.md; then
    pass "build reads $field"
  else
    fail "build ignores $field, which to-issues writes"
  fi
done

# An unproven slice needs a representation in every tracker, or the loop leaks
# on whichever one was forgotten.
if grep -q 'needs-proof' skills/build/SKILL.md; then
  pass "build has a state for a built-but-unproven slice"
else
  fail "build closes or abandons unproven slices with no third state"
fi

if grep -q 'needs-proof' skills/validate/SKILL.md; then
  pass "validate reports needs-proof slices"
else
  fail "validate cannot see a needs-proof slice"
fi

# For local, needs-proof must still be pickable, or the slice is stranded.
if grep -q 'Status: open` or `Status: needs-proof' skills/build/SKILL.md; then
  pass "build picks needs-proof slices back up on the local tracker"
else
  fail "a local needs-proof slice would never be picked up again"
fi

# The four outcomes are the point: covered-unproven must not read as a pass.
for outcome in 'covered+proven' 'covered-unproven' 'uncovered' 'failing'; do
  if grep -q -- "$outcome" skills/validate/SKILL.md; then
    pass "validate distinguishes $outcome"
  else
    fail "validate has no $outcome outcome"
  fi
done

# A PRD from inception leaves criteria as a placeholder; passing that is worse
# than failing it, because an empty gate reads as done.
if grep -q 'placeholder' skills/validate/SKILL.md; then
  pass "validate refuses a PRD whose criteria are still a placeholder"
else
  fail "validate would pass a PRD with no acceptance criteria"
fi

# The gate has to hand work back, or a failure is a dead end.
if grep -q 'back into `build`' skills/validate/SKILL.md; then
  pass "validate hands a gap list back to build"
else
  fail "validate stops on failure with no way back into build"
fi

# The parallel worker must carry the same contract as the sequential path.
if grep -q 'groundwork:verify' agents/slice-builder.md; then
  pass "slice-builder proves its own slice"
else
  fail "slice-builder can report success on tests alone"
fi

# --------------------------------------------------------------- cross-judging

group "Nothing grades its own homework"

for f in skills/_shared/COMPETING-DESIGNS.md agents/design-judge.md agents/review-judge.md; do
  if [ -f "$f" ]; then
    pass "$f exists"
  else
    fail "$f is missing"
  fi
done

# Criteria fixed after seeing candidates rationalise a preference already formed.
if grep -q 'before you see any candidate' skills/_shared/COMPETING-DESIGNS.md; then
  pass "criteria are fixed before any candidate exists"
else
  fail "nothing stops criteria being written after the candidates"
fi

# A judge told who wrote what is not blind. Anchor on a phrase that markdown
# emphasis cannot break up - the first version matched 'not be told' and missed
# the actual text, which reads '**not** be told'.
if grep -q 'who produced which' agents/design-judge.md; then
  pass "design-judge is kept blind to authorship"
else
  fail "design-judge could be told which worker wrote which candidate"
fi

# Both judges must be allowed to decline to pick a winner.
if grep -q 'tie is a real answer' agents/design-judge.md; then
  pass "design-judge may report a tie"
else
  fail "design-judge is forced to invent a winner"
fi

if grep -q 'unresolvable at this level' agents/review-judge.md; then
  pass "review-judge may report an unresolvable conflict"
else
  fail "review-judge is forced to pick a side"
fi

# The arbiter must be exceptional, not a routine pass over every finding.
if grep -q 'skip step 4 entirely' skills/code-review/SKILL.md; then
  pass "code-review skips arbitration when nothing contradicts"
else
  fail "code-review would arbitrate on every run"
fi

if grep -q 'not a conflict' skills/code-review/SKILL.md; then
  pass "code-review defines what is not a conflict"
else
  fail "code-review does not say what fails to count as a contradiction"
fi

# survey has to be able to reach the pattern, or it is dead prose.
if grep -q 'COMPETING-DESIGNS' skills/survey/SKILL.md; then
  pass "survey can reach the competing-designs pattern"
else
  fail "nothing routes survey into competing designs"
fi

# Judges are read-only: a judge that can edit is a participant.
for a in design-judge review-judge; do
  if fm "agents/$a.md" | grep -q 'disallowedTools: Write, Edit'; then
    pass "$a cannot write"
  else
    fail "$a can edit the work it judges"
  fi
done

# The shared reference dirs are not skills, but the installer must still link
# them or ../_runtime/ and ../_shared/ resolve to nothing on a flat install.
if grep -q 'is_shared' install.sh; then
  pass "install.sh links the shared reference directories"
else
  fail "install.sh skips _ directories, breaking every ../ reference"
fi

# ------------------------------------------------------------- understanding

group "Understanding skills stay read-only"

# These are advisory: they must fire from a plain question, so none of them may
# carry the flag that stops model invocation.
for s in why how recall; do
  if [ -f "skills/$s/SKILL.md" ]; then
    pass "$s exists"
  else
    fail "$s is missing"
    continue
  fi
  if fm "skills/$s/SKILL.md" | grep -q 'disable-model-invocation'; then
    fail "$s is flagged off model invocation, so a plain question never reaches it"
  else
    pass "$s can fire from a plain question"
  fi
done

# recall replaces a hand-maintained state file that was removed in 0.2.6. If it
# ever starts writing, it has become the thing that was deleted.
if grep -q 'writes nothing' skills/recall/SKILL.md; then
  pass "recall states that it writes nothing"
else
  fail "recall no longer promises to write nothing - it is becoming STATE.md again"
fi

# An invented rationale is worse than an admitted gap, because it gets repeated.
for grade in Decided Recorded Inferred Lost; do
  if grep -q "\*\*$grade\*\*" skills/why/SKILL.md; then
    pass "why can report a reason as $grade"
  else
    fail "why has no $grade certainty grade"
  fi
done

# how is only cheap if it starts from the feature map rather than from source.
if grep -q 'verify/features' skills/how/SKILL.md; then
  pass "how starts from the feature map"
else
  fail "how reconstructs behaviour from source instead of reading the map"
fi

# teach is how + why composed; a skill that only chains two others is noise.
if [ -d skills/teach ]; then
  fail "a teach skill exists - it is how plus why, and composes without one"
else
  pass "no teach skill: how and why compose without it"
fi

report
