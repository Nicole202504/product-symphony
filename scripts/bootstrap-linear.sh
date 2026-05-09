#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ELIXIR_DIR="$ROOT_DIR/elixir"

if [ -f "$ROOT_DIR/.env.local" ]; then
  # shellcheck disable=SC1091
  . "$ROOT_DIR/.env.local"
fi

if [ ! -x "$ELIXIR_DIR/bin/symphony" ]; then
  echo "Missing elixir/bin/symphony. Run ./scripts/setup.sh first."
  exit 1
fi

cd "$ELIXIR_DIR"
mise exec -- ./bin/symphony product.bootstrap "$@"
