---
name: setup
description: One-time groundwork configuration for this repository - issue tracker, docs location, triage labels, and rules file. Every other groundwork skill reads the result instead of asking again.
disable-model-invocation: true
---

# groundwork:setup

Configure groundwork for this repository, once. The output is `docs/groundwork/config.json`. Every other groundwork orchestrator reads that file instead of interviewing the user again, so get it right here.

## 1. Check for an existing config

Look for `docs/groundwork/config.json` (or the configured `docs_dir` if you already know it moved). If it exists:

- Show the user the current settings.
- If `project_type` is missing, or it's `"existing"` with `detected_stack` missing or empty, that's an incomplete or backfill-needed state either way - don't just confirm and stop. Tell the user what's missing, then run step 2 below to detect it and step 4 to write it back into the existing config, leaving every other field untouched. This backfill doesn't need the full reconfigure interview.
- Otherwise, ask whether they want to reconfigure, and if so, which fields (tracker, docs location, triage labels, rules file). Do not re-run the full interview blind.
- If they just want to confirm it's already set up and `project_type`/`detected_stack` are consistent, say so and stop.

If it does not exist, continue.

## 2. Detect implementation status

Inspect the repository for signs of an existing implementation: package manifests (`package.json`, `pyproject.toml`, `go.mod`, `Gemfile`, `pom.xml`, etc.), lockfiles, source directories beyond scaffolding, a Dockerfile, CI config, framework-specific files.

- **Existing implementation**: one or more of those signals are present. Record what you actually found - language, framework/runtime, package manager, notable infra config - as plain observed facts. Do not infer or invent anything not visible in the repo, and do not fill gaps with a best guess.
- **Greenfield**: no such signals (empty, docs-only, or just scaffolding like this plugin's own repo). Record that plainly. No stack exists yet and none should be decided here - choosing one is `/groundwork:survey`'s job, once a feature is being interrogated, not `setup`'s.

Show the user what was detected (or that nothing was found) and let them correct it before writing config. Either way, `setup` only records what's true today - it never makes or implies an architectural decision.

## 3. Ask, one topic at a time

Ask about each of these in turn. Do not batch them into a single wall-of-text question; this is a one-time setup, not a full survey, but each choice deserves its own moment.

**Issue tracker.** Where should `to-issues` create work items?
- `github`: uses `gh issue create`. Check `gh auth status` and that the current directory is inside a repo with a GitHub remote; tell the user plainly if either check fails, rather than silently falling back.
- `linear`: uses the Linear MCP tools if connected, otherwise the user provides team/workspace details as plain config (never store API keys or secrets in `config.json` - if a key is needed, tell the user to set it up via their own Linear MCP connection or environment, and only record the team/workspace identifier here).
- `local`: no external tracker. Work items are appended to each feature's `tasks.md`.

**Docs location.** Default `docs/groundwork/`. Accept an override, but keep it a single directory - the whole layout in this skill assumes one root.

**Triage labels.** Optional. Only meaningful for `github`/`linear`. A short list of labels `to-issues` applies to every issue it creates (e.g. `groundwork`) - pick something that doesn't collide with whatever label string `triage` ends up using for any of its five state roles (their canonical names by default, or this repo's own mapping if you set one via `triage_role_labels` below), or its issues will be indistinguishable from ones still awaiting triage. Skip for `local`.

**Triage role labels.** Optional, and a separate thing from the list above - only ask if the user says they'll use `/groundwork:triage`, and only meaningful for `github`/`linear` (skip for `local`, same as the config above). `triage` moves an issue through five canonical *state* roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) and needs to know the actual label string for each one - `triage_role_labels` covers only these five; the `bug`/`enhancement` *category* roles are fixed and not configurable here. Default: each state role's label equals its name. Ask if any should map to a different existing label in this repo's tracker (e.g. role `needs-triage` -> label `bug:triage`); only record the ones that differ.

**Rules file.** Where repo-level rules live:
- `claude` (default): groundwork writes `CLAUDE.md` at the repo root. Right choice for a Claude-only repo.
- `agents`: for a multi-tool repo (Cursor, Codex, Copilot, etc. also read this repo). groundwork writes `AGENTS.md` as the portable source of truth, plus a thin `CLAUDE.md` whose body is `@AGENTS.md` and nothing else except any Claude-specific overrides. Never duplicate rule content across the two files - if a rule applies to every tool, it lives only in `AGENTS.md`.

## 4. Write the config

Create the docs directory and write `docs/groundwork/config.json`:

```json
{
  "version": 1,
  "tracker": "github",
  "docs_dir": "docs/groundwork",
  "triage_labels": [],
  "triage_role_labels": {},
  "rules_file": "claude",
  "project_type": "existing",
  "detected_stack": {
    "language": "...",
    "framework": "...",
    "package_manager": "...",
    "notes": "..."
  }
}
```

Adjust fields to what was chosen. For `tracker: "github"`, you may add a `"github": {"repo": "owner/name"}` block detected from the remote. For `tracker: "linear"`, add `"linear": {"team": "..."}` if the user gave one. `triage_role_labels` only needs entries for roles whose label differs from its own name - leave it `{}` if none do. Never write secrets into this file.

Set `project_type` to `"existing"` or `"greenfield"` per step 2. Only include `detected_stack` for `"existing"` - populate it with what was actually found, nothing invented. For `"greenfield"`, omit `detected_stack` entirely (or leave it `null`); the stack gets decided later, in `/groundwork:survey`, and recorded as ADRs, not here.

## 5. Seed the docs

If they don't already exist, create:
- `docs/groundwork/glossary.md` from `${CLAUDE_SKILL_DIR}/templates/glossary.md`
- `docs/groundwork/STATE.md` from `${CLAUDE_SKILL_DIR}/templates/STATE.md`

Leave both mostly empty; other skills fill them in as work happens. Do not translate or rewrite the template headers - later skills add content in whatever language the conversation is in, not a language baked in here.

## 6. Write the rules file

- `rules_file: "claude"`: if `CLAUDE.md` already exists at the repo root, leave its content alone and just confirm it's there. If it doesn't exist, create a minimal one that documents that this repo uses groundwork and points at `docs/groundwork/`.
- `rules_file: "agents"`: create `AGENTS.md` at the repo root if it doesn't exist (minimal, same content as above). Create or update `CLAUDE.md` so its body is exactly `@AGENTS.md` plus, only if needed, a short "Claude-specific" section below it. If `CLAUDE.md` already has unrelated content, ask before overwriting it rather than clobbering the user's existing rules.

## 7. Confirm and hand off

Tell the user what was created. Suggest a next step based on where they are:
- Have an idea but no plan yet -> `/groundwork:brainstorm`
- Already talked through a plan in this conversation -> `/groundwork:to-prd`
- Have inbound issues already sitting in the tracker -> `/groundwork:triage`
- Just want setup done for now -> stop here.

Never re-run this interview automatically. If another groundwork skill can't find `docs/groundwork/config.json`, it should tell the user to run `/groundwork:setup` rather than guessing or asking the same questions inline.
