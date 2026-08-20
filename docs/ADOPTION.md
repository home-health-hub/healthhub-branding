# Branding adoption guide

This guide translates the shared branding standards into implementation boundaries for Health Hub and daemon repositories.

## Architecture boundary

Health Hub owns every interactive browser page, including pages that display or control daemon-backed functions. Do not add a separate browser interface to a daemon.

A daemon remains useful without Health Hub. Its API must support its core responsibilities, including:

- starting, scheduling, or reporting synchronization as appropriate to the device;
- reading its own durable data and synchronization state;
- generating and returning its authoritative PDF reports;
- reporting operational health and errors for an API client or administrator.

### Synchronization job contract

- Health Hub requests synchronization with `POST /sync-jobs` and an `Idempotency-Key`; the daemon creates and owns the job.
- Repeating the same key and request returns the original job. Reusing a key with different parameters returns `409 Conflict`.
- If an equivalent job is active for the same device and operation, return that job with `already_running: true` rather than starting another.
- Closing the Hub browser does not cancel daemon work. Clients retrieve state with `GET /sync-jobs/{job_id}`.
- Use `queued`, `running`, `succeeded`, `failed`, and `interrupted` states. Persist the job and idempotency record transactionally before work begins.
- Responses include stable job and error identifiers, device identity, creation/start/completion timestamps, progress when known, and imported/skipped/error counts.
- After a daemon restart, resume safely or mark abandoned work `interrupted`; never leave it silently `running`.
- A retry after interruption creates a new job and relies on reading-level deduplication to prevent duplicate measurements.
- Retain idempotency keys for a documented period, initially 24 hours. Retain completed job history according to the daemon's longer history policy.

Health Hub calls those APIs and presents the results. It does not become the source of truth for daemon measurements, recreate daemon PDFs, or require a daemon to use Hub presentation code.

An individual Hub-rendered daemon page may use the daemon's approved application or navigation image to identify the function visually. Pair it with the visible function-led page title and apply the shared alternative-text rules. This page image does not replace the organization avatar as the site favicon and is not inserted into doctor-facing PDFs.

## Health Hub adoption

1. Copy `tokens/brand.css` into the Hub's deployable static assets.
2. Record its source, destination, release, commit, and checksum in `branding.lock.json`.
3. Load the token CSS before component styles.
4. Resolve `light`, `dark`, or `system` and set the resolved `data-theme` on the root HTML element before first paint where practical.
5. Store the authenticated preference in the Hub database and browser copy according to the precedence in the interface standard.
6. Render daemon-backed functions with the same Hub components, accessibility behavior, and function-led naming as native Hub functions; use the approved daemon image as an optional page identifier.
7. Treat daemon API failures as operational states and preserve the daemon's error reference without exposing sensitive diagnostics.

### Theme state contract

The database preference and browser cache may contain `light`, `dark`, `system`, or no value. The runtime-resolved theme is always `light` or `dark`.

- Before authentication is known, use valid browser storage; use Light when it is absent, inaccessible, or malformed.
- After login, a valid database preference overrides and refreshes browser storage. An authenticated user with no database preference receives Light, not the previous browser user's choice.
- Keep the last successfully stored non-sensitive browser value on logout. A different user receives their own database preference after login.
- Apply an explicit change immediately. While logged in, persist it to the database first and update browser storage only after success. On failure, keep it in memory for the session, announce that it was not saved, and leave persistent browser storage unchanged.
- While logged out, save an explicit selection directly to browser storage. Never copy a logged-out choice automatically into a newly authenticated database record.
- Store `system`, not its current resolved color. Follow operating-system changes while selected, stop following them after explicit Light or Dark selection, and resolve unavailable system detection to Light.
- Catch storage-access errors and ignore corrupted values without breaking the interface.
- Use a preference revision or request sequence so a delayed database response or stale save cannot overwrite a newer in-session selection.
- Synchronize successful changes across open Hub tabs without placing user identifiers or health information in browser theme storage.
- The authenticated database preference remains authoritative.

