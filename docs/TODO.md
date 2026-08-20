# Branding work

## Completed infrastructure

- Added a repository version marker and reproducible `SHA256SUMS` generation.
- Approved the native-vector organization avatar and true single-color monochrome mark for the export pipeline.
- Adopted hybrid SVGs for raster artwork so approved composition, proportions, and direction remain exact.
- Removed failed native-vector redraw experiments and their temporary comparison tooling.
- Added checksum verification, reproducible-build verification, CI, and a documented release process.
- Set the organization avatar as the single site-wide Health Hub URL-bar and browser-tab favicon, including daemon-dashboard routes.
- Assigned the actual Health Hub URL to deployment configuration; branding supplies only a placeholder launcher example.
- Standardized interface and report typography with an accessible local fallback stack.
- Defined shared operational-status labels and colors separately from device accents.
- Standardized manufacturer-neutral, function-led names for Hub navigation and ordinary user interfaces.
- Defined responsive Hub tiles for concurrent mouse, touch, keyboard, and assistive-technology use.
- Adopted WCAG 2.2 Level AA, contextual alternative text, and manual screen-reader testing as interface requirements.
- Standardized accessible, grayscale-safe chart presentation while leaving clinical chart selection to each daemon.
- Defined Light, Dark, and device-driven themes with authenticated database authority, logged-out browser persistence, and a Light fallback.
- Standardized calm interface language, specific empty and error states, and restrained accessible motion.
- Defined per-product `branding.lock.json` provenance and checksum verification for deployed assets.
- Added machine-readable design tokens, generated CSS, deterministic generation, and automated contrast verification.
- Added a Hub-and-daemon adoption guide that preserves Hub presentation ownership and standalone daemon API operation.
- Added a static interface specimen using the generated tokens and approved daemon identification images.
- Visually approved the interface specimen in Firefox, Chromium, and Vivaldi, including Vivaldi's smallest available window size.
- Defined restrained, text-led daemon PDFs for doctors, including provenance, accessibility, and Hub presentation rules without branding iconography.

## Later decisions

- Review the provisional doctor-facing PDF specification with the project owner and Claude Code before implementation.

## Implementation edge cases

Resolve these in Health Hub and daemon implementation plans. The highest-priority items are marked first.

### Highest priority

- [ ] Make daemon synchronization starts idempotent and handle duplicate Hub requests or an already-running job.
- [ ] Apply shared-browser theme precedence correctly across logged-out state, login, multiple users, delayed database reads, disabled storage, and `system` theme changes.
- [ ] Support multiple devices and manufacturers under one function-led Hub category without changing primary navigation identity.
- [ ] Preserve absolute timestamps, time zones, daylight-saving ambiguity, and distinct `Taken at`, `Received at`, and `Entered at` values.
- [ ] Support asynchronous, restart-safe, bounded PDF generation with stable report identifiers and verifiable response media types.

### Identity and navigation

- [ ] Provide a text-led fallback when a daemon identification image is missing, broken, or not yet approved.
- [ ] Let Health Hub select the person and device explicitly; do not infer a person solely from a device.
- [ ] Keep manufacturer and model names in secondary device details when a daemon supports several devices.

### Theme, input, and accessibility

- [ ] Prevent incorrect-theme flashes without allowing cached browser state to overwrite the authenticated database preference.
- [ ] Keep approved raster artwork legible in Dark mode using a controlled surface rather than inversion or recoloring.
- [ ] Preserve core links, headings, forms, and information when images, CSS, or JavaScript fail.
- [ ] Handle 200–400% text scaling, browser translation, forced colors, and long labels without truncation or fixed-height failures.
- [ ] Prevent duplicate screen-reader names and excessive live announcements during synchronization.
- [ ] Restore focus safely when a dialog trigger disappears after an update.
- [ ] Support simultaneous mouse, touch, and keyboard input without hover-only actions, overlapping targets, or accidental activation while scrolling.

### Daemon state and availability

- [ ] Keep unrelated Hub functions usable when one daemon is offline and label cached data with its last successful update.
- [ ] Define timeouts that move abandoned Syncing states to Unknown or Error.
- [ ] Resume or retrieve daemon-owned synchronization state after the browser closes instead of starting a duplicate job.
- [ ] Keep standalone daemon synchronization, durable data access, operational status, and PDF APIs functional without Health Hub.
- [ ] Define how primary and secondary facts appear when Error, Syncing, Offline, or Attention conditions overlap.

### Charts and measurement data

- [ ] Preserve original values and units when displaying conversions.
- [ ] Retain duplicate timestamps and out-of-order readings without silently merging or misordering provenance.
- [ ] Do not substitute `Entered at` for a missing `Taken at` without an explicit label.
- [ ] Keep historical PDFs immutable or explicitly superseded after a reading is corrected or excluded.
- [ ] Aggregate dense charts only for display and retain access to underlying readings.
- [ ] Use contrast-safe accent derivatives, marker shapes, line styles, and labels in both themes and grayscale.

### PDFs and APIs

- [ ] Echo the resolved person, date range, filters, and time zone in report response metadata.
- [ ] Verify HTTP status and media type before presenting an API response as a PDF.
- [ ] Preserve report metadata when a generated PDF expires and explain whether regeneration may include later corrections.
- [ ] Embed the approved font or record the stable fallback used by the PDF generator.
- [ ] Stream or use bounded temporary storage for large reports.
- [ ] Ensure Health Hub never adds pages, headers, watermarks, or other modifications to a daemon-produced PDF.

### Branding distribution

- [ ] Reject lock files that reference an unreleased version, missing commit, wrong asset role, or mismatched destination checksum.
- [ ] Treat removed or semantically changed token names as a breaking branding release.
- [ ] Require a coherent branding release when tokens and images are updated partially.
- [ ] Verify copied consumer assets and tokens against `branding.lock.json` in consumer CI.
