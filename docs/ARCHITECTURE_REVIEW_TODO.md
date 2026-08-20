# Health Hub architecture review TODO

## Purpose

Prepare for an eventual consolidated Health Hub architecture specification without prematurely rewriting or retiring its source documents. This review records overlap, disagreement, stale assumptions, and implementation claims before proposing resolutions.

## Source protection

The following files in `home-health-hub/healthhub` are read-only review inputs and must not be edited, renamed, replaced, or deleted during this review:

- `docs/Claude-foundation.md`
- `docs/Claude-Addendum-HA.md`
- `docs/Preliminary.md`

The source commit and checksums used for the review are recorded in `docs/ARCHITECTURE_SOURCE_INVENTORY.md`. If a source changes upstream, record and review the new version rather than silently replacing the reviewed text.

## Finding classifications

Use one or more of these labels for each finding:

- **Consistent:** sources express compatible requirements.
- **Duplicate:** substantially the same requirement appears more than once.
- **Conflict:** requirements cannot all be implemented as written.
- **Stale:** a later approved decision or current project scope has superseded the statement.
- **Unverified:** the statement depends on code, hardware, protocol, or external-system behavior that has not been checked for this review.
- **Outside scope:** valid material that does not belong in branding, interface, or report standards.

Do not treat document order, filename, length, or apparent recency as authority. A conflict remains unresolved until the project owner approves its disposition.

## Phase 1: inventory

- [x] Bring the three Health Hub source documents into a clean local read-only checkout.
- [x] Record the Health Hub source commit and SHA-256 checksum for each document.
- [x] Record each document's purpose, major topic coverage, and obvious overlap.
- [x] Map every substantive section to the topic categories below.
- [x] Identify statements that are examples rather than requirements.
- [x] Identify personal names, device lists, endpoint examples, and other values that must not become permanent architecture accidentally.

## Phase 2: topic review

Review one category at a time. Record evidence and proposed dispositions before changing a canonical standard.

- [x] System scope and single-appliance assumptions.
- [x] Hub, daemon, device-driver, and physical-device authority boundaries.
- [x] Person, account, profile, actor, device, and source identity.
- [x] Measurement ownership, provenance, timestamps, correction, and retention.
- [x] Daemon APIs, Hub API, versioning, authentication, and local transport.
- [x] MQTT as the Hub/daemon coordination backbone: events, commands, state, retained data, topic design, delivery semantics, and publisher authority.
- [x] Home Assistant discovery and independence from Home Assistant.
- [x] Browser UI, dashboard, optional displays, sessions, and interaction methods.
- [x] Charts, summaries, notifications, goals, and non-diagnostic language.
- [x] Daemon-owned doctor-facing PDFs and Hub viewing/download coordination.
- [x] Roles, permissions, delegation, recovery administration, and audit.
- [x] Backup, restore, unrecoverable data, Samba, and filesystem access.
- [x] Installation, systemd, host operating system, Python environments, and updates.
- [x] Device-specific capabilities, replacement, and manufacturer-neutral expansion.
- [x] Initial-release scope, deferred work, and stated implementation constraints.

## Phase 3: verification

- [x] Build a claim register for statements about current Hub or daemon behavior.
- [x] Verify API, storage, configuration, MQTT, report, and service claims against current source repositories; see [`ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md`](ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md).
- [x] Verify hardware/protocol limitations against current daemon or driver evidence; see the hardware and protocol section of [`ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md`](ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md).
- [x] Separate confirmed implementation behavior from desired architecture.
- [x] Record external-system assumptions against current official Home Assistant documentation; see the external-system section of [`ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md`](ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md).

## Phase 4: decisions

- [x] Present consequential conflicts to the project owner individually.
- [x] Record the approved resolution, rationale, affected sources, and destination document.
- [x] Keep rejected alternatives and unresolved questions visible in the review record.
- [x] Avoid changing implementation merely to make a draft document appear internally consistent.

## Phase 5: consolidation

- [x] Draft a purpose-named consolidated architecture specification without changing the three source documents; see [`HEALTH_HUB_SYSTEM_ARCHITECTURE.md`](HEALTH_HUB_SYSTEM_ARCHITECTURE.md).
- [x] Keep system boundaries in the consolidated specification, reference the existing interface/report and adoption standards, and route future machine-facing detail to focused contracts only where it has an independent compatibility surface, test suite, release cadence, or maintainer.
- [x] Trace every retained requirement group to its protected source, approved review decision, or focused standard in [`ARCHITECTURE_TRACEABILITY.md`](ARCHITECTURE_TRACEABILITY.md).
- [x] Compare the draft against every protected source section and the completed interface/report contracts; record coverage, delegation, supersession, evidence-only material, deferrals, and corrections in [`ARCHITECTURE_CONSOLIDATION_CHECK.md`](ARCHITECTURE_CONSOLIDATION_CHECK.md).
- [ ] Review the consolidated draft with the project owner and Claude Code.
- [ ] Adopt a canonical specification only after explicit approval.
- [ ] Decide separately whether the three source documents remain historical, become pointers, or are archived.

## Deferred mail-service discussion

Do not treat the following as adopted architecture. Revisit it with the project
owner before changing the consolidated specification or implementation plans.

- [ ] Decide whether Lightr should replace Mailpit as the local household mail
  service. The review must cover per-account mailbox isolation, local-only
  operation, password-reset delivery, external-email fallback, report delivery,
  backup and recovery, security maintenance, and deployment ownership.
- [ ] If Lightr is selected, decide whether the optional browser mail client is
  SnappyMail, LilMail, a limited Hub-integrated mailbox view, or no bundled
  webmail. Compare accessibility, mouse/touch/keyboard support, account and
  session isolation, IMAP/SMTP compatibility, maintenance maturity, resource
  use, dependencies, update handling, and unnecessary exposed features.
- [ ] Keep mailbox credentials separate from Health Hub passwords. Define the
  authentication and credential handoff model before choosing a webmail client;
  do not expose Lightr's administrative or general service API directly to
  household users.
- [ ] Retain the currently documented Mailpit architecture until an explicit
  replacement decision is approved and recorded.

## Publishing cadence

Complete and publish one coherent review category before moving to the next category. A review pull request may add findings and approved dispositions, but must not modify the three protected Health Hub source documents.
