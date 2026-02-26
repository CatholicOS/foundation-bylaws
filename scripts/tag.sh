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

# Validate that the Last Amended date matches HEAD's commit date
LAST_AMENDED=$(grep -i "^\*\*Last Amended:\*\*" "$BYLAWS_FILE" | head -n1 | sed 's/.*\*\* //')
COMMIT_DATE=$(git log -1 --format=%cd --date=short HEAD)

if [[ -z "$LAST_AMENDED" ]]; then
  echo "Error: No Last Amended date found in $BYLAWS_FILE"
  exit 1
fi

if [[ "$LAST_AMENDED" != "$COMMIT_DATE" ]]; then
  echo "Error: Last Amended date ($LAST_AMENDED) does not match HEAD commit date ($COMMIT_DATE)"
  echo ""
  echo "Update the Last Amended date in $BYLAWS_FILE to $COMMIT_DATE via a PR, then re-run this command."
  exit 1
fi

echo "✅ Last Amended date ($LAST_AMENDED) matches HEAD commit date"

git tag -a "$TAG" -m "$TAG"

echo "Created tag $TAG on $(git rev-parse --short HEAD)"
