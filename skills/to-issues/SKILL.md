---
name: to-issues
description: Break prd.md and adr/ (or a plan passed as argument) into tracer-bullet vertical slices, tag each HITL or AFK, build the dependency graph, and create them in the configured tracker.
disable-model-invocation: true
argument-hint: "[feature-slug]"
---

# groundwork:to-issues

Turn a plan into independently-gradable work items: tracer-bullet vertical slices, dependency-ordered, created in whatever tracker this repo is configured for.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, don't stop - bootstrap it per the "Lazy bootstrap" section of the groundwork `setup` skill: detect tracker and project type, write the config with defaults, state the assumptions in one line, and continue. Running `setup` explicitly is only for customizing.

## 1. Implementation-readiness preflight

`survey` should already have checked this, but repeat it here as a defensive backstop - features can reach `to-issues` by a path that skipped or shortcut `survey` (e.g. straight from `to-prd`).

- `project_type` **missing entirely** from config, or `"existing"` with `detected_stack` missing or empty -> backfill it in place: run the same implementation-status detection the Lazy bootstrap uses (setup's step 2 - record only what's actually found, never a guess), merge just those fields into the existing config, tell the user in one line, and continue with the cases below.
- `project_type: "existing"` in config, with a `detected_stack` recorded -> satisfied, continue.
- `project_type: "greenfield"` -> look for one or more ADRs with `Status: Accepted` under the project-wide `docs/groundwork/adr/` (not this feature's own `adr/` - stack decisions are project-wide, per `survey`) that cover, at minimum: application framework/runtime, frontend approach (if applicable), persistence/backend, authentication, deployment assumptions that affect implementation, and whether background processing or a message bus is required.
- `project_type: "greenfield"` recorded but no such ADRs exist -> **stop here**. Do not slice, do not create any issues, and do not choose a stack yourself to get past this. Tell the user to run `survey` on this feature to settle the stack first, then come back.

Never invent or default a stack to unblock issue creation. An unresolved stack is a stop condition, not something to guess past.

## 2. Gather the input

By default, read `docs/groundwork/features/NNNN-slug/prd.md`, every file under its `adr/`, and any relevant `Accepted` ADR under the project-wide `docs/groundwork/adr/` - at minimum the stack decision(s) the preflight above validated, plus any other project-wide ADR whose Decision plausibly constrains this feature. That directory isn't only stack ADRs and grows over time, so read what's relevant, not the whole directory wholesale. If the user passed a plan directly instead (as an argument or pasted into the conversation), use that. Either way, make sure you understand the acceptance criteria and any accepted architectural decisions before slicing - re-read anything unclear rather than guessing.

## 3. Slice into tracer bullets

A slice cuts **end-to-end through every layer it touches** - schema, API, UI, tests, whatever the feature actually spans. Never carve out a horizontal slice that's just "the database layer" or just "the UI" with nothing working behind it. Prefer many thin slices over a few thick ones: a slice that can't ship and be verified on its own is too big.

Order doesn't matter yet at this stage - focus on getting the cuts right. Sequencing happens in the dependency graph below.

## 4. Tag each slice

For every slice, work out:

- **Title**: short, specific, describes the end-to-end capability it adds.
- **Type**: `HITL` (needs a human decision or review mid-flight - touches something irreversible, ambiguous, or outside what the PRD/ADRs already decided) or `AFK` (mergeable without a human in the loop, because the PRD and ADRs already say enough to build and verify it alone). **Prefer AFK.** Only mark `HITL` when there's a concrete reason a human has to be involved, not by default caution.
- **Blocked-by**: which other slices must land first, if any.
- **Covers**: which user stories or acceptance criteria from the PRD this slice satisfies.
- **Finish-condition**: the testable outcome that means this slice is done. State a result, never a duration or an amount of effort - "every caller of the old helper is gone", "the fixture round-trips", not "about half a day". If you cannot state one, the slice is not cut sharply enough yet; go back and cut it again.
- **Verifies**: which feature-map entry under `<docs_dir>/verify/features/` this slice touches, so `build` knows what to drive when it finishes. Write `none` for a slice with no user-visible behaviour (a build script, a dependency bump), and `new: <slug>` when the slice creates a feature the map does not have yet. Skip this field entirely if the repository has no `verify` block in its config.

## 5. Present and quiz

Show the user the full breakdown as a numbered list (Title, Type, Blocked-by, Covers, Finish-condition, Verifies) before creating anything. Then ask about granularity ("is any of these too big, too small, or wrong to cut here?"), about the dependency graph ("did I get the blocking order right?"), and about the finish conditions ("would each of these be unarguable when it lands?"). Iterate on the list until the user approves it - don't create issues from a list they haven't confirmed.

## 6. Create the items

Once approved, create the items in dependency order (blockers before what they block), in the tracker named by `config.json`'s `tracker` field. The slicing, tagging, and quiz above are identical regardless of destination - only this step differs:

- **`github`**: create each with `gh issue create --title "..." --body "..."`, applying any `triage_labels` from config. Put Type, Blocked-by (as `Blocked by #<number>`, filled in once the blocking issue exists), Covers, Finish-condition, and Verifies in the issue body. Cross-reference by issue number.
- **`linear`**: use the Linear MCP tools if connected (check via a tool search if unsure what's available); otherwise tell the user what's missing rather than guessing at an API call. Set the same fields; if the tracker doesn't support a native blocking relation through the tools available, put `Blocked by <identifier>` in the description instead.
- **`local`**: append each slice to `docs/groundwork/features/NNNN-slug/tasks.md` as:

  ```markdown
  ## Slice NNNN: Title

  - Type: AFK
  - Blocked-by: none
  - Covers: <acceptance criteria / user stories referenced>
  - Finish-condition: <the testable outcome that means this is done>
  - Verifies: <feature-map slug, `none`, or `new: <slug>`>
  - Status: open
  ```

  Number slices with a four-digit sequence scoped to that feature's `tasks.md`, starting at `0001`.

## 7. Hand off

Report what was created and where (issue numbers/links, or the `tasks.md` path). Then offer to continue straight into `build` on the unblocked slices - on a yes, load and follow the groundwork `build` skill in this session; an explicit invocation is never required.
