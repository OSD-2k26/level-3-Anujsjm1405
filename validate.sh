#!/bin/bash
set -e

# Get all branch names
BRANCHES=$(git branch --format='%(refname:short)')

# Find path and truth branches (case-insensitive)
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

# Switch to main
git checkout main >/dev/null 2>&1

# Case-insensitive file check in main
FILES_IN_MAIN=$(ls | tr '[:upper:]' '[:lower:]')

echo "$FILES_IN_MAIN" | grep -q "^path.txt$" || {
  echo "❌ path.txt not found in main"
  exit 1
}

echo "$FILES_IN_MAIN" | grep -q "^truth.txt$" || {
  echo "❌ truth.txt not found in main"
  exit 1
}

# Count merge commits
MERGE_COUNT=$(git log --oneline --merges | wc -l)

if [ "$MERGE_COUNT" -lt 2 ]; then
  echo "❌ Expected at least two merge commits"
  exit 1
fi

# Case-insensitive merge validation
MERGES=$(git log --oneline --merges | tr '[:upper:]' '[:lower:]')

echo "$MERGES" | grep -q "merge.*path" || {
  echo "❌ Branch containing 'path' was not merged"
  exit 1
}

echo "$MERGES" | grep -q "merge.*truth" || {
  echo "❌ Branch containing 'truth' was not merged"
  exit 1
}

echo "✅ Level 3 Passed"
