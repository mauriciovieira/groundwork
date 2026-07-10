---
name: validate
description: Lightweight Definition-of-Done gate - check that every acceptance criterion has a passing test, every slice is done or explicitly deferred, and no accepted ADR is violated. Reports pass/fail with specific gaps.
disable-model-invocation: true
argument-hint: "[feature-slug]"
---

# groundwork:validate

A gate, not a test-writing skill. Check whether a feature actually meets its own Definition of Done and report exactly what's missing - never just a pass/fail with no detail.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, tell the user to run `/groundwork:setup` first and stop.

## 1. Check acceptance criteria

For every acceptance criterion in `docs/groundwork/features/NNNN-slug/prd.md`, find whether a test actually exercises it. Run the test suite; don't take a test's existence on faith if you can execute it. Report each criterion as covered, uncovered, or covered-but-failing.

## 2. Check slice status

Read the slices from the configured tracker (open/closed issues, or `tasks.md` statuses). Every slice from `to-issues` should be `done` or explicitly `deferred` with a stated reason. Flag any slice that's neither - stuck open with no explanation, or silently abandoned.

## 3. Check ADR compliance

For every `Accepted` ADR under the feature's `adr/`, and any relevant `Accepted` ADR under the system-wide `docs/groundwork/adr/` (written by `improve-codebase-architecture`, or by `survey` for implementation-stack decisions), do a best-effort check that the current code doesn't contradict its Decision. This can't be exhaustive - look for obvious violations (an ADR mandates one approach and the code visibly does something else), not subtle ones. Say plainly when you can't verify something rather than asserting compliance you didn't check.

## 4. Report

Give a pass/fail per acceptance criterion, per slice, and per ADR, not just an overall verdict. For anything that fails, say exactly what's missing and where. If everything passes, say so clearly and suggest `/groundwork:code-review` as the next step before merging.
