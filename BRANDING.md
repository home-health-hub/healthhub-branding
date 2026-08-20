# Home Health Hub branding

This guide keeps artwork across Home Health Hub repositories recognizable as one family while leaving room for each device to show its purpose.

## Core visual language

- Use rounded, approachable forms with gentle depth rather than hard-edged technical diagrams.
- Keep the background light: white fading into pale aqua.
- Use teal and aqua for devices, home-computing elements, storage, and connectivity.
- Reserve complementary colors for the measurement or function being highlighted.
- Show data staying in the home. Do not use cloud imagery.
- Prefer one clear left-to-right flow: device, connection, home computer, local storage.
- Avoid manufacturer logos, mascots, people, medical claims, arbitrary readings, and decorative interface text.

The Hub artwork in [`healthhub/approved/home-health-hub.png`](healthhub/approved/home-health-hub.png) is the primary large-format visual reference. The organization avatar in [`organization/avatar/approved/organization-avatar.png`](organization/avatar/approved/organization-avatar.png) is the application identity.

## Palette

The artwork uses gradients, so these values are anchors rather than strict single-color fills.

| Role | Color | Hex |
|---|---|---|
| Deep teal | Titles, outlines, device shadows | `#00616E` |
| Hub teal | Devices and structural elements | `#168E98` |
| Aqua | Bluetooth icon and connectivity | `#31BEC1` |
| Pale aqua | Background fields and secondary shapes | `#C9F0EF` |
| Coral | Heart, pulse, and selected measurement accents | `#FF7A61` |
| Warm gold | Glucose transport accent | `#F5A623` |
| Oxygen blue | SpO2-specific live-data accent | `#28B9E8` |
| Cycle plum | Basal body temperature and cycle-tracking accents | `#8E5AA7` |

The Bluetooth icon uses the same teal-to-turquoise treatment in every repository. Device-specific colors belong on the measurement path or related detail, not on the Bluetooth mark.

## Interface and report presentation

Typography, operational status colors, Hub presentation of daemon-backed functions, and daemon-generated PDF presentation are defined in [`docs/INTERFACE_AND_REPORT_STANDARDS.md`](docs/INTERFACE_AND_REPORT_STANDARDS.md). Health Hub owns browser presentation; daemons retain synchronization, data, API, and report authority.

## README banners

README banners use a 3:1 landscape canvas. Keep the repository name exact, prominent, and limited to one appearance. At normal GitHub README width, the device and connection method should remain identifiable without relying on small labels.

Current daemon banners:

| Repository | Functional focus | Complementary accent | Image path |
|---|---|---|---|
| `etekcity-scale-daemon` | BLE scale measurements | Coral-orange | `docs/images/etekcity-scale-daemon-banner.png` |
| `etekcity-bp-daemon` | BLE blood-pressure measurements | Coral | `docs/images/etekcity-bp-daemon-banner.png` |
| `trividia-truemetrix-daemon` | Bluetooth and USB glucose import | Warm gold | `docs/images/trividia-truemetrix-daemon-banner.png` |
| `viatom-o2ring-daemon` | BLE live readings and overnight sessions | Oxygen blue with a small coral pulse accent | `docs/images/viatom-o2ring-daemon-banner.png` |
| `health-thermometer-daemon` | Bluetooth health-temperature readings | Coral infrared and temperature accent | `docs/images/health-thermometer-daemon-banner.png` |

Place a banner directly below the README's level-one project title:

```markdown
# repository-name

![Concise description of the device-to-local-storage flow](docs/images/repository-name-banner.png)
```

Use meaningful alt text that states the device, connection method, and local destination. Do not repeat text that is already visible in the banner.

## Adding another device

Start from the same background, teal device family, Bluetooth treatment, typography, spacing, and local-storage motif. Choose one complementary accent based on the new measurement type. Keep that accent subordinate to the shared teal palette so the full set still reads as one system.

For basal body temperature and cycle tracking, use cycle plum for the measurement path, chart-and-cycle detail, or related emphasis. Keep the thermometer, Bluetooth mark, home-computing elements, and local-storage motif in the shared teal and aqua family.

## Branding repository and asset ownership

This `healthhub-branding` repository is the authoritative home for branding documentation, editable source artwork, approved exports, and historically meaningful superseded artwork. Product repositories keep copies of the approved assets they deploy or display, but do not become the source of truth for those assets. Failed experiments and temporary comparisons are removed rather than archived.

Organize the branding repository by identity and product:

```text
README.md
BRANDING.md
organization/
  avatar/
healthhub/
daemons/
  etekcity-scale-daemon/
  etekcity-bp-daemon/
  trividia-truemetrix-daemon/
  viatom-o2ring-daemon/
  easyathome-bbt-daemon/
  health-thermometer-daemon/
templates/
archive/
```

Each product directory may contain `source/`, `approved/`, `exports/`, and `archive/` subdirectories. Each daemon also has a short branding document recording its functional focus, accent color, approved artwork, filenames, and permitted uses. The root guide defines the shared system; product guides define only the product-specific details.

