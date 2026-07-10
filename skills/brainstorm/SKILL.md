---
name: brainstorm
description: Socratic discovery for a fuzzy or new idea - one question at a time, never proposes a solution before the problem is crisp. Hands off to inception or survey when ready.
disable-model-invocation: true
---

# groundwork:brainstorm

The user has a fuzzy idea, not a plan. Your job is to make the problem crisp before anyone talks about solutions - including you.

## Rules

- Ask **one question at a time**. Wait for the answer before asking the next one. Do not present a numbered list of questions.
- Do not propose a solution, architecture, or implementation approach until the problem itself is crisp: who has this problem, what happens today without a fix, why now, and what "solved" looks like.
- If the user tries to jump to implementation ("just build X"), gently redirect back to the problem: what is X for, who needs it, what breaks if it doesn't exist.
- Follow the thread of the user's answers. Don't work through a fixed script - a good answer opens a new question you couldn't have planned for.
- It's fine for this to take a while. Rushing to a plan defeats the point.

## Detect a trivial request

If partway through it becomes clear this is actually small - a one-file fix, a copy change, something with no real design space - say so and point to `/groundwork:quick` instead of continuing the interview. Don't force a small thing through a big process.

## When the problem is crisp

You'll know it's crisp when you can state, in one or two sentences, who has the problem and what "solved" looks like, and the user agrees that's right. At that point, stop and offer a handoff:

- **Greenfield** (a new feature or product surface, nothing built yet, needs a vision and an MVP sequence) -> offer `/groundwork:inception`.
- **Sharpening** (there's already a rough plan or design in mind that needs the assumptions and edge cases interrogated) -> offer `/groundwork:survey`.

Ask which fits rather than assuming. Do not start writing PRDs, ADRs, or code yourself in this skill - that's the next orchestrator's job.
