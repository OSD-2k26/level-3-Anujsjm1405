#!/bin/bash
set -e

# Ensure all remote branches are available (CI-safe)
git fetch origin '+refs/heads/*:refs/remotes/origin/*' --quiet

# Get remote branch names only
BRANCHES=$(git for-each-ref --format='%(refname:short)' refs/remotes/origin)

# Find required branches
PATH_BRANCH=$(echo "$BRANCHES" | grep -i 'path' | head -n 1 || true)
TRUTH_BRANCH=$(echo "$BRANCHES" | grep -i 'truth' | head -n 1 || true)

if [ -z "$PATH_BRANCH" ]; then
  echo "❌ No branch containing 'path' found"
  exit 1
fi

if [ -z "$TRUTH_BRANCH" ]; then
  echo "❌ No branch containing 'truth' found"
  exit 1
fi

# Switch to main safely
git checkout main >/dev/null 2>&1

# Check files in main (case-insensitive)
FILES_IN_MAIN=$(ls | tr '[:upper:]' '[:lower:]')

echo "$FILES_IN_MAIN" | grep -qx "path.txt" || {
  echo "❌ path.txt not found in main"
  exit 1
}

echo "$FILES_IN_MAIN" | grep -qx "truth.txt" || {
  echo "❌ truth.txt not found in main"
  exit 1
}

# Ensure both branches were merged
MERGES=$(git log --oneline --merges | tr '[:upper:]' '[:lower:]')

echo "$MERGES" | grep -q "path" || {
  echo "❌ Path branch was not merged"
  exit 1
}

echo "$MERGES" | grep -q "truth" || {
  echo "❌ Truth branch was not merged"
  exit 1
}

echo "✅ Level 3 Passed"
