#!/usr/bin/env bash
set -euo pipefail

RESULTS_DIR="test-results"

rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

if [ ! -f "package.json" ]; then
  echo "ERROR: package.json not found in $(pwd)" >&2
  exit 1
fi

if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm ci
fi

PROJECT_NAME=$(node -p "JSON.parse(require('fs').readFileSync('package.json','utf8')).name")
echo "Running tests for: $PROJECT_NAME"

if grep -q '"jest"' package.json; then
  JEST_ARGS="--ci --reporters=default --reporters=jest-junit"
  export JEST_JUNIT_OUTPUT_DIR="$RESULTS_DIR"
  export JEST_JUNIT_OUTPUT_NAME="junit.xml"
  npx jest $JEST_ARGS
elif grep -q '"vitest"' package.json; then
  npx vitest run --reporter=default --reporter=junit --outputFile="$RESULTS_DIR/junit.xml"
else
  echo "Running npm test (no specific runner detected)"
  npm test
fi

echo "Tests passed. Results available in $RESULTS_DIR/"
