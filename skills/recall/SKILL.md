---
name: recall
description: Use when picking work back up after a break and the context is gone - "where were we", "what was I doing on this", "catch me up". Reconstructs the state of a feature from the artifacts that already exist. Writes nothing.
argument-hint: "[feature-slug]"
---

# groundwork:recall

Rebuild the picture of where a piece of work stands, from what the repository already records.

**This skill writes nothing, deliberately.** groundwork carried a hand-maintained state file
once and removed it in 0.2.6, because a file that has to be kept current is one more thing to
forget, and a stale state file is worse than none - it is trusted. Everything below is already
being written for other reasons. Reading it costs nothing and cannot go stale in a way the
underlying artifacts have not already gone stale.

## What to read, and what each one tells you

- **`prd.md`** - what this feature is for, and its acceptance criteria. The destination.
- **`adr/`**, feature-scoped and project-wide - what was already decided and must not be
  re-opened. Check for `Superseded` entries: a reversal is exactly the thing someone returning
  after a break is most likely to miss.
- **the tracker, or `tasks.md`** - which slices are done, open, blocked, or `needs-proof`.
  This is the closest thing to a progress bar. A `needs-proof` slice is built work waiting on
  evidence, which is a very different resumption than an unstarted one.
- **`map.md` and `tickets.md`** - present when `survey` ran at map speed. The map's
  "Not yet specified" section is the live frontier: it says what is still fog.
- **`git log`** on the feature's branches, and any open PRs - what was actually done last, as
  opposed to what was planned.
- **`quicklog.md`** - small things done outside the main flow, which are the easiest to forget
  and the most likely to surprise you.

## Report

Give it in this order, because it is the order someone resuming needs:

1. **Where this was going** - one or two sentences from the PRD, not a summary of the whole file.
2. **What is settled** - accepted ADRs, in one line each. Flag any supersession.
3. **What is done** - closed slices, briefly.
4. **What is in flight** - open slices, `needs-proof` slices, open PRs, uncommitted work on a
   branch. Be specific about which of these it is; they need different next actions.
5. **What is still open** - blocked slices, the map's remaining fog, unanswered questions.
6. **The obvious next step**, if there is one, and say plainly when there isn't.

Separate what the artifacts state from what you are inferring. "The last commit touched the
parser" is a fact; "you were probably mid-refactor" is a guess, and should be labelled as one.

If the artifacts genuinely do not say where things stood, say that. The honest answer is
sometimes that the work was left in a state nobody recorded, and the fix for that is finishing
this session's work through the normal flow, not reconstructing a story.
