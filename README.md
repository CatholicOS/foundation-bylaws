# Catholic Digital Commons Foundation — Bylaws

This repository contains the **official bylaws of the Catholic Digital Commons Foundation**, maintained as a version-controlled public record.

The authoritative text of the bylaws is located in [`BYLAWS.md`](./BYLAWS.md).

---

## Why the bylaws live in Git

The Catholic Digital Commons Foundation exists to steward shared digital goods with clarity, accountability, and continuity.  
Maintaining the bylaws in a Git repository directly serves that mission.

Version control provides:

### 1. Transparency

All changes to the bylaws are publicly visible, attributable, and reviewable.  
There are no silent edits and no ambiguity about when or how governance rules evolve.

### 2. Historical integrity

Git preserves the complete amendment history of the bylaws, allowing the Foundation and external stakeholders to trace decisions over time with precision.

### 3. Accountability

Each modification is associated with a concrete proposal, discussion, and approval record, reinforcing responsible governance.

### 4. Durability

Plain-text Markdown ensures the bylaws remain readable and usable decades into the future, independent of proprietary formats or platforms.

### 5. Alignment with the Foundation’s mission

As a foundation committed to open, shared digital infrastructure for the Church, it is fitting that its own constitutional documents are maintained using open, inspectable tools.

---

## Authority of the text

The content of [`BYLAWS.md`](./BYLAWS.md) constitutes the **official bylaws** of the Catholic Digital Commons Foundation,
subject to adoption and amendment according to the procedures defined therein.

The Git history records _how_ the text has evolved; the bylaws themselves define _when_ changes take legal and organizational effect.

---

## Amendments and governance

Proposed amendments to the bylaws are introduced through documented changes to `BYLAWS.md`,
reviewed according to the Foundation's governance procedures, and merged only after proper approval.

The full amendment workflow — including branch naming, versioning, and approval procedures — is defined in [`GOVERNANCE.md`](./GOVERNANCE.md).

Where applicable, significant changes may be summarized in a `CHANGELOG.md` for ease of reference.

---

## Local development

After cloning the repository, install the Node dev-dependencies:

```sh
npm install
```

To build an HTML version of the bylaws locally:

```sh
npm run build:html
```

This requires [Pandoc](https://pandoc.org/) as a **system dependency** (not installed via npm).
Install it first — for example `sudo apt install pandoc` on Debian/Ubuntu,
`brew install pandoc` on macOS, or see the [Pandoc installation docs](https://pandoc.org/installing.html).

---

## License and reuse

This repository contains governance documents of the Catholic Digital Commons Foundation.  
Reuse or adaptation for other organizations should respect applicable legal and canonical requirements.
