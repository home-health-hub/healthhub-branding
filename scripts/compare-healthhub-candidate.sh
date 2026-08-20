#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
reference="$project_dir/healthhub/approved/home-health-hub.png"
candidate="$project_dir/healthhub/archive/rejected-home-health-hub-native.svg"
review_dir="$project_dir/healthhub/archive/review"

command -v convert >/dev/null 2>&1 || {
  echo "ImageMagick 'convert' is required." >&2
  exit 1
}
command -v inkscape >/dev/null 2>&1 || {
  echo "Inkscape is required." >&2
  exit 1
}

mkdir -p "$review_dir"
inkscape "$candidate" --export-type=png --export-width=1254 --export-height=1254 --export-filename="$review_dir/home-health-hub-native.png"
convert "$reference" "$review_dir/home-health-hub-native.png" +append "$review_dir/home-health-hub-side-by-side.png"
convert "$reference" "$review_dir/home-health-hub-native.png" -compose difference -composite "$review_dir/home-health-hub-difference.png"

echo "Rejected Health Hub candidate review images rebuilt in healthhub/archive/review/."