### First-paint theme bootstrap

- Apply the valid browser-cached preference before first paint with a small inline script in the document `head`.
- If browser storage is absent, inaccessible, or invalid, render Light mode. For a cached `system` choice, resolve the current operating-system preference before paint.
- The pre-paint choice is temporary rendering state, not authenticated preference authority.
- After login or session restoration, retrieve the user's database preference and apply it when different.
- Update browser storage only after an authenticated preference is successfully retrieved or after the person explicitly changes it. Never upload a logged-out cached choice as the database preference.
- Keep the document's script-free initial background compatible with Light mode so a blocked or failed bootstrap does not cause a dark or bright flash.
- The bootstrap contains no identity or health data, performs no network request, and does not depend on the main JavaScript bundle.

### Controlled artwork surface

- Never invert, recolor, tint, or apply automatic Dark-mode filters to approved artwork.
- Place raster artwork on a controlled neutral surface that maintains sufficient separation from surrounding content in Light and Dark themes.
- Use consistent padding and a subtle theme-appropriate border so transparent or same-colored image edges remain distinguishable.
- Preserve the source aspect ratio without cropping or stretching identification artwork.
- Select an approved source resolution suitable for the rendered dimensions and high-density displays; do not upscale a visibly inadequate source.
- If approved artwork remains illegible, omit it and use the text-led identification fallback.
- Do not create or select a separate Dark-mode artwork variant unless the branding repository explicitly publishes and versions it for that role.
- Verify the artwork surface in Light, Dark, forced-colors, and platform high-contrast settings.

### Graceful-degradation contract

- Server-delivered HTML contains meaningful headings, labels, status text, reading summaries, and navigation links.
- Use real links and native form controls as the baseline. JavaScript may enhance their behavior without replacing their semantics.
- Images remain optional and never provide the only occurrence of a name, status, instruction, or measurement.
- Keep content in a logical document order that remains readable and operable if stylesheets fail.
- If JavaScript fails, preserve essential navigation and access to existing data wherever authentication permits.
- For actions that inherently require JavaScript, including live synchronization progress or interactive charts, provide a clear fallback explanation and a usable alternative where practical.
- Manual-entry forms retain server-side validation and submission. Client-side validation is an enhancement.
- Every chart view includes an accessible table or reading list that does not depend on chart JavaScript.
- Fallback and error content never exposes sensitive diagnostics.
- Test blocked images, blocked stylesheets, and blocked scripts as separate failure conditions.

### Resilient layout and text contract

- Support browser zoom and text-only scaling through at least 200%, and test up to 400% where practical.
- Use responsive reflow and avoid fixed heights on text-containing controls, cards, tables, alerts, and navigation.
- Allow labels, values, translated text, and device nicknames to wrap without overlap or clipping.
- Do not truncate medically important values, units, timestamps, person names, statuses, or error explanations.
- Use horizontal scrolling only for genuinely tabular data and preserve visible or programmatic row and column context.
- At narrow widths, reflow non-tabular multi-column layouts into one logical reading order.
- In forced-colors mode, preserve system colors and visible borders; do not rely on background images, shadows, or color alone.
- Icons and custom controls remain identifiable when forced colors replace authored colors.
- Language expansion must not separate labels from their controls or change the intended reading order.
- Test at 200% and 400% with representative long names, expanded translations, narrow touch screens, and forced-colors mode.

### Assistive-technology naming and announcement contract

- Give each interactive control one concise accessible name. Do not duplicate visible text with redundant `aria-label` values or image alternative text.
- Prefer native labels, headings, fieldsets, legends, and descriptions before adding ARIA.
- Treat decorative images and images that merely repeat an adjacent visible title as decorative with empty alternative text.
- Use one dedicated synchronization status region with `role="status"` or `aria-live="polite"`.
- Announce only meaningful transitions: started, completed, failed, interrupted, or action required.
- Do not announce every progress tick, elapsed-time change, retry, received reading, polling response, rerender, or animation.
- Deduplicate unchanged state so polling cannot repeatedly announce the same message.
- Reserve assertive alerts for failures that require immediate action or block the current task. Routine progress and success messages remain polite.
- Keep visible status wording and announced status consistent.
- Test accessible names and synchronization announcements with at least one screen reader using keyboard and mouse workflows.

