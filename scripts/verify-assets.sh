#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

require_file() {
  if [[ ! -s "$1" ]]; then
    echo "Missing or empty: ${1#"$project_dir"/}" >&2
    failures=$((failures + 1))
  fi
}

require_square_png() {
  local file="$1"
  local expected="$2"
  require_file "$file"
  [[ -s "$file" ]] || return
  dimensions="$(identify -format '%wx%h' "$file")"
  if [[ "$dimensions" != "${expected}x${expected}" ]]; then
    echo "Wrong dimensions: ${file#"$project_dir"/} is $dimensions, expected ${expected}x${expected}" >&2
    failures=$((failures + 1))
  fi
}

for size in 16 22 24 32 48 64 96 128 256 512; do
  require_square_png "$project_dir/organization/avatar/exports/linux/hicolor/${size}x${size}/apps/org.homehealthhub.healthhub.png" "$size"
done

for file in \
  "$project_dir/organization/avatar/exports/linux/hicolor/scalable/apps/org.homehealthhub.healthhub.svg" \
  "$project_dir/organization/avatar/exports/web/favicon.ico" \
  "$project_dir/organization/avatar/exports/web/favicon.svg" \
  "$project_dir/organization/avatar/exports/web/monochrome.svg" \
  "$project_dir/organization/avatar/exports/web/apple-touch-icon-180x180.png" \
  "$project_dir/organization/avatar/exports/web/pwa-192x192.png" \
  "$project_dir/organization/avatar/exports/web/pwa-512x512.png" \
  "$project_dir/organization/avatar/exports/web/maskable-192x192.png" \
  "$project_dir/organization/avatar/exports/web/maskable-512x512.png"; do
  require_file "$file"
done

for file in \
  "$project_dir/organization/avatar/approved/organization-avatar.svg" \
  "$project_dir/organization/avatar/approved/monochrome.svg"; do
  require_file "$file"
done

for product_dir in "$project_dir"/daemons/*; do
  [[ -d "$product_dir" ]] || continue
  for role in banner application-icon navigation-icon; do
    require_file "$product_dir/approved/$role.png"
    require_file "$product_dir/exports/svg/$role.svg"
  done
done

require_file "$project_dir/tokens/brand.tokens.json"
require_file "$project_dir/tokens/brand.css"
require_file "$project_dir/specimens/interface.html"
require_file "$project_dir/specimens/specimen.css"
require_file "$project_dir/specimens/specimen.js"
python3 "$project_dir/scripts/verify-design-tokens.py"

if (( failures > 0 )); then
  echo "$failures asset verification failure(s)." >&2
  exit 1
fi

echo "All declared assets are present and launcher sizes are correct."
