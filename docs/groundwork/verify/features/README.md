# Feature map

What groundwork does, from the outside. groundwork has no runtime: what it ships is a skills
tree that an agent loads, so a "feature" here is a skill an agent can find, load, and follow
to the end without hitting a reference that goes nowhere.

## Sweep order

Top to bottom. Earlier entries are preconditions for later ones - a broken install makes every
other result meaningless, so a sweep that fails on it should stop rather than cascade.

1. [Installing the skills](0001-installing-the-skills.md)
2. [Loading and following a skill](0002-loading-a-skill.md)

## Conventions

- One user-visible feature per file, four fixed questions each.
- Behaviour, never implementation.
- Update the entry in the same change that alters the behaviour.
