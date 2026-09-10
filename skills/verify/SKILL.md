---
name: verify
description: Prove a feature actually works by driving the running application and capturing evidence, rather than trusting a green test suite. Builds the project's own verification CLI and feature map on first use, runs a verification on demand, and keeps the map in step with the app.
disable-model-invocation: true
argument-hint: "[feature-slug] [--init] [--sync]"
---

# groundwork:verify

A passing test is the agent grading its own homework. This skill exists so a slice can be
shown working, not asserted working.

The idea, and the shape of the asset below, are adapted from the pstack articles credited in
this repository's `NOTICE`.

## What this builds

Verification lives in the repository being worked on, not inside this plugin and not inside
any one agent's directory, so a human at a terminal and any agent can run the same thing.
Everything below sits under the configured `docs_dir` (`docs/groundwork` by default):

```
<docs_dir>/verify/
  README.md            how to launch, check health, drive, prove, and clean up
  control              the project's own CLI - executable, any language
  features/
    README.md          the index, and the order to sweep them in
    NNNN-slug.md       one file per feature
  evidence/            scratch space, gitignored
```

Two things earn their keep here.

**The CLI is the lever.** Prose telling an agent how to run your app is re-read and
re-interpreted every session. A command is not. `control` is a real program in whatever
language the project already uses, with subcommands, a `--dry-run` for anything destructive,
machine-readable output behind `--json`, and help text worth reading.

**The feature map is behaviour, not code.** Each file answers the same four questions, so an
agent can drive a feature without opening the source. The glossary names the domain; the
feature map says what the product actually does and how to see it doing it.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, don't stop - bootstrap it per the
"Lazy bootstrap" section of the groundwork `setup` skill, then continue.

Read `docs_dir` from the config and resolve every path below against it. Never hardcode
`docs/groundwork`; a repository is free to have moved it.

If the config has no `verify` block and `--init` was not passed, say so in one line and run
`--init` first - there is nothing to verify with yet.

## 1. `--init`: build the verification asset

Do not write the CLI from guesswork. Find out how this project actually runs, then build.

1. **Read before asking.** Check the README, `package.json` scripts, `Makefile`, `Procfile`,
   compose files, CI workflows, and any existing test setup. Most of the answers are already
   written down somewhere.
2. **Interview for what's left.** Use the `groundwork:interview-loop` technique, one question
   at a time, and only for what you could not find: how the app is started for local use,
   what it needs to be healthy (database, migrations, seed data, a logged-in user), how a
   developer normally drives it, and what counts as visible proof that something worked.
3. **Write `control`.** Give it these subcommands at minimum, and add whatever this project
   needs beyond them:
   - `launch` - start the app in a state ready to be driven, and return only when it is
   - `doctor` - check preconditions and report what is wrong, never fix silently
   - `drive <feature>` - exercise a feature the way a user would
   - `prove <feature>` - capture evidence of the outcome into `evidence/`
   - `clean` - return the machine to the state it was in before `launch`

   Rules: any subcommand that destroys or mutates shared state takes `--dry-run` and prints
   exactly what it would do. Every subcommand supports `--json`. Errors say what failed, what
   was expected, and what to try next.
4. **Seed the feature map.** Walk the codebase and write one file per user-visible feature
   from `templates/feature.md`, plus the index from `templates/features-README.md`. Base the
   files on behaviour you can see, and mark anything you inferred rather than confirmed.
5. **Run it once before handing over.** Execute `doctor`, then `drive` and `prove` on one
   feature. If any of that fails, fix it now. Do not deliver a verification asset you have
   not seen work - that is the exact failure this skill exists to prevent.
6. **Record it in the config**, with paths relative to `docs_dir`:

   ```json
   "verify": { "cli": "verify/control", "evidence_dir": "verify/evidence" }
   ```

   Add `<docs_dir>/verify/evidence/` to `.gitignore`.

## 2. Running a verification

Given a feature slug, or the feature a slice touches:

1. Read the feature map entry. If none exists, say so and stop - verifying against an
   unwritten expectation proves nothing. Write the entry first, or run `--sync`.
2. `control doctor`. If the environment is not healthy, report that and stop. A failed
   verification and an unrunnable app are different results and must never be reported alike.
3. `control drive <feature>`, then `control prove <feature>`.
4. Report one of three outcomes, never a bare pass or fail:
   - **proven** - the expected observable outcome happened, and here is the evidence
   - **disproven** - the app ran and did something other than what the feature map says
   - **not verifiable** - the app would not run, or the feature has no observable outcome
     defined yet. This is not a pass.

### Where the evidence actually lives

`evidence/` is gitignored scratch. It disappears when a worktree is removed, so a file path
in it is worthless to anyone on another machine or in a later session.

The proof of record is the artifact itself, posted to the tracker: pasted into the issue
comment, or into the PR body when the slice became a PR. A screenshot, a log excerpt, a
captured response - small enough to read inline. If the evidence is too large for that,
summarise it inline and say where the full artifact came from.

## 3. `--sync`: keep the map honest

A feature map that drifts is worse than none, because it is trusted. Reconcile it against the
app:

- features in the code with no map entry - write one
- map entries whose described path no longer exists - correct them, or delete the entry if
  the feature is gone, and say which you did
- entries no verification has exercised in a long time - flag them, don't quietly trust them

Run this when features land or change. `build` triggers it at the end of a pass; running it
by hand periodically is worth it on a codebase moving faster than its map.

## 4. Hand off

After a verification, report the outcome and the evidence, then stop. This skill proves or
disproves; it does not fix. A disproven feature goes back to `build` with the specific
mismatch, and `validate` is what decides whether the feature as a whole is done.
