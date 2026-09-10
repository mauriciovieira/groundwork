---
name: build
description: Execution - read the open, unblocked slices from the configured tracker and implement them with TDD. Default is sequential, one slice at a time, in the main agent. Worktree isolation and parallel AFK dispatch are opt-in.
disable-model-invocation: true
argument-hint: "[feature-slug] [--worktree] [--parallel]"
---

# groundwork:build

Implement the slices `to-issues` created - or, for issues `triage` marked `ready-for-agent`/`ready-for-human` with no PRD behind them, implement straight from their Agent Brief. The default path is deliberately simple: one slice at a time, in this conversation, using TDD. Worktrees and parallel workers are opt-in flags, not defaults - reach for them when the user asks, not automatically.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, don't stop - bootstrap it per the "Lazy bootstrap" section of the groundwork `setup` skill: detect tracker and project type, write the config with defaults, state the assumptions in one line, and continue. Running `setup` explicitly is only for customizing.

Note whether the config has a `verify` block. If it does, every slice has to be proven before it closes (step 2 below). If it doesn't, say once that this repository has no verification set up, that slices will close on tests alone here, and that `validate` will refuse to pass the feature until `verify --init` has run. Then carry on. Never block a build over it - building unproven work is allowed, certifying it as done is not.

## 0.5. Verify the foundation

Before touching any code, run this repository's gates on the current state - the test suite, and `verify doctor` if a `verify` block is configured - and confirm they pass.

If they don't, **stop and report it**. Do not start a slice on a red base. Building on one makes every failure ambiguous: you cannot tell your own breakage from what was already broken, and the debugging goes to the wrong change. Offer to fix the existing breakage first, as its own work, rather than folding it into a slice that did not cause it.

If there is no runnable gate at all, say so once and continue - an absent suite is a known state, an unexamined one is not.

## 1. Read the open, unblocked slices

Pull from the configured tracker:

- `github`: `gh issue list`, filtered to open issues not marked `Blocked by` an issue that's still open. Read each candidate's comments before treating it as unbuilt: an issue carrying a `Status: needs-proof` comment is finished work waiting only on evidence, so go straight to proving it in step 3 rather than rebuilding it.
- `linear`: query via the Linear MCP tools for open issues in this feature whose blockers are resolved. Check comments for `Status: needs-proof` the same way, and for the same reason.
- `local`: parse `docs/groundwork/features/NNNN-slug/tasks.md` for slices with `Status: open` or `Status: needs-proof` whose `Blocked-by` slices are already `Status: done`. A `needs-proof` slice is built work waiting only on evidence, so pick it up again and go straight to proving it rather than rebuilding it.

If this repo also uses `triage`, the tracker will contain raw inbound issues too - ones still sitting in `needs-triage`, `needs-info`, or otherwise not yet through the triage state machine, and possibly carrying an unrelated "Type:" field of their own (many issue templates have one, e.g. "Type: bug"). Skip anything whose `Type` field isn't exactly `AFK` or `HITL` (in whichever format applies, see below) - that's the actual signal a slice or Agent Brief exists, not just the presence of some field named `Type`. Don't attempt to build it.

If nothing is unblocked, say so and stop - don't force a blocked slice through.

An open issue is workable whether it came from `to-issues` (a `Type` field valued `AFK`/`HITL` somewhere in the issue body, pointing back to a `prd.md`) or from `triage` (a `**Type:** AFK`/`HITL` line inside its own Agent Brief comment, with no PRD at all) - the exact markdown shape and location of that `Type` field isn't guaranteed to match between the two, so look for a `Type` field whose value is `AFK` or `HITL` (not just those words appearing anywhere), wherever in the issue it's written, and treat the two sources identically once found.

## 2. Default: sequential, one slice at a time

For each unblocked slice, in order:

