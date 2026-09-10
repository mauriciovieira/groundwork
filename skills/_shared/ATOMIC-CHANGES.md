# Atomic changes

How to move through a slice: one transformation at a time, from a base you have confirmed is
green, ordered so that stopping anywhere leaves the repository no worse than you found it.

Adapted from the `atomic-changes` skill by Dan Kubb (@dkubb), credited in this repository's
`NOTICE`, onto groundwork's own model. `to-issues` already decides how work is cut into
slices; this governs the commits inside one.

## Verify the foundation first

Before touching anything, run the gates on the current state and confirm they pass. If they
do not, stop and say so - repair it or surface it, but do not start work on top of it.

This is not ceremony. Building on an unverified base means the first failure you hit is
ambiguous: you cannot tell your own breakage from what was already broken, and you will spend
the debugging effort on the wrong change. A cached green result is not a verified foundation
when there is any doubt; run the real thing.

## The floor: as small as possible, no smaller than whole

Split a slice into the smallest steps that each still leave the repository **whole** - passing
the gates that its change actually touches, and standing on its own without a follow-up commit
to avoid a regression.

That is the bound, not line count. A change small enough to leave a gate red, or that wires
half a feature, is too small: fold it into whatever makes it complete. Two changes that each
pass their gates alone are two steps; two that only pass together are one.

The burden runs one way. Splitting independent changes never needs an argument; combining them
always does, and "it is all one feature" is not that argument.

## Order: reduce before you add

Within a slice, do the kinds of change in this order:

**remove, fix, move, rename, refactor, change, add**

The reason is about the system, not the task. A risky addition laid down first spikes
complexity, and every later step piles onto a base nobody has exercised yet. Doing the
subtractive and structural work first ships the preparation early, exercises it, and surfaces a
bad decision before anything is built on top of it.

Two rules follow from it:

- **One kind of change per commit.** A commit that both refactors and adds is doing two things,
  and a reviewer cannot tell which half caused a failure. Split it.
- **A dependency comes before what depends on it.** That is the only hard constraint here; the
  order above breaks ties within it.

## Corrections stay visible

When you find a defect in work you just did, put the correction in its own commit aimed at the
one that introduced it - `git commit --fixup <sha>` - rather than amending.

Amending folds the change into history before anyone can review it, and quietly lets one
commit carry two transformations. Folding is a separate, deliberate step (`rebase --autosquash`)
and only on request.

A defect that predates this branch is not a fixup. It is its own `fix`, placed before the
additions that would otherwise sit on top of it.

## When a step fails

The cause is that step. Revert that one and leave the completed ones alone - that is the whole
point of having made them separately. Whatever you learn becomes new steps with their own
dependencies, not a wider revert.

## What this does not own

`to-issues` decides how a feature is cut into slices, and `tdd` drives red-green-refactor
inside one acceptance criterion. This sits between them: given a slice, how its work reaches
the history.
