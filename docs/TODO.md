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

- [x] Make daemon synchronization starts idempotent and handle duplicate Hub requests or an already-running job; use the daemon-owned job contract in `docs/ADOPTION.md`.
- [x] Apply the database-authoritative, browser-cached theme contract in `docs/ADOPTION.md` across logged-out state, login, multiple users, delayed reads, disabled storage, and `system` changes.
- [x] Support multiple devices, manufacturers, and daemon sources under the function-led device/source contract in `docs/ADOPTION.md` without changing primary navigation identity.
- [x] Preserve absolute and raw local timestamps, time zones, daylight-saving ambiguity, certainty, precision, and distinct `Taken at`, `Received at`, and `Entered at` values under the time contract in `docs/ADOPTION.md`.
- [x] Support asynchronous, restart-safe, bounded PDF generation under the daemon-owned report-job contract in `docs/ADOPTION.md`.

### Identity and navigation

- [x] Use the text-led identification-image fallback in `docs/ADOPTION.md` when daemon artwork is missing, broken, or not yet approved.
- [x] Use the explicit person-selection contract in `docs/ADOPTION.md`; never infer a person solely from a device.
- [x] Keep manufacturer and model names in secondary device details under the device-label contract in `docs/ADOPTION.md`.

### Theme, input, and accessibility

- [x] Use the first-paint theme bootstrap in `docs/ADOPTION.md` without allowing cached browser state to overwrite the authenticated database preference.
- [x] Keep approved raster artwork legible under the controlled artwork-surface contract in `docs/ADOPTION.md`, without inversion or recoloring.
- [x] Preserve core links, headings, forms, and information under the graceful-degradation contract in `docs/ADOPTION.md` when images, CSS, or JavaScript fail.
- [x] Handle 200–400% text scaling, browser translation, forced colors, and long labels under the resilient-layout contract in `docs/ADOPTION.md`.
- [x] Prevent duplicate screen-reader names and excessive synchronization announcements under the assistive-technology announcement contract in `docs/ADOPTION.md`.
- [x] Restore focus under the dialog-focus contract in `docs/ADOPTION.md` when a trigger disappears after an update.
- [x] Support simultaneous mouse, touch, and keyboard input under the mixed-input contract in `docs/ADOPTION.md`.

### Daemon state and availability

- [x] Keep unrelated Hub functions usable under the independent-availability contract in `docs/ADOPTION.md` and label cached data with its last successful refresh.
- [x] Move abandoned `Syncing` presentation to `Unknown`, `Error`, or `Interrupted` under the daemon-authoritative timeout contract in `docs/ADOPTION.md`.
- [x] Resume presentation by retrieving daemon-owned state under the synchronization-recovery contract in `docs/ADOPTION.md` instead of starting a duplicate job after the browser closes.
- [x] Keep synchronization, durable data access, operational status, and PDF APIs functional without Health Hub under the standalone-daemon contract in `docs/ADOPTION.md`.
- [x] Present overlapping `Error`, `Syncing`, `Offline`, and `Attention` facts under the scoped-status contract in `docs/ADOPTION.md`.

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