### Dialog focus contract

- When a dialog opens, remember its trigger only as the preferred focus-return target.
- On close, return focus to the trigger only if it still exists, is visible, is enabled, and belongs to the current view.
- If the trigger is unavailable, move focus to the nearest logical surviving target, such as the updated record, surrounding section heading, or primary action.
- If the underlying view was replaced, focus the new page's main heading or a programmatically focusable main-content container.
- Never return focus to the document body, a hidden element, or a newly destructive action.
- If dialog completion deletes the triggering record, announce the result and move focus to the surrounding list or heading.
- Keep focus contained within a modal dialog while it is open, including its loading and recoverable error states.
- Allow Escape to close only when dismissal is safe. Require confirmation before discarding an unsaved destructive change.
- Test close-button dismissal, Escape, successful submission, deletion, route replacement, and asynchronous refresh.

### Mixed-input contract

- All actions work with keyboard and mouse. Primary workflows also provide comfortably sized touch targets.
- Do not infer input method from viewport width or assume a person uses only one input method.
- Never make an action available only through hover, swipe, drag, long-press, or right-click.
- Hover may add supplementary styling, but the same information and actions remain persistently discoverable.
- Use a minimum 44 by 44 CSS-pixel target where practical. When a smaller target is necessary, provide adequate spacing and an equivalent larger activation target.
- A scrolling gesture must not activate a control merely because the gesture began on it.
- Prevent duplicate activation when a browser emits pointer, touch, and synthetic click events for one gesture.
- Drag operations provide button or keyboard alternatives and a cancellation path.
- Keep keyboard focus indicators visible and distinct from hover styling.
- Test mixed sequences on touchscreen computers: touch then keyboard, mouse then touch, and keyboard while pointer hover remains active.

### Function, device, and source contract

- Keep primary Hub navigation function-led. Manufacturer and model remain secondary device metadata.
- Each daemon owns a stable physical-device ID. Health Hub uses a globally unambiguous `{daemon_id}:{device_id}` source reference.
- Daemon APIs expose device name, manufacturer, model, capabilities, connection method, and operational state; Health Hub does not infer capabilities from model names.
- With one configured source, select it without unnecessary selector UI. With several, provide an accessible selector near the page heading and allow a user-defined nickname without treating it as identity.
- Save the last selected source per Hub user and health function. If it disappears, select a valid remaining source and explain the change.
- One offline source does not make a function unavailable while another valid source remains.
- Offer an All devices view only for measurements with compatible meaning and units. Preserve daemon and device provenance for every reading, preserve original values and units, and never silently merge duplicate-looking readings from different sources.
- Use labels, marker shapes, and line styles when source distinction matters; do not assign permanent manufacturer colors.
- Keep person selection separate from device selection. Health Hub supplies or resolves the person and changing source must not silently change that person.
- A physical device does not imply one person unless explicitly configured.
- Several daemons may supply the same function category while retaining authority over their own measurements.
- Routes and bookmarks use function and stable source identifiers rather than manufacturer names.

### Daemon identification-image fallback

- The visible function-led page title remains the primary identifier. Daemon artwork is supplementary.
- If approved artwork is missing, unavailable, or fails to load, omit the image and preserve a complete, usable text-led layout. Do not expose a broken-image indicator.
- Do not substitute another daemon's artwork, generic daemon artwork, or a manufacturer logo.
- When an adjacent visible heading already provides the same identification, use empty alternative text for the image to prevent duplicate screen-reader output. Supply descriptive alternative text only when the image communicates additional information.
- Image availability never controls navigation, operational status, forms, actions, charts, or access to measurement data.
- Record a missing or failed asset as an administrative or deployment diagnostic without presenting it to the person as an alarming health or device error.
- Consumer CI verifies that required approved assets exist and match the branding lock. The runtime fallback remains required for incomplete or damaged deployments.

