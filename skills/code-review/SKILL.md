---
name: code-review
description: Use when the user asks for a review of the current diff, branch, or recent changes in a repo that uses groundwork. Reviews the diff since a fixed point using two independent workers - a Standards axis and a Spec axis - so neither pollutes the other's context, then merges both reports.
argument-hint: "[since-ref]"
---

# groundwork:code-review

Two independent reviews, run in parallel so neither agent's findings bias the other's, then merged into one report - with a third worker arbitrating only where the two axes contradict each other.

## 0. Preconditions

Read `docs/groundwork/config.json` if it exists. This skill needs only one thing from it, `judges.model`, and works fine without it - do not bootstrap a config just to run a review.

## 1. Determine the diff

Figure out the fixed point to diff against: an argument if one was given (a commit, branch, or tag), otherwise the merge-base with the feature's target branch, or ask if it's genuinely ambiguous. Confirm the range before dispatching anything.

## 2. Run both reviewers as independent workers

Run `groundwork:standards-reviewer` and `groundwork:spec-reviewer` as two independent workers, each in its own context, each given the diff (or the ref range to diff themselves) and, for the spec reviewer, the feature slug and the issue/slice this diff claims to close. Start both before waiting on either.

The isolation is the point here, not the speed - neither axis may see the other's findings. If this runtime has no worker primitive, run them one after the other, each from a clean reading of its own brief, and say so once. Never collapse the two axes into a single combined review; that destroys the independence they exist for. See `../_runtime/RUNTIMES.md`.

## 3. Look for contradictions

Read both reports and find the places where the two axes do not merely differ but **conflict**: one says the code must be a certain way and the other says that same thing is wrong. The usual shape is an accepted ADR mandating an approach that the standards baseline reads as a smell.

Two findings on the same line for unrelated reasons are not a conflict. Neither is one axis being silent where the other spoke. A conflict needs both axes to have an opinion about the same thing and for those opinions to be incompatible.

If there are none, skip step 4 entirely. Most reviews have none, and manufacturing one to have something to arbitrate is worse than having no arbiter at all.

## 4. Arbitrate the contradictions

For each real conflict, run the `groundwork:review-judge` worker with both findings, the code in question, and the ADR or standard each side is citing. If `config.json` carries a `judges.model` value, dispatch the judge on that tier explicitly; otherwise the agent's own default stands. Either way it must not be the tier the two reviewers ran on. Neither reviewer arbitrates its own finding - that is the whole reason this step is a separate worker rather than a judgement call in the merge.

The judge returns which side holds and why, or reports that the conflict is real and unresolvable at this level, which usually means an accepted ADR and the coding standards genuinely contradict each other and a person has to fix one of them. Say that plainly rather than picking a winner to look decisive.

## 5. Merge the reports

Combine both agents' findings into a single report, grouped by file, most-severe first across both axes. Don't just concatenate the two reports - if both agents flagged the same location for different reasons, present it once with both concerns noted. Attribute each finding to its axis (Standards or Spec) so the user can tell which kind of problem it is.

Where the judge ruled, show the ruling with the finding it settled, including the side that lost. A reader who cannot see what was overruled cannot disagree with it.

## 6. Present

Show the merged report. Do not apply fixes automatically unless the user asks - this is a review, not an auto-fix pass.
