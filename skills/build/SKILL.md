---
name: build
description: Execution - read the open, unblocked slices from the configured tracker and implement them with TDD. Default is sequential, one slice at a time, in the main agent. Worktree isolation and parallel AFK dispatch are opt-in.
disable-model-invocation: true
argument-hint: "[feature-slug] [--worktree] [--parallel]"
---

# groundwork:build

Implement the slices `to-issues` created - or, for issues `/groundwork:triage` marked `ready-for-agent`/`ready-for-human` with no PRD behind them, implement straight from their Agent Brief. The default path is deliberately simple: one slice at a time, in this conversation, using TDD. Worktrees and parallel sub-agents are opt-in flags, not defaults - reach for them when the user asks, not automatically.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, tell the user to run `/groundwork:setup` first and stop.

## 1. Read the open, unblocked slices

Pull from the configured tracker:

- `github`: `gh issue list`, filtered to open issues not marked `Blocked by` an issue that's still open.
- `linear`: query via the Linear MCP tools for open issues in this feature whose blockers are resolved.
- `local`: parse `docs/groundwork/features/NNNN-slug/tasks.md` for slices with `Status: open` whose `Blocked-by` slices are already `Status: done`.

If this repo also uses `/groundwork:triage`, the tracker will contain raw inbound issues too - ones still sitting in `needs-triage`, `needs-info`, or otherwise not yet through the triage state machine. Skip anything without a `Type: AFK`/`HITL` field: no `Type` means it isn't a buildable slice or Agent Brief yet, just an unprocessed report. Don't attempt to build it.

If nothing is unblocked, say so and stop - don't force a blocked slice through.

An open issue is workable whether it came from `to-issues` (a `- Type: AFK`/`HITL` line in the issue body, pointing back to a `prd.md`) or from `/groundwork:triage` (a `**Type:** AFK`/`HITL` line inside its own Agent Brief comment, with no PRD at all) - the format differs, but both carry a `Type` field somewhere in the issue, so look for it in whichever place applies and treat the two sources identically from here on.

## 2. Default: sequential, one slice at a time

For each unblocked slice, in order:

1. Read the slice's acceptance criteria - from `prd.md` if it's a `to-issues` slice, or from its own Agent Brief comment if `/groundwork:triage` created it directly - and the relevant ADR sections.
2. Use the `groundwork:tdd` technique to implement it: a failing test per acceptance criterion first, minimal code to pass, then refactor.
3. Mark the slice done in the tracker (close the issue, or set `Status: done` in `tasks.md`) once its tests pass.
4. Move to the next unblocked slice.

This runs entirely in the main agent, no worktree, no sub-agents, unless a flag below is given.

## 3. Opt-in: `--worktree`

Isolate each slice with the `groundwork:worktree` technique: one slice, one worktree, one branch, cleanly mappable to one PR. Still sequential in the main agent unless combined with `--parallel`.

## 4. Opt-in: `--parallel`

Dispatch every independent `AFK` slice (no unresolved blockers, not tagged `HITL`) to a separate `groundwork:slice-builder` agent, each isolated in its own worktree - this implies worktree isolation per dispatched slice even without also passing `--worktree`. Dispatch them concurrently. `HITL` slices, and any slice still blocked, stay sequential in the main agent regardless of `--parallel` - don't hand a slice that needs a human decision to an unattended sub-agent.

After the parallel dispatch returns, review each agent's summary before marking its slice done - a returned summary is not itself confirmation the slice is correct.

## 5. When reality forces a deviation

If implementing a slice reveals that the PRD or an accepted ADR is wrong, incomplete, or contradicted by what you're finding, **stop and log it rather than silently diverging**. Tell the user exactly what conflicts and why, and wait for a decision (update the PRD/ADR via `/groundwork:grill`, or explicitly accept the deviation) before continuing that slice. Never quietly implement something different from what the PRD or an accepted ADR says.

## 6. Hand off

Once the slices in scope for this pass are done, suggest `/groundwork:validate` to check the Definition of Done, or `/groundwork:code-review` to review the diff. Suggest `/groundwork:handoff` if stopping mid-feature.
