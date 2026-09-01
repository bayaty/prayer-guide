#!/usr/bin/env bash
# Install the repo's git hooks into .git/hooks.
#
# Hooks live in scripts/hooks so they are version controlled; .git/hooks is
# not. Run this once per clone.
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p .git/hooks

for hook in scripts/hooks/*; do
  name="$(basename "$hook")"
  target=".git/hooks/$name"
  cp "$hook" "$target"
  chmod +x "$target"
  echo "installed $name"
done

echo
echo "Pushing to main now rebuilds and deploys the web app."
echo "Skip once with: SKIP_WEB_DEPLOY=1 git push"
