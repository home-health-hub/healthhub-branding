# Home Health Hub branding

<p align="center">
  <img src="organization/avatar/approved/organization-avatar.png" alt="Home Health Hub organization avatar" width="240">
</p>

![Documentation](https://img.shields.io/badge/project-documentation-168E98) ![Brand assets](https://img.shields.io/badge/assets-branding-FF7A61)

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue)](https://github.com/home-health-hub/healthhub-branding/blob/main/LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/home-health-hub/healthhub-branding#changes) [![Discussions](https://img.shields.io/badge/discussions-welcome-blue)](https://github.com/home-health-hub/healthhub-branding/discussions)

This repository is the source of truth for Home Health Hub brand documentation and approved visual assets. It contains the organization avatar, Health Hub artwork, daemon artwork, launcher and web exports, editable or hybrid SVGs, and archived superseded or unselected variants.

Start with [BRANDING.md](BRANDING.md). The current asset list and provenance are recorded in [docs/ASSET_INVENTORY.md](docs/ASSET_INVENTORY.md).

## Repository layout

```text
organization/avatar/  Organization identity and the Health Hub launcher icon
healthhub/             Main Hub artwork for documentation and large UI placements
daemons/               Device-specific banners, application images, and navigation icons
templates/             Templates for adding another device
scripts/               Reproducible asset-export tooling
archive/               Unselected or superseded material retained for provenance
```

Within an identity or product directory:

- `source/` contains the highest-resolution input or editable master.
- `approved/` contains the currently approved artwork.
- `exports/` contains derived formats and sizes; these may be regenerated.
- `archive/` contains material that is not approved for current use.

## Application identity

There is one installed application launcher: **Health Hub**. It uses the organization avatar and opens the main Hub login page. Daemon images identify functions inside the Hub; they are not operating-system launcher icons.

## Rebuilding exports

The export script requires ImageMagick:

```bash
./scripts/build-exports.sh
```

The script creates Linux `hicolor` icons, browser and PWA icons, an ICO file, PNG presentation exports, and hybrid SVG representations for current raster-only artwork. Run `./scripts/verify-assets.sh` afterward.

## Changes

Do not replace an approved image silently. Add the proposed asset beside the current one, record its provenance, preview it at its intended sizes, and move the old asset to `archive/` only after approval.

## License

This project is licensed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE).
