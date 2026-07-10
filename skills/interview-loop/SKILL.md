---
name: interview-loop
description: Internal groundwork technique - the one-question-at-a-time interview loop that resolves every branch of a decision tree. Used by groundwork orchestrators such as survey when they need a rigorous interview. Not a user-invoked command; do not invoke on its own outside an active groundwork orchestrator, and it has no file-writing behavior by itself.
---

# groundwork:interview-loop

This is the interview technique itself, factored out so more than one orchestrator can use it. It does not write any files - the orchestrator that invokes it decides what to do with each resolved decision.

## The loop

1. Ask **one question at a time**. Never present a checklist of questions - the next question should depend on the last answer.
2. For every decision point you find, walk both branches before moving on: "what happens if X" and "what happens if not X" (or, for a choice among options, what happens under each option). A branch is not resolved until the consequence is stated and the user has confirmed it's acceptable or fixed it.
3. Hunt for what's unstated: edge cases, error states, empty states, concurrent or simultaneous access, scale limits, who else is affected by this decision, what happens on failure or retry. These are usually where the real design lives, not in the happy path.
4. Push back on vague answers. "It should handle that gracefully" is not an answer - ask what "gracefully" means concretely, with an example.
5. When an answer reveals a new branch you hadn't asked about, follow it before returning to your original thread. A good answer should redirect you, not just fill in a blank.
6. Track decisions as they land, tagging each one by what it affects: goal/scope/acceptance-criteria, an architectural or process decision with real tradeoffs, or a domain term worth naming. Hand this tagging to the calling orchestrator as you go - it's the one writing files.

## Stop condition

Stop when the design survives: you can no longer find an unresolved branch, or the user explicitly says it's good enough. Don't manufacture more questions once genuine ambiguity runs out - the goal is a sharp design, not a long transcript.
