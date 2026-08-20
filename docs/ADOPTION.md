# Branding adoption guide

This guide translates the shared branding standards into implementation boundaries for Health Hub and daemon repositories.

## Architecture boundary

Health Hub owns every interactive browser page, including pages that display or control daemon-backed functions. Do not add a separate browser interface to a daemon.

A daemon remains useful without Health Hub. Its API must support its core responsibilities, including:

- starting, scheduling, or reporting synchronization as appropriate to the device;
- reading its own durable data and synchronization state;
- generating and returning its authoritative PDF reports;
- reporting operational health and errors for an API client or administrator.

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
