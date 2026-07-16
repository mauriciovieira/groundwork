---
name: survey
description: A rigorous design survey - sharpens a plan through a one-question-at-a-time interview until it holds up, scaling from a single session to a tracker-native map of decision tickets for efforts too big for one. Writes and updates prd.md, creates feature-scoped or project-wide adr/ entries per decision, and adds terms to glossary.md as a byproduct.
disable-model-invocation: true
argument-hint: "[feature-slug] [--map]"
---

# groundwork:survey

Survey a plan or design until it's sharp: a careful, one-question-at-a-time assessment of assumptions, risks, edge cases, and unresolved decisions, the way a site survey precedes construction. Most features fit in one continuous interview session. Some don't - too big, too fuzzy, or spanning more than one session or contributor - and need their open questions tracked as tickets on the tracker instead of held in one conversation. Both are this skill; step 3 picks which.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, tell the user to run `/groundwork:setup` first and stop.

Figure out which feature this is: an argument naming a slug, an obviously-current one from context, or if genuinely ambiguous, ask. If no feature exists yet for this idea, ask whether to create one (pick the next `NNNN-slug` under `docs/groundwork/features/`) or whether they meant to run `/groundwork:inception` or `/groundwork:to-prd` first.

## 1. Establish what's being surveyed

Either an existing `prd.md` (read it first, then interrogate what's thin or unstated), or a plan the user is describing fresh in this conversation (interrogate it directly, write the PRD as it firms up).

## 2. Turn each resolved decision into the right artifact, as it lands

Don't batch this to the end, whichever speed produced the decision. As soon as one resolves:

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
  - **The implementation stack itself** (application framework/runtime, frontend approach, persistence/backend, authentication, deployment assumptions, background processing/message bus) -> always `docs/groundwork/adr/MMMM-title.md`, the same project-wide directory `improve-codebase-architecture` uses. Number it with the same four-digit sequence rule as feature-scoped ADRs, but scoped to this directory instead of a feature's - starting at `0001`, next available after that - and sequenced independently of any feature, even when this is the first feature to decide it. A stack decision isn't specific to the feature that happened to trigger it, and later features' implementation-readiness check (below) reads from this directory, not from the deciding feature's own `adr/`.

  ADRs are **append-only** once `Accepted`, in either location: never edit a decided ADR's Decision or Consequences after the fact. If the user changes their mind later, write a *new* ADR that supersedes it, and go back and change only the old ADR's Status line to `Superseded by ADR-MMMM`.

- **Introduces or sharpens a domain term** -> add or update an entry in `docs/groundwork/glossary.md`.

Write everything in the language the conversation has been in. No em dashes in any generated document.

## 3. Pick a speed

Escalate to a map only when the effort genuinely needs it:

- `--map` was passed -> skip straight to map speed (step 5).
- Otherwise, take one breadth-first pass over the plan (or the existing `prd.md`): fan out across the whole space rather than going deep on any single thread, just enough to tell whether the open questions cluster into a handful of related branches (one session's work) or scatter into many independent threads that would outlast this session, need more than one contributor, or depend on external investigation before they can even be asked.
- **No real fog** -> interview speed (step 4).
- **Real fog** -> map speed (step 5).

If genuinely unsure, default to interview speed and escalate mid-survey if it stalls - that's always available, never a failure.

## 4. Interview speed (default)

Follow the `groundwork:interview-loop` loop: one question at a time, both branches of every decision, push on vague answers, chase edge cases. Don't let this skill's file-writing distract from that - the interview is the point, the documents are a byproduct. Apply step 2 to every decision as it resolves.

## 5. Map speed (for efforts too big for one session)

The same interview, generalized: instead of holding every open thread in one conversation, each open decision becomes a tracked ticket on the configured tracker, so the plan can be worked one ticket at a time, across as many sessions or contributors as it takes, with the tracker itself showing what's still open.

### Name the destination

Before anything else, state in one or two lines what this map is finding its way to - a settled `prd.md`, a specific set of ADRs, a change to make. This fixes the scope: everything the map charts either serves this destination or is ruled out of scope, decided below.

### Create the map

Check first whether a map already exists for this feature - an open issue titled `Map: NNNN-slug - <destination>` for `github`/`linear`, or `docs/groundwork/features/NNNN-slug/map.md` already present for `local`. The feature's own `NNNN-slug` in the title is what makes the reuse check and cross-linking unambiguous when two features happen to share similar destination wording. If a map already exists, reuse it: a re-run of `--map` (or any session working this feature's frontier) picks up the existing map rather than creating a second one. Otherwise, create one map artifact per feature - an issue for `github`/`linear`, `docs/groundwork/features/NNNN-slug/map.md` for `local` - holding:

```markdown
## Destination

<one or two lines - what reaching the end of this map looks like>

## Notes

<domain context, standing preferences, which skills a ticket should reach for>

## Decisions so far

<!-- one line per closed ticket, added as each resolves - see "Work the frontier" -->

## Not yet specified

<!-- fog of war: real, in-scope questions too fuzzy to ticket yet -->

## Out of scope

<!-- work ruled beyond the destination - gist plus why, linking the closed ticket -->
```

Sketch the fog into "Not yet specified": whatever breadth-first pass step 3 already took, or - if `--map` skipped straight here without one - take that same breadth-first pass now instead. Either way, this is the fog, not yet tickets. Create the issue per tracker:

- `github`: `gh issue create --title "Map: NNNN-slug - <destination>" --body "..."`.
- `linear`: the equivalent via the Linear MCP tools if connected (check via a tool search if unsure what's available); otherwise tell the user what's missing rather than guessing at an API call.
- `local`: `docs/groundwork/features/NNNN-slug/map.md`.

### Break the fog into tickets

For every question in "Not yet specified" that's now sharp enough to state precisely - even if it's blocked and can't be worked yet - create a ticket with this body:

```markdown
## Question

<the decision or investigation this ticket resolves>

- Type: <research|prototype|interview|task>
- Map: <link back to the map, per tracker below>
```

`Type` and `Map` are plain body fields, not tracker labels, and not a native parent/child issue relationship - `github` has no universal concept of one, and it's workspace-dependent on `linear`, so a ticket links back to its map the same explicit way `to-issues` links a slice to its blocker: `#<number>` for `github`, the equivalent identifier for `linear`, the map's own file path (`docs/groundwork/features/NNNN-slug/map.md`) for `local` - a stable identifier every session encodes the same way. Create the ticket per tracker:

- `github`/`linear`: an issue with this body, linked to the map only via its `Map:` field.
- `local`: an entry in `docs/groundwork/features/NNNN-slug/tickets.md` with the same `Type`/`Map` fields.

`Type` is one of:

- **`research`** (AFK) - a fact the decision is waiting on, gathered from documentation, an external API, or this codebase. Resolved by the `researcher` agent.
- **`prototype`** (HITL) - the question is "how should it look/behave", answered by reacting to something concrete. Invoke this session's own prototyping skill or tool if one is available; otherwise sketch the rough artifact - an outline, a stub, a rough take - directly inline.
- **`interview`** (HITL) - a conversation resolves it. The default ticket type; resolved with the same `groundwork:interview-loop` loop as interview speed, scoped to just this ticket's question.
- **`task`** (HITL or AFK) - prerequisite work, not a decision itself, blocking one until it's done (provisioning access, moving data so its shape can be seen). Do it directly where the agent can (AFK); otherwise hand the user a precise checklist (HITL).

Whatever's still too fuzzy to state that precisely stays in "Not yet specified" rather than being forced into a premature ticket - don't pre-slice the fog.

Wire `Blocked-by` in a second pass, once every ticket has an id (a ticket needs the other's id to reference it): `github` writes it as `Blocked by #<number>` in the body, the same convention `to-issues` uses for slices; `linear` uses the same field via its MCP tools, or `Blocked by <identifier>` in the description instead if the tools available don't support a native blocking relation - same fallback `to-issues` documents; `local` writes it in the `tickets.md` entry. A ticket is **unblocked** once everything blocking it is closed; the open, unblocked tickets are the **frontier** - the edge of the known, and what's actually takeable next.

### Fire research tickets

For every `research` ticket just created, dispatch the `researcher` agent - concurrently, one per ticket.

### Work the frontier

Work exactly one non-research ticket per session. Research tickets are the one exception: dispatched in the previous step, they run asynchronously alongside whichever ticket the session is working, and may finish before, during, or after it. Per ticket:

1. **Claim it** (assign it to yourself, for `github`/`linear` - signals other concurrent sessions to skip it; moot for `local`, which only ever has one session working it at a time).
2. **Resolve it** with the technique its `Type` calls for, above.
3. **Write the artifact** - apply step 2 to the resolution, exactly as interview speed would.
4. **Record it**: post the resolution as a comment on the ticket, close it, and append one line to the map's "Decisions so far" - the ticket's title as a link, plus a one-line gist of the answer. Refer to it by that title everywhere it's discussed, never by a bare number - a wall of `#42, #43, #44` doesn't read; a name does.
5. **Graduate the fog**: anything in "Not yet specified" the resolution just made specifiable becomes a fresh ticket (create, then wire its `Blocked-by` in the next pass); clear it from "Not yet specified" once it has a ticket of its own.
6. **Rule out of scope, don't resolve, anything past the destination**: if this ticket (or another one already open) turns out to sit beyond what "Name the destination" scoped in, close it and add one line to "Out of scope" instead - the gist and why, linking the closed ticket. It never enters "Decisions so far".

Stop the session once the one non-research ticket claimed this pass is resolved (any research tickets dispatched alongside it may still be running) - working the rest of the frontier is the next session's job, or a concurrent one already running.

## 6. Implementation-readiness check

Before this feature can be declared ready for `/groundwork:to-issues`, confirm the implementation stack is actually settled - not just the product decisions above:

- Read `project_type` from `docs/groundwork/config.json`. If it's **missing entirely** (a config written before this check existed), don't guess which case applies - stop and tell the user to re-run `/groundwork:setup` so it can detect and record `project_type`/`detected_stack`, then come back.
- If it's `"existing"` but `detected_stack` is missing or empty (a malformed config, or a `setup` run that didn't complete), that's an inconsistent state, not a green light - stop and tell the user to re-run `/groundwork:setup` rather than proceeding on a guess.
- If it's `"existing"` with a populated `detected_stack`, that answers this for anything the feature doesn't clearly push outside it. If the feature does need something the existing stack doesn't have (a new external service, a new datastore, etc.), interrogate that gap like any other decision and write the resulting ADR.
- If `project_type` is `"greenfield"`, confirm one or more ADRs with `Status: Accepted` under the project-wide `docs/groundwork/adr/` explicitly cover, at minimum: application framework/runtime, frontend approach (if the feature has one), persistence/backend, authentication, deployment assumptions that affect implementation, and whether background processing or a message bus is required. Anything on that list still open is an unresolved branch of the interview, same as any other - interrogate it and write the ADR (to `docs/groundwork/adr/`, per step 2 above) before moving on, don't wave it through. Once an earlier feature has settled the stack there, later features just read it - the interview only needs to cover ground this project-wide directory doesn't already answer.

This is a hard stop condition: do not reach the hand-off step below with a greenfield stack still undecided, and never pick a stack yourself to close the gap - that decision belongs to the interview, made with the user.

## 7. Stop condition

**Interview speed**: stop when the design survives the interview, per the `interview-loop` discipline's stop condition, and the implementation-readiness check above is satisfied.

**Map speed**: stop when the frontier is empty, "Not yet specified" is empty, and the implementation-readiness check above is satisfied - the way to the destination is clear, nothing left to decide.

Either way, summarize what changed: which PRD sections were touched, which ADRs were created, which glossary terms were added, and for map speed, which tickets resolved this session.

## 8. Hand off

Once the plan is sharp and implementation-ready, suggest `/groundwork:to-issues` to break it into work. If the readiness check above is still unsatisfied, say so plainly instead of suggesting `to-issues`.
