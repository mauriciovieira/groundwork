# groundwork

A lightweight, spec-driven development framework for Claude Code. It turns "let's build X" into a PRD (Product Requirements Document), sharpened by an interview, broken into small vertical slices, built with TDD (Test-Driven Development), and reviewed against both the code standards and the spec that motivated it - as much or as little of that as a task actually needs.

Since 1.0, groundwork meets you halfway instead of waiting for commands. The advisory skills (`brainstorm`, `to-prd`, `quick`, `validate`, `code-review`) fire on their own when a request matches their trigger, orchestrators flow into each other instead of waiting for you to type the next command, and the first groundwork skill you touch bootstraps its own config with detected defaults. Every step with real side effects - creating tracker issues, building code, spawning parallel agents - still waits for an inline confirmation, and every skill remains directly invocable as a `/groundwork:...` command when you want to steer.

## Install

```
/plugin marketplace add mauriciovieira/groundwork
/plugin install groundwork
```

Optionally run `/groundwork:setup` to customize the per-repository defaults (tracker, docs location, labels, rules file). If you skip it, the first groundwork skill you use bootstraps a config with detected defaults and tells you what it assumed.

## Two tiers of skill

Every groundwork skill is one of two kinds:

- **Orchestrators** drive a stage of the flow. The advisory ones - `brainstorm`, `to-prd`, `quick`, `validate`, `code-review` - are model-invoked: Claude starts them on its own when your request matches their trigger. The side-effectful or interview-heavy ones - `setup`, `inception`, `survey`, `triage`, `to-issues`, `build`, `improve-codebase-architecture` - keep `disable-model-invocation: true` and start only from your slash command or from another orchestrator handing off. Orchestrators flow into each other: read-only follow-ups (`build` into `validate` into `code-review`) chain automatically, and anything with side effects asks once, inline, before proceeding.
- **Disciplines** are reusable techniques Claude can reach for while executing an orchestrator - the interview loop, the TDD cycle, worktree management. Their descriptions are scoped tightly to groundwork's own workflows, so in practice they only ever fire from inside an orchestrator, not from a cold prompt.

The result: you can still drive everything with explicit commands, but a plain "let's build X" is enough for Claude to open the brainstorm, and a finished build flows into its own validation and review without you re-typing commands.

## Commands

| Command | What it does |
| --- | --- |
| `/groundwork:setup` | Optional config: issue tracker, docs location, triage labels, rules file. Skills bootstrap defaults on first use; run this to customize. |
| `/groundwork:brainstorm` | Socratic discovery for a fuzzy idea, one question at a time. Hands off to `inception` or `survey`. |
| `/groundwork:inception` | Lean Inception, lite: vision, personas, an is/is-not table, an MVP sequence. Writes the first `prd.md`. |
| `/groundwork:survey` | A rigorous design survey: sharpens a plan through a one-question-at-a-time interview, writing `prd.md`, `adr/` entries, and `glossary.md` as decisions land. Scales to a tracker-native map of decision tickets (`--map`) when a plan is too big or fuzzy for one session. |
| `/groundwork:to-prd` | Synthesizes the current conversation into `prd.md`, no interview - use when you've already talked it through. |
| `/groundwork:triage` | Sorts inbound issues through five state roles (`needs-triage`/`needs-info`/`ready-for-agent`/`ready-for-human`/`wontfix` - configurable label strings per role) before they reach `to-issues`, or straight into an agent brief when no PRD is needed. |
| `/groundwork:to-issues` | Breaks `prd.md` + `adr/` into tracer-bullet vertical slices (HITL/AFK, dependency-ordered) and creates them in your tracker. |
| `/groundwork:build` | Implements the open, unblocked slices with TDD. Sequential by default; `--worktree` and `--parallel` are opt-in. |
| `/groundwork:validate` | Definition-of-Done gate: every acceptance criterion tested, every slice done or deferred, no ADR (Architecture Decision Record) violated. |
| `/groundwork:code-review` | Reviews the diff along a Standards axis and a Spec axis, in parallel, then merges both reports. |
| `/groundwork:quick` | The escape hatch: does a trivial task directly, no PRD/ADR/issues. |
| `/groundwork:improve-codebase-architecture` | Periodic architecture review: finds deepening opportunities informed by `glossary.md` and `adr/`, interviews through the chosen candidate, updates both as decisions land. Not part of the linear flow - run it whenever, not per-feature. |

Three more skills back the orchestrators above but aren't meant to be invoked directly, since they're only ever reached from inside one: `interview-loop` (the interview loop behind `survey`), `tdd` (the red-green-refactor loop behind `build`), and `worktree` (isolated branch-per-slice behind `build --worktree`).

## The flow

```
brainstorm ──┬──> inception ──┐
             └──> survey <────┴──> to-prd
                    │
triage ─────────────┘
                    │
                    v
                to-issues ──> build ──> validate ──> code-review
```

Since 1.0 the arrows are real hand-offs: an orchestrator offers the next step inline and continues on a yes - and `build` flows into `validate` and `code-review` automatically, since those are read-only. You type the next command only when you want to steer.

`quick` sits outside this flow entirely, for anything too small to justify it. `improve-codebase-architecture` also sits outside it - a periodic check you run whenever the codebase feels like it's accumulating friction, not a required stop for any one feature. `triage` feeds `to-issues` when an issue needs a PRD-level slice, but can also skip straight to an agent brief when the issue is already fully specified - `build` reads those directly off the tracker alongside `to-issues` slices, in whatever format each carries its `Type` field.

## PRD, ADR, issues - not spec and plan

