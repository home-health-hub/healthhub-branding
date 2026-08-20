# Home Health Hub branding

<p align="center">
  <img src="organization/avatar/approved/organization-avatar.png" alt="Home Health Hub organization avatar" width="240">
</p>

![Documentation](https://img.shields.io/badge/project-documentation-168E98) ![Brand assets](https://img.shields.io/badge/assets-branding-FF7A61)

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue)](https://github.com/home-health-hub/healthhub-branding/blob/main/LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/home-health-hub/healthhub-branding#changes) [![Discussions](https://img.shields.io/badge/discussions-welcome-blue)](https://github.com/home-health-hub/healthhub-branding/discussions)

This repository is the source of truth for Home Health Hub brand documentation and approved visual assets. It contains the organization avatar, Health Hub artwork, daemon artwork, launcher and web exports, editable or hybrid SVGs, and historically meaningful superseded assets.

Start with [BRANDING.md](BRANDING.md). The current asset list and provenance are recorded in [docs/ASSET_INVENTORY.md](docs/ASSET_INVENTORY.md). Shared typography, operational-status, and PDF rules are in [docs/INTERFACE_AND_REPORT_STANDARDS.md](docs/INTERFACE_AND_REPORT_STANDARDS.md). Product integration boundaries and verification are in [docs/ADOPTION.md](docs/ADOPTION.md).

The dependency-free [interface specimen](specimens/interface.html) demonstrates the generated tokens, approved daemon identification images, responsive Hub tiles, statuses, accessible chart treatment, and common interface states. Open it locally in a browser; it contains no production Hub or daemon behavior.

## Repository layout

```text
organization/avatar/  Organization identity and the Health Hub launcher icon
healthhub/             Main Hub artwork for documentation and large UI placements
daemons/               Device-specific banners, application images, and navigation icons
templates/             Templates for adding another device
scripts/               Reproducible asset-export tooling
archive/               Previously approved or deployed assets retained when superseded
```

Within an identity or product directory:

- `source/` contains the highest-resolution input or editable master.
- `approved/` contains the currently approved artwork.
- `exports/` contains derived formats and sizes; these may be regenerated.
- `archive/` contains previously approved or deployed material that has been superseded.

## Application identity

There is one installed application launcher: **Health Hub**. It uses the organization avatar and opens the main Hub login page. Daemon images identify functions inside the Hub; they are not operating-system launcher icons.

## Rebuilding exports

The export script requires ImageMagick:

```bash
./scripts/build-exports.sh
```

The script creates Linux `hicolor` icons, browser and PWA icons, an ICO file, PNG presentation exports, and hybrid SVG representations for current raster-only artwork. Run `./scripts/build-design-tokens.py` to regenerate `tokens/brand.css` from its JSON source. Run `./scripts/verify-assets.sh` afterward.

Run `./scripts/update-checksums.sh` whenever approved assets or generated exports change. Use `./scripts/verify-checksums.sh` and `./scripts/verify-reproducible-build.sh` before review. Raster artwork uses hybrid SVGs when a native redraw would alter the approved design.

The release procedure is documented in [docs/RELEASING.md](docs/RELEASING.md).

## Changes

Do not replace an approved image silently. Add the proposed asset beside the current one, record its provenance, preview it at its intended sizes, and move the old asset to `archive/` only after approval.

## License

This project is licensed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE).
