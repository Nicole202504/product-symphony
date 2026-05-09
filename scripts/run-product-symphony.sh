#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ELIXIR_DIR="$ROOT_DIR/elixir"
WORKFLOW_PATH="${1:-$ELIXIR_DIR/WORKFLOW.product.md}"

if [ ! -x "$ELIXIR_DIR/bin/symphony" ]; then
  echo "Missing elixir/bin/symphony. Run ./scripts/setup.sh first."
  exit 1
fi

if [ "${LINEAR_API_KEY:-}" = "" ]; then
  echo "LINEAR_API_KEY is required."
  exit 1
fi

if [ "${PRODUCT_SYMPHONY_TARGET_REPO:-}" = "" ]; then
  echo "PRODUCT_SYMPHONY_TARGET_REPO is required."
  echo "Example: export PRODUCT_SYMPHONY_TARGET_REPO=git@github.com:org/repo.git"
  exit 1
fi

cd "$ELIXIR_DIR"

mise exec -- ./bin/symphony \
  --i-understand-that-this-will-be-running-without-the-usual-guardrails \
  "$WORKFLOW_PATH"