1. Read the slice's acceptance criteria - from `prd.md` if it's a `to-issues` slice, or from its own Agent Brief comment if `triage` created it directly - and the relevant ADR sections. Read its `Finish-condition` too: that is what "done" means for this slice, and it is what step 4 is checked against.
2. Use the `groundwork:tdd` technique to implement it: a failing test per acceptance criterion first, minimal code to pass, then refactor.
3. **Prove it, if this repository has verification.** Run the `groundwork:verify` skill against the feature named in the slice's `Verifies` field. Post the evidence to the slice itself - pasted into the issue comment, or into the PR body when the slice became a PR - because a path into the gitignored `evidence/` directory means nothing to the next session. A slice whose `Verifies` field is `none` skips this; a slice whose field says `new: <slug>` needs its feature-map entry written first.
4. **Close it, or mark it unproven.** A slice closes when its tests pass, its finish condition is met, and its evidence is posted. If the tests pass but the verification did not - disproven, or the app would not run - do not close it. Record it as needing proof and move on to the next slice rather than stopping the whole build:
   - `github` and `linear`: leave the issue **open** and comment `Status: needs-proof` with what is missing. Closing is the only "done" signal these trackers have, so an unproven slice must not be closed.
   - `local`: set `Status: needs-proof` in `tasks.md`, alongside the existing `open` and `done`.
5. Move to the next unblocked slice.

At the end of the pass, run `verify --sync` if this repository has verification, so the feature map reflects what this pass actually changed. A slice that added or altered user-visible behaviour has just made the map stale, and a stale feature map is worse than none because the next verification trusts it.

Then report the slices that closed and, separately, the ones left needing proof. Never fold the two together into a count of slices "done".

This runs entirely in the main agent, no worktree, no workers, unless a flag below is given.

## 3. Opt-in: `--worktree`

Isolate each slice with the `groundwork:worktree` technique: one slice, one worktree, one branch, cleanly mappable to one PR. Still sequential in the main agent unless combined with `--parallel`.

## 4. Opt-in: `--parallel`

Hand every independent `AFK` slice (no unresolved blockers, not tagged `HITL`) to its own `groundwork:slice-builder` worker, each isolated in its own worktree - this implies worktree isolation per slice even without also passing `--worktree`. Start them all before waiting on any. `HITL` slices, and any slice still blocked, stay sequential in the main agent regardless of `--parallel` - don't hand a slice that needs a human decision to an unattended worker.

If this runtime has no worker primitive, or cannot give each worker its own worktree, build sequentially instead and say so. Parallel writers sharing one directory corrupt each other, so this fallback is mandatory rather than a preference. See `../_runtime/RUNTIMES.md`.

Each worker runs its own verification and posts the evidence to its own PR before returning, and reports the outcome as part of its summary.

Once the workers return, review each summary before marking its slice done - a returned summary is not itself confirmation the slice is correct, and a worker reporting success without evidence is exactly the case this check exists for. A slice whose worker could not prove it follows the same `needs-proof` path as the sequential case.

## 4.5. Commit atomically inside a slice

A slice is one vertical tracer bullet, but it rarely lands as one commit. Follow `../_shared/ATOMIC-CHANGES.md` for how its work reaches the history. The three rules that matter most:

- **One kind of change per commit.** A commit that refactors and adds is doing two things, and a reviewer cannot tell which half broke something.
- **Reduce before you add.** Within a slice, run remove, fix, move, rename and refactor before change and add, so the risky part lands on a base that has already been exercised.
- **Corrections go in a `fixup!` commit**, aimed at the commit that introduced the defect, not an amend. Amending hides the change before anyone can review it. Folding is a separate deliberate step, and only on request.

Each commit should leave the repository whole - passing the gates its change touches, standing alone without a follow-up to avoid a regression. That is the bound on how small a commit can be, not line count.

## 5. When reality forces a deviation

If implementing a slice reveals that the PRD or an accepted ADR is wrong, incomplete, or contradicted by what you're finding, **stop and log it rather than silently diverging**. Tell the user exactly what conflicts and why, and wait for a decision (update the PRD/ADR via `survey`, or explicitly accept the deviation) before continuing that slice. Never quietly implement something different from what the PRD or an accepted ADR says.

## 6. Hand off

Once the slices in scope for this pass are done, continue straight into `validate` to check the Definition of Done, unless the user said to stop after building. `validate` writes nothing, so don't ask first - though it does run the test suite and may run a verification, so it is not free. `validate` itself chains into `code-review` when the gate passes, and hands a gap list back here when it doesn't.
