#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
reference="$project_dir/organization/avatar/approved/organization-avatar.png"
candidate="$project_dir/organization/avatar/candidates/organization-avatar-native.svg"
review_dir="$project_dir/docs/review"

command -v convert >/dev/null 2>&1 || {
  echo "ImageMagick 'convert' is required." >&2
  exit 1
}
command -v inkscape >/dev/null 2>&1 || {
  echo "Inkscape is required." >&2
  exit 1
}

mkdir -p "$review_dir"
inkscape "$candidate" --export-type=png --export-width=1254 --export-height=1254 --export-filename="$review_dir/organization-avatar-native.png"
convert "$reference" "$review_dir/organization-avatar-native.png" +append "$review_dir/organization-avatar-side-by-side.png"
convert "$reference" "$review_dir/organization-avatar-native.png" -compose difference -composite "$review_dir/organization-avatar-difference.png"

echo "Avatar review images rebuilt in docs/review/."
