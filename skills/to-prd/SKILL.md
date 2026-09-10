---
name: to-prd
description: Use when a plan has already been talked through in this conversation and deserves capturing - the user says "write this up", "capture this", "let's document what we agreed", or asks to move forward on a discussed design. Synthesizes the conversation into prd.md with no interview; never invents what wasn't discussed.
argument-hint: "[feature-slug]"
---

# groundwork:to-prd

Capture, don't interview. The user has already talked through a plan in this conversation; your job is to turn what was actually said into a `prd.md`, not to ask new questions or invent what wasn't discussed.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, don't stop - bootstrap it per the "Lazy bootstrap" section of the groundwork `setup` skill: detect tracker and project type, write the config with defaults, state the assumptions in one line, and continue. Running `setup` explicitly is only for customizing.

Determine the feature slug and number: an argument naming one, an existing feature obviously under discussion, or the next `NNNN-slug` under `docs/groundwork/features/` if this is new. Confirm the slug with the user before writing.

## 1. Extract from the conversation

Read back through what's been discussed and pull out, only where it was actually stated:

- Problem and motivation
- Users / who this is for
- Goals
- Non-goals / explicitly out-of-scope items
- Acceptance criteria, if any were stated
- Any decisions that read as architectural (flag these for the user - they may belong in an ADR via `survey` rather than the PRD body)

Do not fabricate content for a section that wasn't discussed. If acceptance criteria were never mentioned, leave that section as an explicit placeholder and tell the user it's missing rather than inventing plausible-sounding criteria.

## 2. Write prd.md

Write `docs/groundwork/features/NNNN-slug/prd.md` with sections: Problem, Users, Goals, Non-goals, Acceptance criteria, Out of scope. Use the language the conversation has been in. No em dashes.

If `prd.md` already exists for this feature, merge rather than overwrite: keep existing content that the conversation didn't touch, update what it did.

## 3. Report gaps and hand off

Tell the user exactly what got captured and, separately, what's missing or thin. If there are real gaps or unstated assumptions, offer to continue into `survey` to interrogate them rather than pretending the PRD is complete. If it's solid, offer `to-issues`. On a yes, load and follow the groundwork skill of that name directly in this session - don't wait to be asked again.
