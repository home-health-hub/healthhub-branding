#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$project_dir"
if [[ ! -s SHA256SUMS ]]; then
  echo "SHA256SUMS is missing or empty." >&2
  exit 1
fi

sha256sum --check --strict SHA256SUMS
echo "All recorded asset checksums match."
