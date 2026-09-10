# Assertion helpers for tests/run.sh. Sourced, not executed.

PASS=0
FAIL=0
CURRENT_GROUP=""

group() {
  CURRENT_GROUP="$1"
  printf '\n%s\n' "$CURRENT_GROUP"
}

pass() {
  PASS=$((PASS + 1))
  printf '  ok   %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  FAIL %s\n' "$1"
  [ $# -gt 1 ] && shift && printf '       %s\n' "$@"
  return 0
}

# check_empty <description> <findings>
# Passes when <findings> is empty; fails and prints every offending line.
#
# Findings are passed as an argument, never piped in: a function on the right
# of a pipe runs in a subshell, so its FAIL increment would be discarded and
# the assertion could never fail. Call it as:
#     check_empty "desc" "$(some | pipeline || true)"
check_empty() {
  desc="$1"
  found="$2"
  if [ -z "$found" ]; then
    pass "$desc"
  else
    fail "$desc"
    printf '%s\n' "$found" | sed 's/^/       /'
  fi
}

report() {
  printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
  [ "$FAIL" -eq 0 ] || return 1
}
