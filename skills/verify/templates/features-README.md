# Feature map

What this application does, from the outside. One file per feature, each answering the same
four questions, short enough that an agent can drive the feature without opening the source.

This is not the glossary. `glossary.md` names the domain; this says what the product does and
how to watch it do it.

## Sweep order

Top to bottom is the regression order: earlier entries are preconditions for later ones, so a
full sweep that fails early should stop rather than cascade.

<!-- List every feature file in the order a full sweep should run them. -->

1. [Example feature](0001-example-feature.md)

## Conventions

- One user-visible feature per file. Split when the preconditions stop fitting in a sentence.
- Behaviour, never implementation. If a file needs a file path to make sense, it is describing
  the code rather than the feature.
- Update the entry in the same change that alters the behaviour. A map that drifts is worse
  than no map, because it is trusted.
