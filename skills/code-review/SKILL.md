---
name: code-review
description: Review the diff since a fixed point using two parallel sub-agents - a Standards axis and a Spec axis - so neither pollutes the other's context, then merge both reports.
disable-model-invocation: true
argument-hint: "[since-ref]"
---

# groundwork:code-review

Two independent reviews, run in parallel so neither agent's findings bias the other's, then merged into one report.

## 1. Determine the diff

Figure out the fixed point to diff against: an argument if one was given (a commit, branch, or tag), otherwise the merge-base with the feature's target branch, or ask if it's genuinely ambiguous. Confirm the range before dispatching anything.

## 2. Dispatch both reviewers in parallel

Dispatch `groundwork:standards-reviewer` and `groundwork:spec-reviewer` at the same time, each with the diff (or the ref range to diff themselves) and, for the spec reviewer, the feature slug and the issue/slice this diff claims to close. Run them concurrently - do not wait for one to finish before starting the other.

## 3. Merge the reports

Combine both agents' findings into a single report, grouped by file, most-severe first across both axes. Don't just concatenate the two reports - if both agents flagged the same location for different reasons, present it once with both concerns noted. Attribute each finding to its axis (Standards or Spec) so the user can tell which kind of problem it is.

## 4. Present

Show the merged report. Do not apply fixes automatically unless the user asks - this is a review, not an auto-fix pass.
