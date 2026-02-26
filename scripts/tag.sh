#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-}"

if [[ -z "$TAG" ]]; then
  echo "Usage: npm run tag -- vMAJOR.MINOR or npm run tag -- v1.0-draft-N"
  echo "Examples: npm run tag -- v1.1"
  echo "          npm run tag -- v1.0-draft-1"
  exit 1
fi

if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+$ ]] && [[ ! "$TAG" =~ ^v1\.0-draft-[0-9]+$ ]]; then
  echo "Error: Tag must follow vMAJOR.MINOR (e.g. v1.0) or v1.0-draft-N format"
  exit 1
fi

BYLAWS_FILE="BYLAWS.md"

if [[ ! -f "$BYLAWS_FILE" ]]; then
  echo "Error: $BYLAWS_FILE not found"
  exit 1
fi

TODAY=$(date +%Y-%m-%d)

# Update the Last Amended date in BYLAWS.md
sed -i "s/^\*\*Last Amended:\*\* .*/\*\*Last Amended:\*\* $TODAY/" "$BYLAWS_FILE"

echo "Updated Last Amended date to $TODAY"

git add "$BYLAWS_FILE"
if git diff --cached --quiet; then
  echo "Last Amended date already set to $TODAY — tagging current commit"
else
  git commit -m "Update Last Amended date for $TAG"
fi
git tag "$TAG"

echo "Created tag $TAG with Last Amended date $TODAY"
