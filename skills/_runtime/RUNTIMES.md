# Runtime capabilities groundwork relies on

groundwork skills are plain prose. They are meant to be readable and executable by any
coding agent that can load a skill, not only by the runtime they were first written for.

Three capabilities are the only places where a runtime's own primitives matter. Every skill
that needs one describes it in neutral terms and points here. If your runtime does not
provide one, the degraded path below is always correct - slower, never wrong.

## 1. Load a sibling skill

**What groundwork needs:** an orchestrator finishing its stage hands off to the next one
inside the same session, without waiting for the user to invoke it. `brainstorm` hands off
to `survey`, `build` to `validate`, `validate` to `code-review`.

**How to satisfy it:** load the named groundwork skill and follow it. If your runtime cannot
address a skill by name, read the file directly - the skills sit side by side, so from any
skill the sibling is at `../<name>/SKILL.md`, and from the install root at
`skills/<name>/SKILL.md`.

**Degraded path:** none needed. Reading the file always works.

## 2. Dispatch independent workers

**What groundwork needs:** several units of work that share no state, run at the same time,
each in its own context so one worker's findings cannot bias another's.

Three skills use it, and the isolation is the point in all three:

| Skill | Workers | Why they must not share context |
| --- | --- | --- |
| `survey` (map speed) | one `researcher` per research ticket | each answers one question from sources; a shared context lets one ticket's findings contaminate another's |
| `build --parallel` | one `slice-builder` per unblocked AFK slice | slices are independent by construction; sharing a context would serialize them for no reason |
| `code-review` | `standards-reviewer` and `spec-reviewer` | the two axes are deliberately blind to each other, so neither anchors on the other's findings |

**How to satisfy it:** use whatever primitive your runtime has for running a subordinate
agent with its own context - a subagent, a worker, a task, a background session. Give each
worker only the brief for its own unit of work.

**Degraded path:** run the units one after another in the main agent, and **start each one
from a clean reading of its own brief**. Say once that you are running sequentially because
the runtime has no worker primitive. Never skip a unit, and never merge two units into one
pass to save time - for `code-review` in particular, running the two axes sequentially is
acceptable but running them as a single combined review is not: that destroys the isolation
the two axes exist for.

## 3. Isolate a worker's filesystem

**What groundwork needs:** when several workers write code at once, each needs its own
working tree so two slices never write the same file.

**How to satisfy it:** `git worktree` is the mechanism, and the `worktree` skill describes
it. Some runtimes create one per worker automatically; if yours does, let it, and do not
also create one by hand.

**Degraded path:** if worktrees are unavailable, do not run writers in parallel at all. Fall
back to sequential building in the main tree. Parallel writers in one directory corrupt each
other, so this is the one case where the degraded path is mandatory rather than a preference.

## Distribution

`skills/` is the whole install surface. Nothing inside it refers to a specific runtime's
environment variables or tool names, so the directory can be installed anywhere a runtime
looks for skills. `install.sh` symlinks it into `~/.agents/skills/`, which several agents
read directly.

`agents/` sits outside that surface on purpose. Those files describe subagents in Claude
Code's own format - fields like `model`, `effort` and `maxTurns` have no portable meaning.
Agent names appear in the skills as `groundwork:<name>` - the address Claude Code uses for a
plugin's agents. A runtime that does not namespace agents should read that as the bare name.

A runtime with a different worker format should translate the role described in each file
rather than copy the frontmatter: what the worker is for, what it may not do, and what it
must return are stated in the body of every agent file, which is the portable part.
