---
name: improve-codebase-architecture
description: Find deepening opportunities in a codebase, informed by the domain language in docs/groundwork/glossary.md and the decisions in docs/groundwork/adr/ (or the current feature's adr/). Use periodically, alongside the main brainstorm/grill/build flow, when the user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more testable and AI-navigable.
disable-model-invocation: true
---

# groundwork:improve-codebase-architecture

Surface architectural friction and propose **deepening opportunities** - refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

This is a periodic, standalone check, not a required stop in the `brainstorm -> ... -> build -> validate -> code-review` chain. Run it whenever the codebase feels like it's accumulating friction, independent of any single feature in flight.

## 0. Preconditions

Read `docs/groundwork/config.json`. If it doesn't exist, tell the user to run `/groundwork:setup` first and stop.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point - don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** - anything with an interface and an implementation (function, class, package, slice).
- **Interface** - everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** - the code inside.
- **Depth** - leverage at the interface: a lot of behavior behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** - where an interface lives; a place behavior can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** - a concrete thing satisfying an interface at a seam.
- **Leverage** - what callers get from depth.
- **Locality** - what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is _informed_ by the project's domain model. `docs/groundwork/glossary.md` gives names to good seams; accepted ADRs record decisions the skill should not re-litigate.

## Process

### 1. Explore

Read `docs/groundwork/glossary.md` and any ADRs in the area you're touching first - check `docs/groundwork/adr/` for system-wide decisions not tied to one feature, and the relevant feature's `docs/groundwork/features/NNNN-slug/adr/` if the area maps to work already in flight.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics - explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** - interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user - `xdg-open <path>` on Linux, `open <path>` on macOS, `start "" "<path>"` on Windows (the empty `""` avoids `cmd` treating a quoted path as the window title) - and tell them the absolute path.

The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via CDN** for diagrams where a graph/flow/sequence reliably communicates the structure. Mix Mermaid with hand-crafted CSS/SVG visuals - use Mermaid when relationships are graph-shaped (call graphs, dependencies, sequences), and hand-built divs/SVG when you want something more editorial (mass diagrams, cross-sections, collapse animations). Each candidate gets a **before/after visualization**. Be visual.

For each candidate, the same template as before, but rendered as a card:

- **Files** - which files/modules are involved
- **Problem** - why the current architecture is causing friction
- **Solution** - plain English description of what would change
- **Benefits** - explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram** - side-by-side, custom-drawn, illustrating the shallowness and the deepening
- **Recommendation strength** - one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**Use `docs/groundwork/glossary.md` vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If the glossary defines "Order," talk about "the Order intake module" - not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly in the card (e.g. a warning callout: _"contradicts ADR-0007 - but worth reopening because..."_). Don't list every theoretical refactor an ADR forbids.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a `groundwork:grilling` session. Walk the design tree with them - constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline as decisions crystallize:

- **Naming a deepened module after a concept not in the glossary?** Add or update an entry in `docs/groundwork/glossary.md` - a term and the one thing a newcomer must know to use it correctly, same format `grill` uses.
- **Sharpening a fuzzy term during the conversation?** Update `docs/groundwork/glossary.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing - skip ephemeral reasons ("not worth it right now") and self-evident ones.

  Write it in Nygard format, same as `grill`:

  ```markdown
  # MMMM. Title

  ## Status
  Accepted

  ## Context
  What forces are at play, including the option(s) considered.

  ## Decision
  What was decided.

  ## Consequences
  What becomes easier or harder as a result.
  ```

  If the candidate belongs to a feature already in flight, number it into that feature's `docs/groundwork/features/NNNN-slug/adr/`, scoped and sequenced the same way `grill` does. Otherwise - most deepening work isn't tied to a single feature - write it to `docs/groundwork/adr/MMMM-title.md` (create the directory lazily if it doesn't exist yet), sequenced independently of any feature. Either way, ADRs are **append-only** once `Accepted`: a change of mind is a new ADR that supersedes the old one, never an edit to a decided one.

- **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

Write everything in the language the conversation has been in. No em dashes in any generated document.
