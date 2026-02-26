# Governance and Amendment Process

This document defines the authoritative workflow for proposing, approving,
versioning, and recording amendments to the bylaws of the Catholic Digital
Commons Foundation.

It exists to ensure continuity, transparency, and institutional integrity
across time, leadership changes, and legal contexts.

---

## Scope and authority

This document governs **process**, not substance.

- The bylaws (`BYLAWS.md`) define the legal and organizational norms
- This document defines how those norms are amended, recorded, and preserved
- In case of conflict, the bylaws prevail

---

## Canonical status of the repository

The `main` branch of this repository always reflects the **currently effective**
version of the bylaws.

Git history records how the text evolved; legal authority is determined by the
approval procedures defined in the bylaws themselves.

---

## Amendment workflow

### 1. Proposal

Each proposed amendment is introduced as a dedicated Git branch:

`amendment/YYYY-NN-short-title`

Example:

`amendment/2026-01-board-composition`

Only the following files may be modified in an amendment proposal:

- `BYLAWS.md`
- `CHANGELOG.md` (if present)

Each commit must clearly identify the amendment.

---

### 2. Pull Request

Every amendment requires a Pull Request with:

- A clear amendment title
- A concise description of the change
- The rationale for the amendment
- The approval authority required under the bylaws

The Pull Request serves as the permanent deliberation record.

---

### 3. Approval

Approval occurs outside Git according to the procedures defined in the bylaws
(e.g. Board resolution, members’ vote).

Upon approval:

- The Pull Request is merged into `main`
- The merge commit records:
  - Approval reference (resolution number or date)
  - Effective date, if not immediate

No rebasing, squashing, or history rewriting is permitted.

---

### 4. Effectivity

Once merged:

- The `main` branch reflects the legally effective bylaws
- Previous versions remain permanently accessible via Git history and tags

---

## Versioning of the bylaws

### Version format

The bylaws follow a legal semantic versioning scheme:

`MAJOR.MINOR`

There is no PATCH level.

---

### MAJOR version

The MAJOR version is incremented only when the bylaws are:

- Fully replaced
- Consolidated after extensive amendments
- Substantially re-founded due to legal or jurisdictional change

This represents a constitutional reset.

---

### MINOR version

The MINOR version is incremented for **every approved amendment**, regardless
of size or scope.

Each amendment corresponds to exactly one MINOR increment.

---

### Version declaration

The current version is declared at the top of `BYLAWS.md`, together with:

- Original adoption date
- Date of last amendment

Git tags (e.g. `v1.3`) may be used to mark each approved version.

---

### Pre-ratification draft tags

Before the bylaws are officially ratified as `v1.0`, draft tags following the
pattern `v1.0-draft-N` (e.g. `v1.0-draft-1`, `v1.0-draft-2`) may be used to
mark successive working drafts.

Once `v1.0` is tagged, draft tags are no longer permitted and only the strict
`vMAJOR.MINOR` format is valid.

---

## Changelog

Where maintained, `CHANGELOG.md` provides a human-readable summary of amendments.
It does not replace Git history and has no independent legal authority.

---

## Durability principle

All governance documents are maintained in plain-text formats to ensure
long-term accessibility, platform independence, and institutional durability.

This reflects the Foundation’s mission to steward shared digital goods with
clarity and responsibility.
