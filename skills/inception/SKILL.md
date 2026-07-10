---
name: inception
description: Lean Inception, lite - one focused pass producing a vision, personas, an is/is not/does/does not table, and an MVP sequence. Writes the first draft of prd.md.
disable-model-invocation: true
---

# groundwork:inception

A single focused pass for a greenfield idea, not a multi-day workshop. By the end you'll have a first-draft `prd.md`. Use `/groundwork:survey` afterward to interrogate it further if the idea has any real ambiguity left.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, tell the user to run `/groundwork:setup` first and stop.

This skill stays in product discovery: vision, personas, scope, goals, non-goals, MVP sequencing. It does not require or produce a stack decision, and it must not invent one. Capture technical constraints only when the user states them as an actual product requirement (e.g. "must work offline", "must integrate with our existing SSO") - record them under Goals or in the Does / Does not table, whichever fits, not as an invented technical section. Choosing an application framework, database, or deployment target is out of scope here. That happens later, in `/groundwork:survey`, and is recorded as ADRs before `/groundwork:to-issues` will proceed.

## 1. Vision

Get to a one-paragraph vision statement with the user: for whom, what need, what it is, how it's different from doing nothing (or from the obvious alternative). Don't accept a vague vision - if the user's first answer is generic, push once for specifics before moving on.

## 2. Personas

Light weight, not full personas with stock photos. One to three: name, role, goal, and the one frustration that makes them care about this. Skip any persona that isn't going to change a scope decision later - a persona that doesn't affect what gets built or cut isn't worth writing down.

## 3. Is / is not / does / does not

Build this table with the user - it's the fastest way to surface scope disagreements early:

| Is | Is not |
| --- | --- |
| | |

| Does | Does not |
| --- | --- |
| | |

## 4. MVP sequencer

Order the work into thin, end-to-end slices by value and risk, not by layer. A slice cuts through every layer it touches (schema, API, UI, whatever applies) - never "build the database" as one slice and "build the UI" as another. Sequence the riskiest and highest-value slices first. This list is a starting sequence, not final acceptance criteria - `to-issues` will turn it into real tracer-bullet issues later, and `survey` may reorder or split it.

## 5. Write prd.md

Determine the feature slug and number: look at `docs/groundwork/features/` for existing `NNNN-slug` directories and pick the next number (four digits, zero-padded). If this is the first feature, use `0001`. Confirm the slug with the user.

Write `docs/groundwork/features/NNNN-slug/prd.md` with sections: Vision, Personas, Is / Is not / Does / Does not, Goals, Non-goals, MVP sequence. Match the language the user has been writing in - do not translate into English if the conversation has been in another language.

Do not write acceptance criteria yet unless the user already stated them clearly; leave that section as a placeholder for `survey` to fill in. Do not use em dashes anywhere in the document.

## 6. Hand off

Tell the user what was written and where. If the PRD still has real open questions or unstated assumptions, suggest `/groundwork:survey` to sharpen it. If it's already tight enough to act on, suggest `/groundwork:to-issues`.
