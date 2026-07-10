# groundwork

A lightweight, opt-in, spec-driven development framework for Claude Code. It turns "let's build X" into a PRD, sharpened by an interview, broken into small vertical slices, built with TDD, and reviewed against both the code standards and the spec that motivated it - as much or as little of that as you actually invoke.

groundwork never starts on its own. Every part of it is a skill you invoke explicitly with a `/groundwork:...` command; none of it auto-fires from a plain request, and an orchestrator never chains into another orchestrator without you typing the next command yourself. If you never type `/groundwork:anything`, groundwork has no effect on your session.

## Install

```
/plugin marketplace add mauriciovieira/groundwork
/plugin install groundwork
```

Then run `/groundwork:setup` once per repository before anything else.

## Two tiers of skill

Every groundwork skill is one of two kinds:

- **Orchestrators** are user-invoked only (`disable-model-invocation: true` in their frontmatter). They run only when you type the slash command - Claude may *suggest* one when your request looks like it needs the process, but never starts one on its own. An orchestrator can call disciplines, never another orchestrator.
- **Disciplines** are reusable techniques Claude can reach for while executing an orchestrator you already invoked - the interview loop, the TDD cycle, worktree management. Their descriptions are scoped tightly to groundwork's own workflows, so in practice they only ever fire from inside an orchestrator, not from a cold prompt.

This keeps the whole system opt-in from where you sit: nothing groundwork-related starts unless you typed a `/groundwork:` command first, while orchestrators still get to compose shared, tested building blocks internally.

## Commands

| Command | What it does |
| --- | --- |
| `/groundwork:setup` | One-time config: issue tracker, docs location, triage labels, rules file. Run this first. |
| `/groundwork:brainstorm` | Socratic discovery for a fuzzy idea, one question at a time. Hands off to `inception` or `grill`. |
| `/groundwork:inception` | Lean Inception, lite: vision, personas, an is/is-not table, an MVP sequence. Writes the first `prd.md`. |
| `/groundwork:grill` | The relentless interview: sharpens a plan, writing `prd.md`, `adr/` entries, and `glossary.md` as decisions land. |
| `/groundwork:to-prd` | Synthesizes the current conversation into `prd.md`, no interview - use when you've already talked it through. |
| `/groundwork:triage` | Sorts inbound issues (needs-triage/needs-info/ready-for-agent/ready-for-human/wontfix) before they reach `to-issues`, or straight into an agent brief when no PRD is needed. |
| `/groundwork:to-issues` | Breaks `prd.md` + `adr/` into tracer-bullet vertical slices (HITL/AFK, dependency-ordered) and creates them in your tracker. |
| `/groundwork:build` | Implements the open, unblocked slices with TDD. Sequential by default; `--worktree` and `--parallel` are opt-in. |
| `/groundwork:validate` | Definition-of-Done gate: every acceptance criterion tested, every slice done or deferred, no ADR violated. |
| `/groundwork:code-review` | Reviews the diff along a Standards axis and a Spec axis, in parallel, then merges both reports. |
| `/groundwork:handoff` | Reads or writes `docs/groundwork/STATE.md` to pause and resume work. |
| `/groundwork:quick` | The escape hatch: does a trivial task directly, no PRD/ADR/issues. |
| `/groundwork:improve-codebase-architecture` | Periodic architecture review: finds deepening opportunities informed by `glossary.md` and `adr/`, grills the chosen candidate, updates both as decisions land. Not part of the linear flow - run it whenever, not per-feature. |

Three more skills back the orchestrators above but have no slash command of their own, since they're only ever reached from inside one: `grilling` (the interview loop behind `grill`), `tdd` (the red-green-refactor loop behind `build`), and `worktree` (isolated branch-per-slice behind `build --worktree`).

## The flow

```
brainstorm ──┬──> inception ──┐
             └──> grill <─────┴──> to-prd
                    │
triage ─────────────┘
                    │
                    v
                to-issues ──> build ──> validate ──> code-review
                                 │
                                 v
                             handoff (pause/resume, any point)
```

