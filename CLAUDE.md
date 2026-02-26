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

## Building HTML

- `npm run build:html` — convert `BYLAWS.md` to `dist/bylaws.html` using Pandoc

This script requires [Pandoc](https://pandoc.org/) as a **system dependency** (it is not installed via npm).
Install it before running the script — for example `sudo apt install pandoc` on Debian/Ubuntu,
`brew install pandoc` on macOS, or see the [Pandoc installation docs](https://pandoc.org/installing.html).

## Tagging Releases

- `npm run tag -- vMAJOR.MINOR` — validate that the `Last Amended` date in `BYLAWS.md` matches HEAD's commit date, then create an annotated git tag.
- `npm run tag -- v1.0-draft-N` — same as above, but for pre-ratification draft tags (only valid before `v1.0` is officially tagged).

The script does **not** modify files or create commits.
The `Last Amended` date must be updated as part of the amendment PR (or a dedicated PR) before tagging.
This ensures compatibility with branch protection rules on `main`.

## Merging Amendment PRs

- `npm run merge -- <PR_NUMBER> [TAG]` — automates the full merge-and-tag workflow for amendment PRs.

The script performs the following steps:

1. Validates inputs (PR number required; tag optional but must follow `vMAJOR.MINOR` or `v1.0-draft-N` format)
2. Fetches PR metadata via `gh pr view` — checks the PR is open and mergeable
3. Checks out the PR branch and updates `BYLAWS.md`: sets `Last Amended` to today and, if a tag is provided, sets `Version` to match the tag (skips if already current)
4. Waits for CI checks to pass (`gh pr checks --watch`)
5. Merges the PR with a merge commit (`--merge`, no squash/rebase per governance rules)
6. Updates local `main` and deletes the amendment branch (local and remote)
7. If a tag was provided: validates the `Last Amended` date matches the merge commit date, creates an annotated tag, and pushes it

Requires the [GitHub CLI (`gh`)](https://cli.github.com/) to be installed and authenticated.

## Pre-commit Hook

A husky pre-commit hook runs `lint-staged`, which applies Prettier and then markdownlint-cli2 to staged `.md` files.

Configuration: `.markdownlint.yml` (max line length 180, code blocks and tables exempt).

## CI Enforcement

The `enforce-names.yml` workflow runs on all pushes and PRs to `main`. It checks:

- Branch names match `amendment/YYYY-NN-short-title` pattern when `BYLAWS.md` is modified
- Tags match `vMAJOR.MINOR` format (or `v1.0-draft-N` before ratification)
- Tag names align with the version declared in `BYLAWS.md`
- `Last Amended` date in `BYLAWS.md` matches the tagged commit's date

## Important Constraints

- All documents are plain-text Markdown for long-term durability and platform independence.
- Amendments must be atomic: one amendment per PR.
- The `main` branch has legal authority; `GOVERNANCE.md` governs process but the bylaws prevail in case of conflict.
