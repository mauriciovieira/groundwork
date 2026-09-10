# Loading and following a skill

An agent opening a skill and being able to act on it end to end.

## What exists today

Each skill is a `SKILL.md` with YAML frontmatter carrying at least `name` and `description`.
Skills reference three things that have to resolve: sibling reference directories as
`../_runtime/` and `../_shared/`, other skills by name for hand-offs, and agents as
`groundwork:<name>`.

Those references are written relative to the skill, so they resolve both inside a plugin tree
and in a flat `~/.agents/skills` install.

## How a person gets here

Invoking a skill by name in whichever agent they use, or reading the file directly.

## How an agent drives it

```
./control drive <skill>
./control drive all
./control prove all
```

Observable outcome: for each skill, the frontmatter name matches its directory, a description
exists, every `../_` reference points at something present in the install, and every
`groundwork:<name>` resolves to an installed skill or a file in `agents/`.

References are resolved **textually**, not by following symlinks. Following them would resolve
back into the source tree and report a broken install as healthy.

## Known failure modes

- A reference written from the plugin root (`skills/_runtime/...`) instead of from the skill
  (`../_runtime/...`) resolves under Claude Code and dangles in a flat install. This has
  happened once already.
- An agent named in a skill but absent from `agents/` fails only at dispatch time, long after
  the skill was read.
