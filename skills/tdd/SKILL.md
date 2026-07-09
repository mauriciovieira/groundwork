---
name: tdd
description: Internal groundwork technique - red-green-refactor loop, one vertical slice at a time. A failing test per acceptance criterion first, then minimal code to pass, then refactor. Used by build; not meant to be invoked outside an active groundwork build session.
---

# groundwork:tdd

Red, green, refactor - per acceptance criterion, not per slice as a whole.

## The loop

For each acceptance criterion of the slice being built:

1. **Red**: write a test that captures the criterion and watch it fail. Do not write any implementation first. If you can't state the criterion as a test, that's a sign the criterion itself is still too vague - go back to the PRD rather than guessing.
2. **Green**: write the minimum code that makes the test pass. Resist adding anything the criterion doesn't require - that belongs to a later criterion or isn't in scope at all.
3. **Refactor**: with the test suite green, clean up - naming, duplication, structure - without changing behavior. Re-run tests after every refactor step.
4. Move to the next acceptance criterion and repeat.

## Rules

- Never write implementation code with no failing test driving it. If you catch yourself doing that, stop, write the test, watch it fail, then continue.
- Keep the loop scoped to the slice at hand. A test that exercises a different slice's behavior belongs in that slice's pass, not this one.
- If an acceptance criterion turns out to be untestable as stated, that's a gap in the slice definition - flag it to the calling orchestrator rather than inventing a criterion that wasn't in the PRD.
