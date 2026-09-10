---
name: code-review
description: Use when the user asks for a review of the current diff, branch, or recent changes in a repo that uses groundwork. Reviews the diff since a fixed point using two independent workers - a Standards axis and a Spec axis - so neither pollutes the other's context, then merges both reports.
argument-hint: "[since-ref]"
---

# groundwork:code-review

Two independent reviews, run in parallel so neither agent's findings bias the other's, then merged into one report.

## 1. Determine the diff

Figure out the fixed point to diff against: an argument if one was given (a commit, branch, or tag), otherwise the merge-base with the feature's target branch, or ask if it's genuinely ambiguous. Confirm the range before dispatching anything.

## 2. Run both reviewers as independent workers

Run `groundwork:standards-reviewer` and `groundwork:spec-reviewer` as two independent workers, each in its own context, each given the diff (or the ref range to diff themselves) and, for the spec reviewer, the feature slug and the issue/slice this diff claims to close. Start both before waiting on either.

The isolation is the point here, not the speed - neither axis may see the other's findings. If this runtime has no worker primitive, run them one after the other, each from a clean reading of its own brief, and say so once. Never collapse the two axes into a single combined review; that destroys the independence they exist for. See `skills/_runtime/RUNTIMES.md`.

## 3. Merge the reports

Combine both agents' findings into a single report, grouped by file, most-severe first across both axes. Don't just concatenate the two reports - if both agents flagged the same location for different reasons, present it once with both concerns noted. Attribute each finding to its axis (Standards or Spec) so the user can tell which kind of problem it is.

## 4. Present

Show the merged report. Do not apply fixes automatically unless the user asks - this is a review, not an auto-fix pass.
