# Verifying this project

How to see this application actually working. Written for an agent to execute and for a
person to read, and kept true by `groundwork:verify --sync`.

`control` is the entry point for all of it. Run `./control --help` for the full list.

## Launch

<!-- The one command that starts the app ready to be driven, and what it needs first. -->

```
./control launch
```

## Doctor

Check that the environment is healthy before trusting any result. A failed verification and
an app that would not start are different outcomes and must never be reported as the same
thing.

```
./control doctor
```

<!-- List what doctor checks: services, migrations, seed data, credentials, ports. -->

## Drive

Exercise a feature the way a user would.

```
./control drive <feature>
```

<!-- Name the feature slugs, or point at features/README.md as the list. -->

## Prove

Capture evidence of the outcome.

```
./control prove <feature>
```

Evidence lands in `evidence/`, which is gitignored scratch. The proof of record is the
artifact itself pasted into the issue or PR - a path into `evidence/` means nothing to anyone
on another machine or in a later session.

## Clean up

Return the machine to the state it was in before `launch`.

```
./control clean
```

## Conventions

- Anything that destroys or mutates shared state takes `--dry-run` and prints what it would do.
- Every subcommand supports `--json`.
- Errors say what failed, what was expected, and what to try next.
