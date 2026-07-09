---
name: worktree
description: Internal groundwork technique - create and manage a git worktree for a single slice, isolated branch and directory, cleanly mappable to one PR. Used by build when worktree isolation is requested; not meant to be invoked outside an active groundwork build session.
---

# groundwork:worktree

One slice, one worktree, one branch, one PR. Keeps parallel or long-running slice work from colliding with whatever else is happening in the main checkout.

## Create

From the repository root:

```sh
git worktree add -b <branch-name> .worktrees/<slug> <base-branch>
```

Name the branch after the slice (e.g. `feat/0007-thin-slice-title`), and derive `<slug>` from the same name. Base it off the branch the feature is targeting, not necessarily `main`, if the feature itself is already on a longer-lived branch.

## Work

Do all of the slice's work inside `.worktrees/<slug>`. Don't touch the main checkout while a worktree is active for the same slice - that's the isolation this technique exists for.

## Finish

Once the slice's tests pass and TDD is complete:

1. Push the branch.
2. If the configured tracker is `github`, open a PR with `gh pr create` from inside the worktree, referencing the slice's issue.
3. Report the branch (and PR link, if opened) back to whatever invoked this technique. Do not merge automatically - that's a human or a separate review step, not this technique's job.

## Clean up

After the branch merges (or is abandoned), remove the worktree and delete the local branch:

```sh
git worktree remove .worktrees/<slug>
git branch -d <branch-name>
```

Never force-remove a worktree or force-delete a branch with unmerged, uncommitted work without checking with the user first.
