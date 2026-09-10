---
name: how
description: Use when someone asks how something works - "how does X happen", "walk me through this flow", "where does this actually run". Explains behaviour from the feature map first, then traces the mechanism in the code. Read-only.
argument-hint: "[what to explain]"
---

# groundwork:how

Explain how something actually works, from the outside in.

## 1. Start from behaviour, not code

If this repository has a feature map, read the relevant entry under
`<docs_dir>/verify/features/` first. It says what the feature does, how a person reaches it,
and what proves it worked - all in behavioural terms, which is where an explanation should
start. Reading it costs a page; reconstructing the same picture from source costs far more and
is easier to get wrong.

Read `glossary.md` too when the area has domain vocabulary, so your explanation uses the
project's words rather than inventing parallel ones.

If there is no feature map, say so once and trace from the code. `verify --init` is what
creates one.

## 2. Trace the mechanism

Follow the actual path: entry point, what it calls, where state is read and written, where it
ends. Prefer reading the code over guessing from names - a function called `validate` may not
validate.

When the area is large, this is a good use of independent workers, one per path, so the
tracing is not done one file at a time in a single context. See `../_runtime/RUNTIMES.md`.

Note where behaviour is decided by configuration, an environment variable, or a feature flag
rather than by the code path - that is the most common reason a correct-looking trace does not
match what actually happens in production.

## 3. Explain

Lead with the shape - the two or three steps someone needs to hold in their head - then go
into detail. Name concrete files and functions so the reader can go and look.

Say what you did not check. A trace that skipped an error path or a background job is still
useful, but only if its edges are stated. Silence about a gap reads as coverage.

If the mechanism contradicts what the feature map says, that is a finding worth more than the
explanation: report it, and offer `verify --sync` to correct the map.

For the reasoning behind a design rather than its mechanics, use `why`. The two compose: the
mechanism plus the rationale is a complete explanation, and there is no separate skill for
that combination because there does not need to be.

This skill writes nothing.
