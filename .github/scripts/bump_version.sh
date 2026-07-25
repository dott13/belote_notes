#!/usr/bin/env bash
# Bumps the `version:` field in pubspec.yaml (major|minor|patch) and writes
# the result to $GITHUB_OUTPUT as `new_version`.
set -euo pipefail

BUMP_TYPE="${1:-}"
case "$BUMP_TYPE" in
  major|minor|patch) ;;
  *)
    echo "Usage: $0 <major|minor|patch>" >&2
    exit 1
    ;;
esac

CURRENT=$(grep -m1 '^version:' pubspec.yaml | sed 's/^version: *//' | tr -d '[:space:]')
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$BUMP_TYPE" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

echo "Bumped version: $CURRENT -> $NEW_VERSION ($BUMP_TYPE)"
echo "new_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
