# Installing the skills

Getting groundwork onto a machine so an agent can find it.

## What exists today

Three install paths. Claude Code installs the plugin from the marketplace and reads
`.claude-plugin/`. Codex reads `.codex-plugin/plugin.json`, which points at the same `skills/`
tree. Everything else runs `install.sh`, which symlinks each skill into `~/.agents/skills`.

`install.sh` refuses to overwrite a name it does not own, and links the underscore directories
(`_runtime`, `_shared`) alongside the skills because the skills reference them as siblings.

## How a person gets here

`/plugin install groundwork` on Claude Code, or `./install.sh` from a clone. `--dry-run` shows
what would happen first; `--uninstall` removes only the links pointing back at that clone.

## How an agent drives it

```
./control launch
./control doctor
```

Observable outcome: every skill directory present in the install, the underscore directories
present alongside them, and the three manifests parsing and agreeing on a version.

## Known failure modes

- A skill name already taken by another source is skipped, not overwritten, and the count in
  the summary drops. That is correct behaviour, not a failure, but it means a partial install
  looks like a successful one unless the count is read.
- Dropping the underscore directories leaves every `../_runtime/` reference dangling. Nothing
  in the install itself complains; `drive` is what catches it.
