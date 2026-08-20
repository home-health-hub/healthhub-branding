# Organization avatar vector review

## Status

The native-vector avatar and monochrome mark were approved for the export pipeline. Their original candidate files and review images remain here as provenance.

## Native-vector candidate

`organization-avatar-native.svg` redraws the organization avatar with editable paths and gradients. It preserves the approved house-and-heart concept, palette, square canvas, and warm-white background without embedding raster data.

Review it for:

- overall roof, chimney, wall, and heart proportions;
- visual weight at 16, 32, and 48 pixels;
- agreement with the approved teal and coral palette;
- whether the warm-white background should remain part of the avatar;
- whether the redraw is close enough to replace the hybrid SVG.

Run `./scripts/compare-avatar-candidate.sh` to generate side-by-side and difference images under `docs/review/`.

## Monochrome candidate

`monochrome.svg` is a true single-color vector. The heart is represented as negative space so the mark remains recognizable when a platform supplies its own foreground color. It contains no gradients, raster images, or background rectangle.

Approval of the native-vector candidate does not automatically approve the monochrome candidate; review both independently.
