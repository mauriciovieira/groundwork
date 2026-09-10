# Interface Design

Exploring alternative interfaces for a chosen deepening candidate. This is the module-shaped
specialisation of the general pattern in `../_shared/COMPETING-DESIGNS.md` - follow that
file for the process (fix criteria first, produce candidates independently, judge blind,
record as an ADR) and use what is below for the parts specific to module interfaces.

Uses the vocabulary in [LANGUAGE.md](LANGUAGE.md) - **module**, **interface**, **seam**,
**adapter**, **leverage**.

## Framing (step 2 of the shared pattern)

The problem space here is:

- The constraints any new interface would need to satisfy
- The dependencies it would rely on, and which category they fall into (see [DEEPENING.md](DEEPENING.md))
- A rough illustrative code sketch to ground the constraints - not a proposal, just a way to
  make the constraints concrete

## Criteria (step 1 of the shared pattern)

For a module interface, these are usually the ones that matter. Confirm them with the user
rather than assuming, and add whatever this particular module makes important:

- **Depth** - leverage per entry point. How much does a caller get for how much it must know?
- **Locality** - where does change concentrate when the requirements move?
- **Seam placement** - is the boundary in a place that will still make sense later?
- **Common-case cost** - what does the most frequent caller have to write?

## Biases for the candidates (step 3 of the shared pattern)

Give each worker one of these, so the candidates differ by construction:

- "Minimise the interface - aim for 1-3 entry points. Maximise leverage per entry point."
- "Maximise flexibility - support many use cases and extension."
- "Optimise for the most common caller - make the default case trivial."
- "Design around ports and adapters for cross-seam dependencies." (when applicable)

Include both [LANGUAGE.md](LANGUAGE.md) vocabulary and `docs/groundwork/glossary.md`
vocabulary in each brief, so candidates name things consistently with the architecture
language and the project's domain language.

## What each candidate returns

1. Interface (types, methods, params - plus invariants, ordering, error modes)
2. Usage example showing how callers use it
3. What the implementation hides behind the seam
4. Dependency strategy and adapters (see [DEEPENING.md](DEEPENING.md))
5. Trade-offs - where leverage is high, where it's thin
