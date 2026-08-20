#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
before="$(mktemp)"
after="$(mktemp)"
trap 'rm -f "$before" "$after"' EXIT

cd "$project_dir"
find organization healthhub daemons \
  -type f \
  ! -path '*/archive/*' \
  -print0 \
  | sort -z \
  | xargs -0 sha256sum > "$before"

./scripts/build-exports.sh

find organization healthhub daemons \
  -type f \
  ! -path '*/archive/*' \
  -print0 \
  | sort -z \
  | xargs -0 sha256sum > "$after"

if ! cmp -s "$before" "$after"; then
  echo "The export build changed committed asset bytes." >&2
  diff -u "$before" "$after" || true
  exit 1
fi

echo "The export build is reproducible."
