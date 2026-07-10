---
name: survey
description: A rigorous design survey - sharpens a plan through a one-question-at-a-time interview until it holds up. Writes and updates prd.md, creates feature-scoped or project-wide adr/ entries per decision, and adds terms to glossary.md as a byproduct.
disable-model-invocation: true
argument-hint: "[feature-slug]"
---

# groundwork:survey

Survey a plan or design until it's sharp: a careful, one-question-at-a-time assessment of assumptions, risks, edge cases, and unresolved decisions, the way a site survey precedes construction. Use the `groundwork:interview-loop` technique for the interview itself; this skill's job is to run that loop against a specific feature and turn resolved decisions into documents as they land, not to wait until the end.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, tell the user to run `/groundwork:setup` first and stop.

Figure out which feature this is: an argument naming a slug, an obviously-current one from context, or if genuinely ambiguous, ask. If no feature exists yet for this idea, ask whether to create one (pick the next `NNNN-slug` under `docs/groundwork/features/`) or whether they meant to run `/groundwork:inception` or `/groundwork:to-prd` first.

## 1. Establish what's being surveyed

Either an existing `prd.md` (read it first, then interrogate what's thin or unstated), or a plan the user is describing fresh in this conversation (interrogate it directly, write the PRD as it firms up).

## 2. Run the interview

Follow the `groundwork:interview-loop` loop: one question at a time, both branches of every decision, push on vague answers, chase edge cases. Don't let this skill's file-writing distract from that - the interview is the point, the documents are a byproduct.

## 3. Turn each resolved decision into the right artifact, as it lands

Don't batch this to the end. As soon as a decision resolves:

- **Shapes the problem, users, goals, non-goals, or an acceptance criterion** -> update `docs/groundwork/features/NNNN-slug/prd.md` immediately.
- **An architectural, technical, or process decision with a real tradeoff** (the kind someone will ask "why did we do it this way" about later) -> write a new ADR in Nygard format:

  ```markdown
  # MMMM. Title

  ## Status
  Accepted

  ## Context
  What forces are at play, including the option(s) considered.

  ## Decision
  What was decided.

  ## Consequences
  What becomes easier or harder as a result.
  ```

  Two locations, by scope:
  - **Feature-specific** (only this feature is affected) -> `docs/groundwork/features/NNNN-slug/adr/MMMM-title.md`, numbered with a four-digit sequence scoped to that feature's `adr/` directory, starting at `0001`.
  - **The implementation stack itself** (application framework/runtime, frontend approach, persistence/backend, authentication, deployment assumptions, background processing/message bus) -> always `docs/groundwork/adr/MMMM-title.md`, the same project-wide directory `improve-codebase-architecture` uses, sequenced independently of any feature - even when this is the first feature to decide it. A stack decision isn't specific to the feature that happened to trigger it, and later features' implementation-readiness check (below) reads from this directory, not from the deciding feature's own `adr/`.

  ADRs are **append-only** once `Accepted`, in either location: never edit a decided ADR's Decision or Consequences after the fact. If the user changes their mind later, write a *new* ADR that supersedes it, and go back and change only the old ADR's Status line to `Superseded by ADR-MMMM`.

- **Introduces or sharpens a domain term** -> add or update an entry in `docs/groundwork/glossary.md`.

Write everything in the language the conversation has been in. No em dashes in any generated document.

## 4. Implementation-readiness check

Before this feature can be declared ready for `/groundwork:to-issues`, confirm the implementation stack is actually settled - not just the product decisions above:

- Read `project_type` from `docs/groundwork/config.json`. If it's **missing entirely** (a config written before this check existed), don't guess which case applies - stop and tell the user to re-run `/groundwork:setup` so it can detect and record `project_type`/`detected_stack`, then come back.
- If it's `"existing"` but `detected_stack` is missing or empty (a malformed config, or a `setup` run that didn't complete), that's an inconsistent state, not a green light - stop and tell the user to re-run `/groundwork:setup` rather than proceeding on a guess.
- If it's `"existing"` with a populated `detected_stack`, that answers this for anything the feature doesn't clearly push outside it. If the feature does need something the existing stack doesn't have (a new external service, a new datastore, etc.), interrogate that gap like any other decision and write the resulting ADR.
- If `project_type` is `"greenfield"`, confirm one or more **accepted** ADRs under the project-wide `docs/groundwork/adr/` explicitly cover, at minimum: application framework/runtime, frontend approach (if the feature has one), persistence/backend, authentication, deployment assumptions that affect implementation, and whether background processing or a message bus is required. Anything on that list still open is an unresolved branch of the interview, same as any other - interrogate it and write the ADR (to `docs/groundwork/adr/`, per step 3 above) before moving on, don't wave it through. Once an earlier feature has settled the stack there, later features just read it - the interview only needs to cover ground this project-wide directory doesn't already answer.

This is a hard stop condition: do not reach the hand-off step below with a greenfield stack still undecided, and never pick a stack yourself to close the gap - that decision belongs to the interview, made with the user.

## 5. Stop condition

Stop when the design survives the interview, per the `interview-loop` discipline's stop condition, and the implementation-readiness check above is satisfied. Summarize what changed: which PRD sections were touched, which ADRs were created, which glossary terms were added.

## 6. Hand off

Once the plan is sharp and implementation-ready, suggest `/groundwork:to-issues` to break it into work. If the user wants to keep refining later, mention `/groundwork:handoff` to save state before stopping. If the readiness check above is still unsatisfied, say so plainly instead of suggesting `to-issues`.
