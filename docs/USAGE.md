# Asset usage

## Health Hub launcher

Use `org.homehealthhub.healthhub` as the icon basename and desktop-file identifier. The launcher uses the organization avatar and opens the main Hub login page.

Linux packages install the PNG icons from `organization/avatar/exports/linux/hicolor/` into the matching `hicolor` theme directories. Install the SVG fallback from `scalable/apps/` when supported.

The example in `organization/avatar/org.homehealthhub.healthhub.desktop.example` intentionally contains a placeholder URL. The branding repository does not define a production address. Installation or deployment configuration must substitute the applicable Hub address.

## Web application

Use files in `organization/avatar/exports/web/` for the main Health Hub favicon, browser metadata, installable PWA, and touch icon. The PWA manifest should declare the 192- and 512-pixel normal icons and the maskable variants.

Use the organization avatar as the single site-wide URL-bar and browser-tab favicon. It remains the favicon on login, administration, general Hub, and daemon-dashboard routes. Daemon navigation icons belong inside the page interface and do not replace the website favicon.

## Device interfaces

Use daemon navigation icons for tiles, compact navigation, and optional daemon-specific browser tabs. Use daemon application images for dashboard headers and larger identity placements. Use banners in repository READMEs. None of these replaces the organization avatar as the operating-system launcher icon.

## Reports and PDFs

Daemons remain responsible for the contents and generation of their PDFs. They may use their approved device image, navigation mark, accent, and chart styling. Health Hub coordinates viewing and downloading those daemon-produced documents without becoming their branding or content authority.
