#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if ! command -v node >/dev/null 2>&1; then
  echo "node is required to report Product Symphony issues automatically."
  exit 1
fi

node "$ROOT_DIR/scripts/report-product-symphony-issue.mjs" "$@"

