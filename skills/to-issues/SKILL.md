---
name: to-issues
description: Break prd.md and adr/ (or a plan passed as argument) into tracer-bullet vertical slices, tag each HITL or AFK, build the dependency graph, and create them in the configured tracker.
disable-model-invocation: true
argument-hint: "[feature-slug]"
---

# groundwork:to-issues

Turn a plan into independently-gradable work items: tracer-bullet vertical slices, dependency-ordered, created in whatever tracker this repo is configured for.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, tell the user to run `/groundwork:setup` first and stop.

## 1. Implementation-readiness preflight

`/groundwork:survey` should already have checked this, but repeat it here as a defensive backstop - features can reach `to-issues` by a path that skipped or shortcut `survey` (e.g. straight from `/groundwork:to-prd`).

- `project_type` **missing entirely** from config (written before this check existed) -> **stop here**, but don't send this case to `survey` - the fix is `/groundwork:setup`, re-run so it can detect and record `project_type`/`detected_stack`, then come back to `to-issues`.
- `project_type: "existing"` but `detected_stack` missing or empty (malformed config, or a `setup` run that didn't complete) -> **stop here**. Don't proceed on a guess - tell the user to re-run `/groundwork:setup` to populate `detected_stack`, then come back.
- `project_type: "existing"` in config, with a `detected_stack` recorded -> satisfied, continue.
- `project_type: "greenfield"` -> look for one or more **accepted** ADRs under the project-wide `docs/groundwork/adr/` (not this feature's own `adr/` - stack decisions are project-wide, per `survey`) that cover, at minimum: application framework/runtime, frontend approach (if applicable), persistence/backend, authentication, deployment assumptions that affect implementation, and whether background processing or a message bus is required.
- `project_type: "greenfield"` recorded but no such ADRs exist -> **stop here**. Do not slice, do not create any issues, and do not choose a stack yourself to get past this. Tell the user to run `/groundwork:survey` on this feature to settle the stack first, then come back.

Never invent or default a stack to unblock issue creation. An unresolved stack is a stop condition, not something to guess past.

## 2. Gather the input

By default, read `docs/groundwork/features/NNNN-slug/prd.md` and every file under its `adr/`. If the user passed a plan directly instead (as an argument or pasted into the conversation), use that. Either way, make sure you understand the acceptance criteria and any accepted architectural decisions before slicing - re-read anything unclear rather than guessing.

## 3. Slice into tracer bullets

A slice cuts **end-to-end through every layer it touches** - schema, API, UI, tests, whatever the feature actually spans. Never carve out a horizontal slice that's just "the database layer" or just "the UI" with nothing working behind it. Prefer many thin slices over a few thick ones: a slice that can't ship and be verified on its own is too big.

Order doesn't matter yet at this stage - focus on getting the cuts right. Sequencing happens in the dependency graph below.

## 4. Tag each slice

For every slice, work out:

- **Title**: short, specific, describes the end-to-end capability it adds.
- **Type**: `HITL` (needs a human decision or review mid-flight - touches something irreversible, ambiguous, or outside what the PRD/ADRs already decided) or `AFK` (mergeable without a human in the loop, because the PRD and ADRs already say enough to build and verify it alone). **Prefer AFK.** Only mark `HITL` when there's a concrete reason a human has to be involved, not by default caution.
- **Blocked-by**: which other slices must land first, if any.
- **Covers**: which user stories or acceptance criteria from the PRD this slice satisfies.

## 5. Present and quiz

Show the user the full breakdown as a numbered list (Title, Type, Blocked-by, Covers) before creating anything. Then ask about granularity ("is any of these too big, too small, or wrong to cut here?") and about the dependency graph ("did I get the blocking order right?"). Iterate on the list until the user approves it - don't create issues from a list they haven't confirmed.

## 6. Create the items

Once approved, create the items in dependency order (blockers before what they block), in the tracker named by `config.json`'s `tracker` field. The slicing, tagging, and quiz above are identical regardless of destination - only this step differs:

- **`github`**: create each with `gh issue create --title "..." --body "..."`, applying any `triage_labels` from config. Put Type, Blocked-by (as `Blocked by #<number>`, filled in once the blocking issue exists), and Covers in the issue body. Cross-reference by issue number.
- **`linear`**: use the Linear MCP tools if connected (check via a tool search if unsure what's available); otherwise tell the user what's missing rather than guessing at an API call. Set the same fields; if the tracker doesn't support a native blocking relation through the tools available, put `Blocked by <identifier>` in the description instead.
- **`local`**: append each slice to `docs/groundwork/features/NNNN-slug/tasks.md` as:

  ```markdown
  ## Slice NNNN: Title

  - Type: AFK
  - Blocked-by: none
  - Covers: <acceptance criteria / user stories referenced>
  - Status: open
  ```

  Number slices with a four-digit sequence scoped to that feature's `tasks.md`, starting at `0001`.

## 7. Hand off

Report what was created and where (issue numbers/links, or the `tasks.md` path). Suggest `/groundwork:build` to start executing the unblocked slices.