`quick` sits outside this flow entirely, for anything too small to justify it. `improve-codebase-architecture` also sits outside it - a periodic check you run whenever the codebase feels like it's accumulating friction, not a required stop for any one feature. `triage` feeds `to-issues` when an issue needs a PRD-level slice, but can also skip straight to an agent brief when the issue is already fully specified - `build` reads those directly off the tracker alongside `to-issues` slices, in whatever format each carries its `Type` field.

## PRD, ADR, issues - not spec and plan

- **`prd.md`** is the what and why: problem, users, goals, non-goals, acceptance criteria, out-of-scope. One per feature, at `docs/groundwork/features/NNNN-slug/prd.md`.
- **`adr/MMMM-title.md`** is one architectural or process decision per file, in Nygard format (Status, Context, Decision, Consequences). ADRs are append-only once `Accepted` - a change of mind is a *new* ADR that marks the old one `Superseded`, never an edit to a decided one. Most ADRs are feature-scoped (`docs/groundwork/features/NNNN-slug/adr/`), written by `grill` as a feature is designed. `improve-codebase-architecture` also writes ADRs for decisions that aren't tied to one feature, into a sibling `docs/groundwork/adr/`, sequenced independently.
- **Issues** are tracer-bullet vertical slices - each cuts end-to-end through every layer it touches, never a horizontal slice of just one layer. `to-issues` tags each with a `Type`, preferring `AFK`, and builds the `blocked-by` graph before creating anything:
  - **`AFK`** (Away From Keyboard) - mergeable without a human in the loop, because the PRD and ADRs already say enough to build and verify it alone. The default; prefer it.
  - **`HITL`** (Human In The Loop) - needs a human decision or review mid-flight, because the slice touches something irreversible, ambiguous, or outside what the PRD/ADRs already decided. Only use it when there's a concrete reason, not by default caution.

  `build --parallel` dispatches every unblocked `AFK` slice to its own sub-agent concurrently; `HITL` slices (and anything still blocked) always stay sequential in the main agent, so a human is in the loop for exactly the slices that need one.

```
docs/groundwork/
  config.json
  glossary.md
  STATE.md
  quicklog.md            # only if you've used /groundwork:quick with logging
  adr/                   # system-wide decisions, not tied to one feature
    0001-title.md        # written by improve-codebase-architecture; created lazily
  features/
    0001-example-slug/
      prd.md
      adr/
        0001-title.md
      tasks.md            # only when tracker = local
```

## Tracker-agnostic by design

`/groundwork:setup` records one of `github`, `linear`, or `local` in `docs/groundwork/config.json`. Every other skill reads that instead of asking again. `to-issues` and `build` behave identically regardless of destination - only the last step (where an issue actually gets created, and where its status lives) differs: `gh issue create` for `github`, the Linear MCP tools for `linear`, or a checklist in each feature's `tasks.md` for `local`.

## Rules file: CLAUDE.md by default, AGENTS.md for multi-tool repos

Since groundwork is a Claude Code plugin, `setup` writes `CLAUDE.md` at the repo root by default. If your repo also has clients on Cursor, Codex, or Copilot, choose `agents` during setup instead: groundwork writes `AGENTS.md` as the portable source of truth, plus a thin `CLAUDE.md` whose body is `@AGENTS.md` and nothing else except any Claude-specific overrides. Rule content is never duplicated across the two files - a rule that applies to every tool lives only in `AGENTS.md`.

## The escape hatch

Not everything needs a PRD. `/groundwork:quick` does a trivial task directly - no interview, no ADR, no issue breakdown - and optionally appends one line to `docs/groundwork/quicklog.md` if you want a trail of what you've done outside the full process. `brainstorm` and other orchestrators will point you at `quick` themselves when they notice a request is too small for the ceremony.

## Language

groundwork itself - every `SKILL.md`, command, and this README - is written in English. The artifacts it generates (PRDs, ADRs, the glossary, issues) follow whatever language the conversation or your prompt is in. Nothing here hardcodes a language into generated output.

## Notes on the Claude Code plugin format

This plugin was verified against the current official Claude Code plugin documentation at build time. Two things worth calling out if you're extending it:

- Skills are exposed as `/groundwork:<name>` automatically from their `skills/<name>/SKILL.md` location - no separate `commands/` wrapper is needed for a skill to become a slash command.
- `disable-model-invocation: true` in a plugin skill's frontmatter reliably keeps Claude from auto-invoking it, the same as a personal or project skill.
