#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$project_dir/SHA256SUMS"
temporary="$(mktemp)"
trap 'rm -f "$temporary"' EXIT

cd "$project_dir"
find organization healthhub daemons tokens \
  -type f \
  ! -path '*/archive/*' \
  -print0 \
  | sort -z \
  | xargs -0 sha256sum > "$temporary"
mv "$temporary" "$output"
trap - EXIT

echo "Updated SHA256SUMS."
