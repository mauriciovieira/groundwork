---
name: validate
description: Use when a groundwork feature's implementation looks finished, or the user asks "is it done", "ready to merge", or "does it meet the spec". Definition-of-Done gate - checks every acceptance criterion has a passing test, every slice is done or explicitly deferred, and no accepted ADR is violated. Reports pass/fail with specific gaps.
argument-hint: "[feature-slug]"
---

# groundwork:validate

A gate, not a test-writing skill. Check whether a feature actually meets its own Definition of Done and report exactly what's missing - never just a pass/fail with no detail.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, don't stop - bootstrap it per the "Lazy bootstrap" section of the groundwork `setup` skill: detect tracker and project type, write the config with defaults, state the assumptions in one line, and continue. Running `setup` explicitly is only for customizing.

## 1. Check the PRD actually states criteria

Open `docs/groundwork/features/NNNN-slug/prd.md` and find its acceptance criteria. A PRD written by `inception` deliberately leaves that section as a placeholder for `survey` to fill in.

If the section is missing, empty, or still a placeholder, **stop here and say so**. A feature with no stated criteria cannot pass this gate, and reporting a pass over an empty list is the worst outcome available: it reads as done. Send the user to `survey` to state the criteria, and do not continue to step 2.

## 2. Check acceptance criteria

For every acceptance criterion, ask two separate questions.

**Is it tested?** Find whether a test actually exercises it. Run the test suite; don't take a test's existence on faith if you can execute it.

**Is it proven?** If the config has a `verify` block, check that the criterion has observable evidence behind it - a verification that drove the running application and captured what happened, posted to the slice that covers this criterion. A passing test is the code agreeing with itself; evidence is the product being watched doing the thing.

Report each criterion as exactly one of:

- **`covered+proven`** - a passing test and posted evidence
- **`covered-unproven`** - a passing test, no evidence. Not a pass
- **`uncovered`** - no test exercises it
- **`failing`** - a test exercises it and does not pass

Where the repository has no `verify` block at all, every criterion is `covered-unproven` - there is no way to prove any of them. Say that once, as one fact about the repository rather than once per criterion, and name `verify --init` as what fixes it. Do not invent a softer outcome for this case: a feature nobody can demonstrate is not a feature anybody has finished, and a repository without verification is the case most likely to be quietly certified for years.

## 3. Check slice status

Read the slices from the configured tracker. Where a slice's status lives differs, and `needs-proof` is the case that is easy to miss: on `github` and `linear` it is a comment on an issue that is still open, not a field, so read the comments rather than only the open/closed state. On `local` it is a `Status:` value in `tasks.md` alongside `open` and `done`. Every slice from `to-issues` should be `done` or explicitly `deferred` with a stated reason. Flag any slice that's neither - stuck open with no explanation, or silently abandoned. A slice marked `needs-proof` is its own outcome: built, but never shown working. Report those separately from open slices, because the fix is different - they need a verification run, not implementation.

Check each slice's `Finish-condition` against reality too. A closed slice whose finish condition is not actually met was closed early.

## 4. Check ADR compliance

For every `Accepted` ADR under the feature's `adr/`, and any relevant `Accepted` ADR under the system-wide `docs/groundwork/adr/` (written by `improve-codebase-architecture`, or by `survey` for implementation-stack decisions), do a best-effort check that the current code doesn't contradict its Decision. This can't be exhaustive - look for obvious violations (an ADR mandates one approach and the code visibly does something else), not subtle ones. Say plainly when you can't verify something rather than asserting compliance you didn't check.

## 5. Report, and close the loop

Give a verdict per acceptance criterion, per slice, and per ADR, not just an overall one. For anything that fails, say exactly what's missing and where.

**If everything passes**, say so clearly and continue straight into `code-review` before merging.

**If this repository has no verification at all**, the gate does not pass. Report every criterion as `covered-unproven`, say plainly that nothing here can be demonstrated, and point at `verify --init`. This is the one failure the user can close in a single step, and it is also the one they are most likely to want waved through - do not wave it through. `build` deliberately does not block on this, so the gate is the only place it is ever caught.

**If anything failed**, don't just stop. Say what would close each gap, and offer to go back into `build` with that exact list - uncovered criteria need tests, `covered-unproven` ones need a verification run, `needs-proof` slices need evidence, and a failing test needs a fix. Hand the list over rather than making the user reconstruct it. Review waits until the gaps are closed.

Never report an overall pass because most things passed. This gate exists to be the one place that says no.
