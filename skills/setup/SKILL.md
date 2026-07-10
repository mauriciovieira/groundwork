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
- Ask whether they want to reconfigure, and if so, which fields (tracker, docs location, triage labels, rules file). Do not re-run the full interview blind.
- If they just want to confirm it's already set up, say so and stop.

If it does not exist, continue.

## 2. Ask, one topic at a time

Ask about each of these in turn. Do not batch them into a single wall-of-text question; this is a one-time setup, not a full survey, but each choice deserves its own moment.

**Issue tracker.** Where should `to-issues` create work items?
- `github`: uses `gh issue create`. Check `gh auth status` and that the current directory is inside a repo with a GitHub remote; tell the user plainly if either check fails, rather than silently falling back.
- `linear`: uses the Linear MCP tools if connected, otherwise the user provides team/workspace details as plain config (never store API keys or secrets in `config.json` - if a key is needed, tell the user to set it up via their own Linear MCP connection or environment, and only record the team/workspace identifier here).
- `local`: no external tracker. Work items are appended to each feature's `tasks.md`.

**Docs location.** Default `docs/groundwork/`. Accept an override, but keep it a single directory - the whole layout in this skill assumes one root.

**Triage labels.** Optional. Only meaningful for `github`/`linear`. A short list of labels to apply to created issues (e.g. `needs-triage`). Skip for `local`.

**Rules file.** Where repo-level rules live:
- `claude` (default): groundwork writes `CLAUDE.md` at the repo root. Right choice for a Claude-only repo.
- `agents`: for a multi-tool repo (Cursor, Codex, Copilot, etc. also read this repo). groundwork writes `AGENTS.md` as the portable source of truth, plus a thin `CLAUDE.md` whose body is `@AGENTS.md` and nothing else except any Claude-specific overrides. Never duplicate rule content across the two files - if a rule applies to every tool, it lives only in `AGENTS.md`.

## 3. Write the config

Create the docs directory and write `docs/groundwork/config.json`:

```json
{
  "version": 1,
  "tracker": "github",
  "docs_dir": "docs/groundwork",
  "triage_labels": [],
  "rules_file": "claude"
}
```

Adjust fields to what was chosen. For `tracker: "github"`, you may add a `"github": {"repo": "owner/name"}` block detected from the remote. For `tracker: "linear"`, add `"linear": {"team": "..."}` if the user gave one. Never write secrets into this file.

## 4. Seed the docs

If they don't already exist, create:
- `docs/groundwork/glossary.md` from `${CLAUDE_SKILL_DIR}/templates/glossary.md`
- `docs/groundwork/STATE.md` from `${CLAUDE_SKILL_DIR}/templates/STATE.md`

Leave both mostly empty; other skills fill them in as work happens. Do not translate or rewrite the template headers - later skills add content in whatever language the conversation is in, not a language baked in here.

## 5. Write the rules file

- `rules_file: "claude"`: if `CLAUDE.md` already exists at the repo root, leave its content alone and just confirm it's there. If it doesn't exist, create a minimal one that documents that this repo uses groundwork and points at `docs/groundwork/`.
- `rules_file: "agents"`: create `AGENTS.md` at the repo root if it doesn't exist (minimal, same content as above). Create or update `CLAUDE.md` so its body is exactly `@AGENTS.md` plus, only if needed, a short "Claude-specific" section below it. If `CLAUDE.md` already has unrelated content, ask before overwriting it rather than clobbering the user's existing rules.

## 6. Confirm and hand off

Tell the user what was created. Suggest a next step based on where they are:
- Have an idea but no plan yet -> `/groundwork:brainstorm`
- Already talked through a plan in this conversation -> `/groundwork:to-prd`
- Just want setup done for now -> stop here.

Never re-run this interview automatically. If another groundwork skill can't find `docs/groundwork/config.json`, it should tell the user to run `/groundwork:setup` rather than guessing or asking the same questions inline.