### Person-selection contract

- Health Hub owns interactive person selection and sends a stable `person_id` to the daemon for person-specific operations.
- Never infer the person solely from a selected device, signed-in account, browser state, or most recent reading. Device selection and person selection remain independent.
- Show the selected person near manual-entry, synchronization, chart, and report actions whenever the result belongs to or is filtered for that person.
- Before a person change discards or reassigns unsaved form data, require explicit confirmation. Changing the selected device never changes the selected person.
- With no selected person, disable person-specific submission and report actions and explain how to select one. Do not silently choose a default.
- Reject an unknown, deleted, inactive, or unauthorized `person_id` without substituting another person.
- The daemon validates the supplied person identity and stores it with resulting records, synchronization assignments, or report parameters as applicable.
- Audit data keeps the actor who performed an action separate from the person whose health data the action concerns.

### Device-label contract

- Keep the health function as the page title and primary navigation label regardless of manufacturer or model.
- In device selectors and details, show a user-defined nickname first when available. Otherwise use a normalized model label or a neutral function-based label such as `Blood pressure device`.
- Present manufacturer and model as secondary device details rather than as the identity of the health function.
- Manufacturer metadata is optional and may be missing or unreliable. Its absence must not prevent configuration or use of an otherwise supported device.
- Never infer capabilities, compatibility, or person identity from manufacturer or model text. Use explicit daemon-reported capabilities and stable identifiers.
- Distinguish devices with identical labels using a nickname, a non-sensitive shortened stable device ID, or a connection location.
- Preserve raw daemon-reported manufacturer and model values for diagnostics while allowing reviewed normalized display labels.
- Supporting another manufacturer requires no change to primary navigation, route structure, branding, or page layout.

### Measurement-time contract

- Keep `taken_at`, `received_at`, and `entered_at` independent. Never substitute one silently for another.
- Store known absolute instants in UTC and preserve the original device or local value, applicable IANA time-zone name, numeric offset, source precision, and clock source.
- For a naive device clock, preserve the raw local value and apply a configured device time zone only when known. Mark the result `exact`, `assumed`, `ambiguous`, or `unknown`; never silently use the daemon's current offset.
- Preserve repeated daylight-saving times as ambiguous without a reliable offset or ordering clue. Preserve nonexistent spring-forward values as invalid or uncertain rather than shifting them silently.
- Preserve the original device timestamp when correcting clock drift. Store corrected effective time, method, and reason separately, and do not rewrite history after a time-zone configuration change.
- Emit absolute API timestamps in RFC 3339 form with `Z` or an explicit offset and include original local value, IANA zone, precision, source, and certainty metadata where applicable.
- Assign `received_at` with the daemon's trusted ingestion clock and `entered_at` when a manual entry is committed. A missing `taken_at` remains missing.
- Display time in the Hub user's locale while identifying the applicable zone. Distinguish repeated local times with an offset or abbreviation.
- Sort first by reliable effective `taken_at`; keep uncertain records visible and use receipt time plus stable record ID only as a deterministic fallback.
- Do not imply exact chart spacing when source precision or certainty is insufficient.
- A PDF records the display zone, conversion rule, relevant uncertainty or correction, and timestamp semantics used at generation so later configuration changes do not alter it.

### PDF report-job contract

