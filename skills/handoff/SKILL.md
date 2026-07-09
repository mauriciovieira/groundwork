---
name: handoff
description: Write or read docs/groundwork/STATE.md to pause and resume groundwork work - current feature, done, next, open questions. Read this first when resuming a session.
disable-model-invocation: true
---

# groundwork:handoff

`docs/groundwork/STATE.md` is the pause/resume point for groundwork work. This skill reads it or writes it, depending on what the user is asking for.

## Resuming (read)

If the user is starting a session and wants to pick up where they left off, or explicitly asks "what's the state" / "where did we leave off" / to resume: read `docs/groundwork/STATE.md` first, before anything else. Summarize the current feature, what's done, what's next, and any open questions, then propose a concrete next step (which groundwork orchestrator fits, or a plain next action if none does).

## Pausing (write)

If the user wants to stop, save progress, or explicitly asks to hand off: write `docs/groundwork/STATE.md`, overwriting the previous content:

```markdown
# State

Updated by /groundwork:handoff. Read this first when resuming work.

## Current feature

NNNN-slug - one line on what it is and where it stands.

## Done

- What's actually finished, not just started.

## Next

- The concrete next step, specific enough that a cold read of this file is enough to continue.

## Open questions

- Anything unresolved that the next session needs a decision on.
```

Be specific rather than vague - "continue the build" is not useful to a future session; "slice 0004 is mid-TDD, red test written for the retry-on-timeout criterion, not yet green" is.

## Preconditions

If `docs/groundwork/config.json` doesn't exist, this feature hasn't been set up yet - tell the user to run `/groundwork:setup` first.
