#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-}"

if [[ -z "$TAG" ]]; then
  echo "Usage: npm run tag -- vMAJOR.MINOR"
  echo "Example: npm run tag -- v1.1"
  exit 1
fi

if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Tag must follow vMAJOR.MINOR format (e.g. v1.0)"
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
git commit -m "Update Last Amended date for $TAG"
git tag "$TAG"

echo "Created tag $TAG with Last Amended date $TODAY"
