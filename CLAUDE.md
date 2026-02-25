# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **governance-only repository** containing the official bylaws of the Catholic Digital Commons Foundation.
There is no application code, no build system, and no tests.
The repository holds Markdown legal documents maintained under strict version-control procedures.

## Key Files

- `BYLAWS.md` — The authoritative bylaws text. Contains a `Version:` header (MAJOR.MINOR format), original adoption date, and last-amended date.
- `GOVERNANCE.md` — Defines the amendment workflow, versioning scheme, and process rules.
- `.github/workflows/enforce-names.yml` — CI workflow enforcing branch naming and tag-version alignment.
- `.github/PULL_REQUEST_TEMPLATE.md` — Required template for amendment PRs.

## Amendment Workflow (from GOVERNANCE.md)

1. **Branch naming:** Amendments must use branches named `amendment/YYYY-NN-short-title`
   (e.g. `amendment/2026-01-board-composition`). The CI workflow enforces this when `BYLAWS.md` is modified.
2. **Allowed file changes:** Only `BYLAWS.md` and `CHANGELOG.md` may be modified in amendment branches.
3. **PRs:** Every amendment requires a PR against `main` using the PR template. The PR is the permanent deliberation record.
4. **No history rewriting:** Rebasing, squashing, and force-pushing are prohibited on amendment branches.
5. **Versioning:** Each approved amendment increments the MINOR version in `BYLAWS.md`.
   MAJOR increments are reserved for full replacements or constitutional resets. There is no PATCH level.
6. **Tags:** Must follow `vMAJOR.MINOR` format (e.g. `v1.0`). CI verifies that tag names match the `Version:` field in `BYLAWS.md`.
7. **`main` branch** always reflects the currently effective bylaws.

## Linting and Formatting

Run after `npm install`:

- `npm run lint:md` — lint all Markdown files with markdownlint-cli2
- `npm run lint:md:fix` — auto-fix lint issues
- `npm run format:md` — format all Markdown files with Prettier

A husky pre-commit hook runs `lint-staged`, which applies Prettier and then markdownlint-cli2 to staged `.md` files.

Configuration: `.markdownlint.yml` (max line length 180, code blocks and tables exempt).

## CI Enforcement

The `enforce-names.yml` workflow runs on all pushes and PRs to `main`. It checks:

- Branch names match `amendment/YYYY-NN-short-title` pattern when `BYLAWS.md` is modified
- Tags match `vMAJOR.MINOR` format
- Tag names align with the version declared in `BYLAWS.md`

## Important Constraints

- All documents are plain-text Markdown for long-term durability and platform independence.
- Amendments must be atomic: one amendment per PR.
- The `main` branch has legal authority; `GOVERNANCE.md` governs process but the bylaws prevail in case of conflict.