- **`prd.md`** is the what and why: problem, users, goals, non-goals, acceptance criteria, out-of-scope. One per feature, at `docs/groundwork/features/NNNN-slug/prd.md`.
- **`adr/MMMM-title.md`** is one architectural or process decision per file, in Nygard format (Status, Context, Decision, Consequences). ADRs are append-only once `Accepted` - a change of mind is a *new* ADR that marks the old one `Superseded`, never an edit to a decided one. Most ADRs are feature-scoped (`docs/groundwork/features/NNNN-slug/adr/`), written by `survey` as a feature is designed. Decisions that aren't tied to one feature go into a sibling, project-wide `docs/groundwork/adr/` instead, sequenced independently - `improve-codebase-architecture` writes there for architecture reviews, and `survey` writes there too for the implementation stack itself (framework, persistence, auth, deployment, background processing), since a stack decision isn't specific to whichever feature happened to trigger it.
- **Issues** are tracer-bullet vertical slices - each cuts end-to-end through every layer it touches, never a horizontal slice of just one layer. `to-issues` tags each with a `Type`, preferring `AFK`, and builds the `blocked-by` graph before creating anything:
  - **`AFK`** (Away From Keyboard) - mergeable without a human in the loop, because the PRD and ADRs already say enough to build and verify it alone. The default; prefer it.
  - **`HITL`** (Human In The Loop) - needs a human decision or review mid-flight, because the slice touches something irreversible, ambiguous, or outside what the PRD/ADRs already decided. Only use it when there's a concrete reason, not by default caution.

  `build --parallel` dispatches every unblocked `AFK` slice to its own sub-agent concurrently; `HITL` slices (and anything still blocked) always stay sequential in the main agent, so a human is in the loop for exactly the slices that need one.

```
docs/groundwork/
  config.json
  glossary.md
  quicklog.md            # only if you've used /groundwork:quick with logging
  adr/                   # system-wide decisions, not tied to one feature
    0001-title.md        # improve-codebase-architecture or survey (stack decisions); created lazily
  features/
    0001-example-slug/
      prd.md
      adr/
        0001-title.md
      tasks.md            # only when tracker = local
      map.md              # only when survey escalated to map speed and tracker = local
      tickets.md          # only when survey escalated to map speed and tracker = local
```

## Two speeds of survey

Most features fit in one continuous interview. `survey` escalates to **map speed** (`--map`, or automatically when a breadth-first pass turns up too much fog for one session) for efforts that don't: it charts a **map** - an issue for `github`/`linear`, or `map.md` for `local` - naming the Destination, Notes, Decisions so far, Not yet specified (the fog of war), and Out of scope - then breaks the fog into **tickets** (issues for `github`/`linear`, `tickets.md` entries for `local`), each referencing the map via a `Map:` body field (not a native parent/child hierarchy - not universal on `github`, workspace-dependent on `linear`) and carrying a `Type:` body field (also not a tracker label, so it reads identically across `github`/`linear`/`local`) valued `research` (an autonomous `researcher` agent gathers a fact), `prototype` (a rough artifact to react to), `interview` (the same one-question-at-a-time loop, scoped to one question), or `task` (prerequisite work blocking a decision). Tickets resolve one at a time - research tickets run in parallel - across as many sessions or contributors as it takes, writing into the exact same `prd.md`/`adr/`/`glossary.md` either speed produces, until the frontier is empty and the way to `to-issues` is clear.

Map speed adapts the [`wayfinder`](https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md) skill by [Matt Pocock](https://github.com/mattpocock) onto groundwork's own artifact model (`prd.md`/`adr/`/`glossary.md`, the existing tracker-agnostic dispatch) instead of introducing a separate one.

## Tracker-agnostic by design

`/groundwork:setup` (or the lazy bootstrap, the first time any skill runs without a config) records one of `github`, `linear`, or `local` in `docs/groundwork/config.json`. Every other skill reads that instead of asking again. `to-issues` and `build` behave identically regardless of destination - only the last step (where an issue actually gets created, and where its status lives) differs: `gh issue create` for `github`, the Linear MCP tools for `linear`, or a checklist in each feature's `tasks.md` for `local`.

## Rules file: CLAUDE.md by default, AGENTS.md for multi-tool repos

Since groundwork is a Claude Code plugin, `setup` writes `CLAUDE.md` at the repo root by default. If your repo also has clients on Cursor, Codex, or Copilot, choose `agents` during setup instead: groundwork writes `AGENTS.md` as the portable source of truth, plus a thin `CLAUDE.md` whose body is `@AGENTS.md` and nothing else except any Claude-specific overrides. Rule content is never duplicated across the two files - a rule that applies to every tool lives only in `AGENTS.md`.

## The escape hatch

Not everything needs a PRD. `/groundwork:quick` does a trivial task directly - no interview, no ADR, no issue breakdown - and optionally appends one line to `docs/groundwork/quicklog.md` if you want a trail of what you've done outside the full process. `brainstorm` and other orchestrators will switch into `quick` themselves (with your ok) when they notice a request is too small for the ceremony - and Claude reaches for `quick` directly on trivial asks in a groundwork repo.

## Language

groundwork itself - every `SKILL.md`, command, and this README - is written in English. The artifacts it generates (PRDs, ADRs, the glossary, issues) follow whatever language the conversation or your prompt is in. Nothing here hardcodes a language into generated output.

## Notes on the Claude Code plugin format

This plugin was verified against the current official Claude Code plugin documentation at build time. Two things worth calling out if you're extending it:

- Skills are exposed as `/groundwork:<name>` automatically from their `skills/<name>/SKILL.md` location - no separate `commands/` wrapper is needed for a skill to become a slash command.
- `disable-model-invocation: true` in a plugin skill's frontmatter reliably keeps Claude from auto-invoking it, the same as a personal or project skill. groundwork uses it only on the side-effectful orchestrators; the advisory ones rely on trigger-form descriptions ("Use when...") to be picked up automatically.
