---
name: quick
description: Explicit escape hatch - do a trivial task directly, no PRD, ADR, or issues. Optionally logs one line to docs/groundwork/quicklog.md.
disable-model-invocation: true
---

# groundwork:quick

The point of this skill is to do less, not more. When the user invokes it, just do the task with normal engineering judgment - no PRD, no ADR, no issue breakdown, no interview. If another groundwork skill suggested this as the right move for a trivial request, that suggestion was correct: honor it by staying light.

## Do the task

Implement whatever was asked directly. Use whatever tools and process the task actually needs - tests where they make sense, nothing ceremonial beyond that.

## Optionally log it

After finishing, ask (or just do it, if the user already said they want a trail) whether to append one line to `docs/groundwork/quicklog.md`:

```markdown
- 2026-07-09: one-line description of what was done.
```

Create the file with a one-line header if it doesn't exist yet. Skip this entirely for genuinely throwaway asks - the log is for a lightweight trail of small work, not a requirement.

Do not create `docs/groundwork/config.json` or any feature directory from this skill. If the user is using `quick` a lot for work that's clearly growing beyond "trivial," say so and point back at `/groundwork:brainstorm` or `/groundwork:to-prd`.
