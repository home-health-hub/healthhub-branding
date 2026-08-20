#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
avatar="$project_dir/organization/avatar/approved/organization-avatar.png"
avatar_vector="$project_dir/organization/avatar/approved/organization-avatar.svg"
avatar_monochrome="$project_dir/organization/avatar/approved/monochrome.svg"
web_dir="$project_dir/organization/avatar/exports/web"
linux_dir="$project_dir/organization/avatar/exports/linux/hicolor"

command -v convert >/dev/null 2>&1 || {
  echo "ImageMagick 'convert' is required." >&2
  exit 1
}

mkdir -p "$web_dir"

write_hybrid_svg() {
  local input="$1"
  local output="$2"
  local width height encoded
  width="$(identify -format '%w' "$input")"
  height="$(identify -format '%h' "$input")"
  encoded="$(base64 -w 0 "$input")"
  mkdir -p "$(dirname "$output")"
  {
    printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>'
    printf '<svg xmlns="http://www.w3.org/2000/svg" width="%s" height="%s" viewBox="0 0 %s %s" role="img">\n' "$width" "$height" "$width" "$height"
    printf '  <image width="%s" height="%s" href="data:image/png;base64,%s"/>\n' "$width" "$height" "$encoded"
    printf '%s\n' '</svg>'
  } > "$output"
}

for size in 16 22 24 32 48 64 96 128 256 512; do
  target_dir="$linux_dir/${size}x${size}/apps"
  mkdir -p "$target_dir"
  convert "$avatar" -strip -filter Lanczos -resize "${size}x${size}" "$target_dir/org.homehealthhub.healthhub.png"
done

mkdir -p "$linux_dir/scalable/apps"
cp "$avatar_vector" "$linux_dir/scalable/apps/org.homehealthhub.healthhub.svg"

for size in 16 32 48; do
  convert "$avatar" -strip -filter Lanczos -resize "${size}x${size}" "$web_dir/favicon-${size}x${size}.png"
done

convert "$web_dir/favicon-16x16.png" "$web_dir/favicon-32x32.png" "$web_dir/favicon-48x48.png" -strip "$web_dir/favicon.ico"
convert "$avatar" -strip -filter Lanczos -resize 180x180 "$web_dir/apple-touch-icon-180x180.png"
convert "$avatar" -strip -filter Lanczos -resize 192x192 "$web_dir/pwa-192x192.png"
convert "$avatar" -strip -filter Lanczos -resize 512x512 "$web_dir/pwa-512x512.png"
convert "$avatar" -strip -filter Lanczos -resize 154x154 -gravity center -background '#C9F0EF' -extent 192x192 "$web_dir/maskable-192x192.png"
convert "$avatar" -strip -filter Lanczos -resize 410x410 -gravity center -background '#C9F0EF' -extent 512x512 "$web_dir/maskable-512x512.png"
cp "$avatar_vector" "$web_dir/favicon.svg"
cp "$avatar_monochrome" "$web_dir/monochrome.svg"

write_hybrid_svg "$project_dir/healthhub/approved/home-health-hub.png" "$project_dir/healthhub/source/home-health-hub.svg"
write_hybrid_svg "$project_dir/healthhub/approved/home-health-hub.png" "$project_dir/healthhub/exports/home-health-hub.svg"

for product_dir in "$project_dir"/daemons/*; do
  [[ -d "$product_dir" ]] || continue
  mkdir -p "$product_dir/source" "$product_dir/exports/svg" "$product_dir/exports/png"
  for role in banner application-icon navigation-icon; do
    input="$product_dir/approved/$role.png"
    [[ -f "$input" ]] || continue
    cp "$input" "$product_dir/source/${role}-master.png"
    write_hybrid_svg "$input" "$product_dir/source/$role.svg"
    write_hybrid_svg "$input" "$product_dir/exports/svg/$role.svg"
  done
  if [[ -f "$product_dir/approved/navigation-icon.png" ]]; then
    for size in 16 32 48 64 128 256 512; do
      convert "$product_dir/approved/navigation-icon.png" -strip -filter Lanczos -resize "${size}x${size}" "$product_dir/exports/png/navigation-icon-${size}x${size}.png"
    done
  fi
  if [[ -f "$product_dir/approved/application-icon.png" ]]; then
    for size in 64 128 256 512; do
      convert "$product_dir/approved/application-icon.png" -strip -filter Lanczos -resize "${size}x${size}" "$product_dir/exports/png/application-icon-${size}x${size}.png"
    done
  fi
done

echo "Asset exports rebuilt."