- A daemon accepts `POST /report-jobs` with the resolved person, a clearly defined inclusive/exclusive time range, display time zone, filters and exclusions, report format, and an idempotency key.
- Return `202 Accepted` with a stable `job_id`, status URL, queued state, and the future `report_id` when it can be assigned safely at submission.
- Repeating an idempotency key with the same normalized request returns the original job. Reusing it with a different request returns `409 Conflict`.
- Job states are `queued`, `running`, `succeeded`, `failed`, `interrupted`, and `expired`. `GET /report-jobs/{job_id}` returns timestamps, progress when meaningful, error references, the resolved request fields, generator and report-format versions, and output metadata.
- Closing or disconnecting the browser does not cancel a job. The daemon persists the normalized request and job state, then resumes safely after restart or marks the job `interrupted` with an explicit retry path.
- Generate into bounded temporary storage on the destination filesystem and publish by atomic rename. Never expose a partial PDF.
- Stream inputs and outputs where practical. Enforce documented limits for date range, reading count, output size, generation time, concurrency, and temporary-disk use. Reject an oversized request explicitly instead of silently truncating it.
- A completed report has stable metadata and a content endpoint that returns `application/pdf`, a safe `Content-Disposition` filename, a correct content length when known, and immutable content for that `report_id`.
- Report metadata includes SHA-256, byte length, generation time, daemon and report-format versions, resolved person, range, display time zone, filters and exclusions, reading count, and any report it supersedes.
- Health Hub verifies successful job state, report identity, and response media type before offering browser viewing or download. It never reconstructs or modifies the daemon-produced PDF.
- Retain report metadata after downloadable content expires. An expired-content response explains that regeneration creates a new report ID and may include later corrections or exclusions under the daemon's documented retention policy.
- Historical PDFs remain immutable. Corrections or exclusions produce a new report that may explicitly supersede an earlier report.
- Report creation, status retrieval, metadata retrieval, and content download remain usable through the daemon API without Health Hub.

The Hub may copy approved organization, Hub, application, and navigation artwork required by its pages. It does not copy README banners into the application.

## Daemon adoption

1. Keep approved repository and device artwork required for documentation or distribution and record copied branding inputs in `branding.lock.json`.
2. Do not implement a branded browser UI or a separate theme preference.
3. Keep synchronization, durable data, operational state, and PDF generation available through the daemon API without Health Hub.
4. Keep report generation deterministic for the same data and report parameters where practical.
5. Return a stable report identifier, media type, filename, generation time, and report-format version with a generated PDF.
6. Preserve `Taken at`, `Received at`, and `Entered at` as distinct fields when applicable.
7. Use design-token source values needed for report typography or charts without importing browser-only component behavior.

The doctor-facing PDF specification remains provisional and must be reviewed with the project owner and Claude Code before implementation.

## Branding lock

Start from [`templates/branding.lock.example.json`](../templates/branding.lock.example.json). Use a released branding version without a `-dev` suffix, an exact source commit, and SHA-256 values from this repository's `SHA256SUMS`.

Product CI must verify that every listed destination exists and matches its checksum. An asset or token update and its lock-file update belong in the same pull request. Do not fetch branding assets at runtime or use this repository as a submodule.

## Required verification

Health Hub implementation review includes:

- Light, Dark, logged-in, and logged-out theme behavior;
- database/browser preference precedence;
- mouse, touch, keyboard, screen-reader, zoom, and reduced-motion workflows;
- function-led names and accessible status announcements;
- chart summaries, accessible values, and grayscale behavior;
- lock-file and copied-token verification.

Daemon implementation review includes:

- standalone synchronization and data access without Health Hub;
- standalone PDF generation through the API;
- report provenance and timestamp fields;
- lock-file verification for copied assets or tokens;
- confirmation that no separate browser interface was introduced.

## Ownership summary

| Concern | Authority |
|---|---|
| Browser pages and interaction | Health Hub |
| User identity and theme preference | Health Hub |
| Device synchronization | Daemon |
| Measurement data and provenance | Daemon |
| PDF content and generation | Daemon |
| PDF browser viewing and download coordination | Health Hub |
| Shared visual rules and token values | Branding repository |
| Deployed copies of assets and tokens | Consuming repository, locked to a branding release |
