# Competing designs, judged blind

Your first idea is rarely your best one, and the agent that produced an idea is the worst
available judge of it. This is the pattern for any decision with real design space: produce
several genuinely different candidates, then have something that did not write them choose.

Based on "Design It Twice" (Ousterhout). Reach for it when a decision has more than one
defensible answer, not for every decision - most have an obvious shape, and running a
bake-off over an obvious question wastes everyone's time and produces three variations of the
same idea dressed up as alternatives.

## 1. Fix the criteria before you see any candidate

Write down what would make one design better than another, and do it **first**. Criteria
invented after the candidates exist are a rationalisation of whichever one you already liked.

Three to five criteria, each one something a design can visibly succeed or fail at. State
which matter most. Show them to the user before going further - this is the step where a
wrong assumption is cheapest to catch.

## 2. Frame the problem space

Write a short explanation of the constraints any answer has to satisfy, and what depends on
this decision. Ground it with a rough sketch if that makes the constraints concrete - not a
proposal, just something to argue with.

Show it to the user, then start step 3 immediately. They read while the work runs.

## 3. Produce candidates independently

Run 3 or more workers, each producing a **radically different** answer. Each needs its own
context. A worker that has seen another's sketch converges on it, and convergence is the one
outcome that makes this whole exercise pointless.

Give each a different bias, so the candidates differ by construction rather than by luck.
The biases depend on the decision; whatever they are, they should pull in genuinely opposite
directions. A caller of this file supplies its own list.

If this runtime has no worker primitive, produce the sketches one at a time and do not re-read
an earlier sketch before writing the next. See `../_runtime/RUNTIMES.md`.

## 4. Judge blind

Hand the candidates to the `groundwork:design-judge` worker, stripped of any hint about who
produced which - no ordering that matches the brief order, no labels carrying the bias that
generated them. Give it the criteria from step 1 and nothing else.

Do not judge them yourself. You commissioned them; you have already formed a preference, and
the point of this step is that the choice survives someone not having done that.

The judge returns a ranking, a score per criterion, and the specific reason each losing
candidate lost. It may report that two candidates are genuinely tied, or that none of them
satisfies the criteria - both are real results and neither should be smoothed over.

## 5. Present, and let the user overrule

Show the candidates, the criteria, and the judge's verdict including the reasons the losers
lost. Add your own read if it differs from the judge's, and say plainly that it differs.

The user decides. The judge exists to stop the author grading their own work, not to take the
decision away from a person.

## 6. Record it

A decision with a real design space is exactly what an ADR is for. Write one in Nygard form:

- **Decision** - the design that won
- **Context** - the criteria, the candidates that lost, and why. This is the half people skip
  and the half that stops the same bake-off being re-run in six months.
- **Consequences** - what this commits the project to

Rejected candidates belong in Context. Do not invent a separate artifact for them; the format
already has the place.
