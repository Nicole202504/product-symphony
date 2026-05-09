#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ELIXIR_DIR="$ROOT_DIR/elixir"

if ! command -v mise >/dev/null 2>&1; then
  echo "mise is required to install the pinned Erlang/Elixir toolchain."
  echo "Install mise first, then rerun: ./scripts/setup.sh"
  exit 1
fi

cd "$ELIXIR_DIR"

mise trust
mise install
mise exec -- mix setup
mise exec -- mix build

echo "Product Symphony setup complete."
echo "Next:"
echo "  export LINEAR_API_KEY=..."
echo "  export PRODUCT_SYMPHONY_TARGET_REPO=git@github.com:org/repo.git"
echo "  edit elixir/WORKFLOW.product.md tracker.project_slug"
echo "  ./scripts/run-product-symphony.sh"

