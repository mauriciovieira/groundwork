# Changelog

All notable changes to this project are documented in this file.

## [2.4.0] - 2026-09-10

### Added

- verify the foundation and commit one transformation at a time ([#21](https://github.com/mauriciovieira/groundwork/pull/21))

## [2.3.2] - 2026-09-10

### Changed

- draw the flow and document the proof loop ([#20](https://github.com/mauriciovieira/groundwork/pull/20))

## [2.3.1] - 2026-09-10

### Changed

- verify groundwork with its own verification skill ([#19](https://github.com/mauriciovieira/groundwork/pull/19))
- record the verify config and keep evidence out of git ([#19](https://github.com/mauriciovieira/groundwork/pull/19))

## [2.3.0] - 2026-09-10

### Added

- add why, how and recall ([#18](https://github.com/mauriciovieira/groundwork/pull/18))

### Fixed

- catch Portuguese as it is actually written, and check every tracked file ([#18](https://github.com/mauriciovieira/groundwork/pull/18))
- close the gaps both review axes found ([#18](https://github.com/mauriciovieira/groundwork/pull/18))
- refuse to certify a feature nothing can demonstrate ([#18](https://github.com/mauriciovieira/groundwork/pull/18))

### Changed

- drop the Portuguese language gate ([#18](https://github.com/mauriciovieira/groundwork/pull/18))
- restore the credit assertions dropped with the language gate ([#18](https://github.com/mauriciovieira/groundwork/pull/18))

## [2.2.0] - 2026-09-10

### Added

- stop letting the author of a thing be its judge ([#17](https://github.com/mauriciovieira/groundwork/pull/17))

## [2.1.0] - 2026-09-10

### Added

- prove a feature works instead of asserting it ([#16](https://github.com/mauriciovieira/groundwork/pull/16))
- require proof before a slice or a feature counts as done ([#16](https://github.com/mauriciovieira/groundwork/pull/16))

### Fixed

- stop the language check from matching its own word list ([#16](https://github.com/mauriciovieira/groundwork/pull/16))

### Changed

- add structural tests and run them in CI ([#16](https://github.com/mauriciovieira/groundwork/pull/16))
- match the not-implemented die, not any die ([#16](https://github.com/mauriciovieira/groundwork/pull/16))

## [2.0.0] - 2026-09-10

### Added

- run on any agent that can load a skill ([#13](https://github.com/mauriciovieira/groundwork/pull/13))

### Fixed

- keep the Codex manifest version in step with the Claude ones ([#13](https://github.com/mauriciovieira/groundwork/pull/13))

### Changed

- drop runtime-specific references from skill prose ([#13](https://github.com/mauriciovieira/groundwork/pull/13))
- cover multi-runtime install and credit prior art ([#13](https://github.com/mauriciovieira/groundwork/pull/13))

## [1.0.0] - 2026-08-10

### Added

- auto-invoke advisory skills, chain orchestrators, lazy-bootstrap config ([#12](https://github.com/mauriciovieira/groundwork/pull/12))

### Fixed

- hand-offs into flagged skills read the SKILL.md directly ([#12](https://github.com/mauriciovieira/groundwork/pull/12))
- make lazy bootstrap detection explicitly non-interactive ([#12](https://github.com/mauriciovieira/groundwork/pull/12))

## [0.3.0] - 2026-07-16

### Added

- fold wayfinder's map/ticket planning into survey ([#11](https://github.com/mauriciovieira/groundwork/pull/11))

### Fixed

- apply Copilot round-1 feedback ([#11](https://github.com/mauriciovieira/groundwork/pull/11))
- apply Copilot round-2 feedback, move attribution to NOTICE ([#11](https://github.com/mauriciovieira/groundwork/pull/11))
- apply Copilot round-3 feedback ([#11](https://github.com/mauriciovieira/groundwork/pull/11))
- apply Copilot round-4 feedback ([#11](https://github.com/mauriciovieira/groundwork/pull/11))
- apply Copilot round-5 feedback ([#11](https://github.com/mauriciovieira/groundwork/pull/11))
- apply Copilot round-6 feedback ([#11](https://github.com/mauriciovieira/groundwork/pull/11))

### Changed

- credit mattpocock's wayfinder skill in the README ([#11](https://github.com/mauriciovieira/groundwork/pull/11))
- credit mattpocock/skills and igoruehara/spec-driven in LICENSE ([#11](https://github.com/mauriciovieira/groundwork/pull/11))

## [0.2.6] - 2026-07-11

### Changed

- remove the handoff skill and STATE.md ([#10](https://github.com/mauriciovieira/groundwork/pull/10))

## [0.2.5] - 2026-07-11

### Fixed

- scope changelog to the PR's own commits via the API ([#9](https://github.com/mauriciovieira/groundwork/pull/9))
- grant pull-requests:read, drop merge commits from PR history ([#9](https://github.com/mauriciovieira/groundwork/pull/9))

## [0.2.4] - 2026-07-11

### Added

- let a bump:minor/bump:major label override the release type ([#8](https://github.com/mauriciovieira/groundwork/pull/8))

## [0.2.3] - 2026-07-11

### Fixed

- dedupe squash-merge PR number, link PR refs in changelog ([#7](https://github.com/mauriciovieira/groundwork/pull/7))

## [0.2.2] - 2026-07-11

### Fixed

- stop dropping the last commit line in changelog generation ([#6](https://github.com/mauriciovieira/groundwork/pull/6))

## [0.2.1] - 2026-07-11

### Changed

- add automated patch release workflow and changelog ([#5](https://github.com/mauriciovieira/groundwork/pull/5))

## [0.2.0] - 2026-07-10

### Added

- add triage and improve-codebase-architecture skills ([#1](https://github.com/mauriciovieira/groundwork/pull/1))
- gate issue generation on a settled implementation stack ([#3](https://github.com/mauriciovieira/groundwork/pull/3))

### Changed

- rename grill to survey, grilling to interview-loop ([#2](https://github.com/mauriciovieira/groundwork/pull/2))
- bump plugin version to 0.2.0 ([#4](https://github.com/mauriciovieira/groundwork/pull/4))

## [0.1.0] - 2026-07-09

### Added

- scaffold groundwork spec-driven-development plugin
