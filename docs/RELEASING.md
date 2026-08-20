# Releasing branding assets

Branding releases identify an approved, reproducible set of source artwork and exports.

## Versioning

The repository version is stored in `VERSION`. Use semantic versioning:

- Patch: corrected metadata or exports with no intended visual change.
- Minor: a new approved asset, size, format, or device family.
- Major: an intentional breaking change to established identity or asset paths.

A `-dev` suffix marks unreleased work. Remove it only when the asset set has passed review and is ready to tag.

## Release checklist

1. Confirm every changed image is in the correct `source/`, `approved/`, `exports/`, or `archive/` directory.
2. Confirm no candidate or archived image is referenced as an approved asset.
3. Run `./scripts/build-exports.sh`.
4. Run `./scripts/update-checksums.sh`.
5. Run `./scripts/verify-assets.sh`.
6. Run `./scripts/verify-checksums.sh`.
7. Run `./scripts/verify-reproducible-build.sh`.
8. Review image changes at their intended display sizes.
9. Update `VERSION` and remove the `-dev` suffix.
10. Merge through the protected `main` branch before creating the matching tag and GitHub release.

The release tag should be `v` followed by the exact contents of `VERSION`, for example `v0.2.0`.
