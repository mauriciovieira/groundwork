---
name: why
description: Use when someone asks why the code is the way it is - "why do we do it this way", "who decided this", "is this intentional or an accident". Recovers the reasoning behind a decision from the ADRs first, then git history, the tracker, and the out-of-scope record. Read-only.
argument-hint: "[what to explain]"
---

# groundwork:why

Recover the reasoning behind something, and be honest when the reasoning is not recoverable.

This is cheap in a groundwork repository because the artifacts already exist. Recording
decisions is what ADRs are for; this is the skill that spends them.

## 1. Read the decisions first

Look in the ADRs before anything else:

- `docs/groundwork/adr/` - project-wide decisions, including the implementation stack
- `docs/groundwork/features/NNNN-slug/adr/` - decisions scoped to one feature

An ADR's **Context** is usually the actual answer, and its Consequences say what the project
signed up for. Check the Status: a `Superseded` ADR explains what someone used to think, and
the ADR that superseded it explains what changed their mind. Both are worth reporting, in that
order - the reversal is often the most useful part.

## 2. Then the rest, in descending order of reliability

- **`prd.md`** - if the answer is "because the product needs it", this is where that lives
- **`.out-of-scope/`** - if the question is why something *isn't* there, this is the record
  of concepts that were deliberately rejected, and it exists precisely so the same idea does
  not get re-litigated
- **`git log` and `git blame`** - the commit that introduced it, and the PR it came from
- **the tracker** - the issue behind that PR, and any discussion on it
- **`glossary.md`** - when the confusion is really about what a term means

## 3. Answer, and grade your own certainty

Say what the reason was and where you found it. Then say how confident you are, in these
terms:

- **Decided** - an accepted ADR says so. Quote it.
- **Recorded** - a PRD, issue, or commit message states it, though nobody wrote it up as a
  decision.
- **Inferred** - you reconstructed it from the code and the history. Say so plainly, and say
  what would confirm it.
- **Lost** - nothing explains it. Say that instead of constructing a plausible story. An
  invented rationale is worse than an admitted gap, because it gets repeated.

If the answer turns out to be "decided, but the decision was never written down", offer to
capture it as an ADR through `survey`. That is how a `Lost` becomes a `Decided` for the next
person to ask.

This skill writes nothing on its own.
