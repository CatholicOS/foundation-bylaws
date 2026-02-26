#!/usr/bin/env bash
set -euo pipefail

PR="${1:-}"
TAG="${2:-}"

if [[ -z "$PR" ]]; then
  echo "Usage: npm run merge -- <PR_NUMBER> [TAG]"
  echo "Examples: npm run merge -- 7 v1.1"
  echo "          npm run merge -- 7 v1.0-draft-1"
  echo "          npm run merge -- 7"
  exit 1
fi

if [[ ! "$PR" =~ ^[0-9]+$ ]]; then
  echo "Error: PR number must be a positive integer"
  exit 1
fi

# Validate tag format if provided
if [[ -n "$TAG" ]]; then
  if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+$ ]] && [[ ! "$TAG" =~ ^v1\.0-draft-[0-9]+$ ]]; then
    echo "Error: Tag must follow vMAJOR.MINOR (e.g. v1.0) or v1.0-draft-N format"
    exit 1
  fi
fi

# Ensure gh CLI is available
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is required but not installed"
  echo "Install it from https://cli.github.com/"
  exit 1
fi

# Fetch PR metadata
echo "Fetching PR #$PR metadata..."
PR_STATE=$(gh pr view "$PR" --json state --jq '.state')
if [[ "$PR_STATE" != "OPEN" ]]; then
  echo "Error: PR #$PR is not open (state: $PR_STATE)"
  exit 1
fi

PR_BRANCH=$(gh pr view "$PR" --json headRefName --jq '.headRefName')
echo "PR branch: $PR_BRANCH"

PR_MERGEABLE=$(gh pr view "$PR" --json mergeable --jq '.mergeable')
if [[ "$PR_MERGEABLE" == "CONFLICTING" ]]; then
  echo "Error: PR #$PR has merge conflicts"
  exit 1
fi

BYLAWS_FILE="BYLAWS.md"
TODAY=$(date +%Y-%m-%d)
LABEL="${TAG:-PR #$PR}"

# Save current branch to restore on failure
ORIGINAL_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)

# Checkout the PR branch and update the Last Amended date
echo "Checking out branch $PR_BRANCH..."
git fetch origin "$PR_BRANCH"
git checkout "$PR_BRANCH"
git pull origin "$PR_BRANCH"

LAST_AMENDED=$(grep -i "^\*\*Last Amended:\*\*" "$BYLAWS_FILE" | head -n1 | sed 's/.*\*\* //')
NEEDS_UPDATE=false

if [[ "$LAST_AMENDED" != "$TODAY" ]]; then
  echo "Updating Last Amended date from $LAST_AMENDED to $TODAY..."
  sed -i "s/^\(\*\*Last Amended:\*\*\).*/\1 $TODAY/" "$BYLAWS_FILE"
  NEEDS_UPDATE=true
fi

# Update Version to match the tag (strip leading "v")
if [[ -n "$TAG" ]]; then
  TAG_VERSION="${TAG#v}"
  CURRENT_VERSION=$(grep -i "^\*\*Version:\*\*" "$BYLAWS_FILE" | head -n1 | sed 's/.*\*\* //')
  if [[ "$CURRENT_VERSION" != "$TAG_VERSION" ]]; then
    echo "Updating Version from $CURRENT_VERSION to $TAG_VERSION..."
    sed -i "s/^\(\*\*Version:\*\*\).*/\1 $TAG_VERSION/" "$BYLAWS_FILE"
    NEEDS_UPDATE=true
  fi
fi

if [[ "$NEEDS_UPDATE" == true ]]; then
  git add "$BYLAWS_FILE"
  git commit -m "Update Last Amended date for $LABEL"
  git push origin "$PR_BRANCH"
  echo "Pushed updates to $PR_BRANCH"
else
  echo "Last Amended date and Version already up to date, skipping commit"
fi

# Wait for CI checks to pass
echo "Waiting for CI checks to pass..."
if ! gh pr checks "$PR" --watch; then
  echo "Error: CI checks failed for PR #$PR"
  git checkout "$ORIGINAL_BRANCH"
  exit 1
fi

# Merge the PR (merge commit, no squash/rebase per governance rules)
echo "Merging PR #$PR..."
gh pr merge "$PR" --merge

# Update local main
echo "Switching to main and pulling..."
git checkout main
git pull origin main

# Clean up the amendment branch
echo "Cleaning up branch $PR_BRANCH..."
git branch -d "$PR_BRANCH" 2>/dev/null || true
git push origin --delete "$PR_BRANCH" 2>/dev/null || true

echo "PR #$PR merged successfully"

# If a tag was provided, validate and create it
if [[ -n "$TAG" ]]; then
  echo ""
  echo "Creating tag $TAG..."

  LAST_AMENDED=$(grep -i "^\*\*Last Amended:\*\*" "$BYLAWS_FILE" | head -n1 | sed 's/.*\*\* //')
  COMMIT_DATE=$(git log -1 --format=%cd --date=short HEAD)

  if [[ "$LAST_AMENDED" != "$COMMIT_DATE" ]]; then
    echo "Error: Last Amended date ($LAST_AMENDED) does not match HEAD commit date ($COMMIT_DATE)"
    exit 1
  fi

  echo "Last Amended date ($LAST_AMENDED) matches HEAD commit date"
  git tag -a "$TAG" -m "$TAG"
  git push origin "$TAG"
  echo "Created and pushed tag $TAG on $(git rev-parse --short HEAD)"
fi

echo ""
echo "Done!"