## Asset roles

Keep the following roles distinct:

- The organization avatar identifies Home Health Hub as an organization and the single installed Health Hub application.
- The Health Hub image identifies the main hub in documentation and larger interface placements.
- Daemon application images identify device functions in Hub dashboards, page headers, and repository documentation.
- Daemon navigation icons are simplified artwork for Health Hub tiles, menus, and other small interface placements.
- README banners are repository-specific landscape artwork and are not application-launcher icons.

Device-specific imagery must not be used as an Ubuntu application launcher. Health Hub presents daemon-backed functions after the user signs in; daemons do not provide separate browser interfaces.

## Health Hub application launcher

Provide one application launcher named **Health Hub**. It opens the main Health Hub page, where the user signs in, and does not open a daemon dashboard directly. Use the organization avatar for this launcher on every supported platform.

Use a stable reverse-domain identifier such as `org.homehealthhub.healthhub` for the desktop-file ID and icon basename. A Linux desktop entry should refer to the icon by that name rather than by an absolute file path:

```ini
[Desktop Entry]
Type=Application
Name=Health Hub
Comment=Open the Home Health Hub
Icon=org.homehealthhub.healthhub
Exec=xdg-open https://<health-hub-address>/
Terminal=false
Categories=Utility;MedicalSoftware;
```

The deployed launcher may replace the example URL or command during installation. The branding repository supplies artwork and an example desktop entry; deployment configuration owns the actual address.

### Ubuntu and Linux launcher exports

Store Linux exports using the Freedesktop `hicolor` hierarchy:

```text
organization/avatar/exports/linux/hicolor/
  16x16/apps/org.homehealthhub.healthhub.png
  22x22/apps/org.homehealthhub.healthhub.png
  24x24/apps/org.homehealthhub.healthhub.png
  32x32/apps/org.homehealthhub.healthhub.png
  48x48/apps/org.homehealthhub.healthhub.png
  64x64/apps/org.homehealthhub.healthhub.png
  96x96/apps/org.homehealthhub.healthhub.png
  128x128/apps/org.homehealthhub.healthhub.png
  256x256/apps/org.homehealthhub.healthhub.png
  512x512/apps/org.homehealthhub.healthhub.png
  scalable/apps/org.homehealthhub.healthhub.svg
```

Keep a 1024-by-1024 or larger master even when that size is not installed into the icon theme. Inspect the 16-through-48-pixel exports individually and simplify details where needed instead of relying only on automatic downscaling.

## Favicons and installable web application icons

The main Health Hub site uses the organization avatar for its favicon and installable web application identity. Provide:

```text
organization/avatar/exports/web/
  favicon.ico
  favicon.svg
  favicon-16x16.png
  favicon-32x32.png
  favicon-48x48.png
  apple-touch-icon-180x180.png
  pwa-192x192.png
  pwa-512x512.png
  maskable-192x192.png
  maskable-512x512.png
  monochrome.svg
```

The ICO file should contain the 16-, 32-, and 48-pixel variants. Normal favicon and launcher artwork may use transparency. Maskable icons require a deliberate opaque background and must keep essential artwork inside the central mask-safe area. Monochrome artwork must be a true single-color silhouette rather than a grayscale copy.

Daemon favicons may use their simplified navigation icons when distinguishing open dashboard tabs is useful. They do not replace the organization avatar as the installed Health Hub application's icon.

The web application manifest should declare ordinary, maskable, and monochrome purposes where the platform supports them:

```json
{
  "icons": [
    {
      "src": "/icons/pwa-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/icons/pwa-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/icons/maskable-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "/icons/monochrome.svg",
      "sizes": "any",
      "type": "image/svg+xml",
      "purpose": "monochrome"
    }
  ]
}
```

## SVG and raster masters

Provide SVG versions of all current organization, Health Hub, daemon, navigation, banner, monochrome, and maskable artwork wherever practical. SVG is the preferred editable master for flat artwork and icons. Retain approved high-resolution PNG masters and size-specific PNG exports for browsers, READMEs, PDFs, and environments that require raster images.

Use this general layout within each identity or product directory:

```text
source/
  asset-name.svg
  asset-name-master.png
approved/
  asset-name.svg
  asset-name.png
exports/
  svg/
    asset-name.svg
  png/
    asset-name-16.png
    asset-name-32.png
    ...
archive/
```

Classify each SVG in the relevant product branding document:

- **Native vector:** constructed from editable vector paths and shapes.
- **Vectorized:** traced from approved raster artwork, simplified, and visually verified against it.
- **Hybrid:** an SVG container that contains one or more raster elements because the artwork cannot be represented faithfully as clean vectors.

Do not treat an automatic trace as an approved master without inspection. Remove unnecessary paths, verify gradients and transparency, compare the rendering at intended sizes, and preserve the appearance of the approved image. Product branding documents should also record the source asset, SVG classification, export sizes, application or icon identifier where applicable, and any small-size simplification rules.
