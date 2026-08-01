#!/usr/bin/env bash
# Bumps the `version:` field in pubspec.yaml (major|minor|patch) and writes
# the result to $GITHUB_OUTPUT as `new_version`. `none` leaves pubspec.yaml
# untouched and just reports the current version (patch releases don't bump
# - the version is already advanced continuously by auto-version-bump.yml
# on every push to main).
set -euo pipefail

BUMP_TYPE="${1:-}"
case "$BUMP_TYPE" in
  major|minor|patch|none) ;;
  *)
    echo "Usage: $0 <major|minor|patch|none>" >&2
    exit 1
    ;;
esac

CURRENT=$(grep -m1 '^version:' pubspec.yaml | sed 's/^version: *//' | tr -d '[:space:]')
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$BUMP_TYPE" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  none) ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
if [ "$BUMP_TYPE" != "none" ]; then
  sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
fi

echo "Version: $CURRENT -> $NEW_VERSION ($BUMP_TYPE)"
echo "new_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
