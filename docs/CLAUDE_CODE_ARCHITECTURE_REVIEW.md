# Claude Code architecture review handoff

## Review objective

Review the Health Hub consolidation draft for technical accuracy, missing requirements, contradictions, accidental scope changes, and implementability. This is a review of architecture and contracts, not authorization to change application code or the three protected source documents.

The project owner must review consequential findings before this draft can become canonical.

## Files to review

Primary draft:

- [`HEALTH_HUB_SYSTEM_ARCHITECTURE.md`](HEALTH_HUB_SYSTEM_ARCHITECTURE.md)

Required review evidence:

- [`ARCHITECTURE_TRACEABILITY.md`](ARCHITECTURE_TRACEABILITY.md)
- [`ARCHITECTURE_CONSOLIDATION_CHECK.md`](ARCHITECTURE_CONSOLIDATION_CHECK.md)
- [`ARCHITECTURE_REVIEW_FINDINGS.md`](ARCHITECTURE_REVIEW_FINDINGS.md)
- [`ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md`](ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md)
- [`ARCHITECTURE_SOURCE_INVENTORY.md`](ARCHITECTURE_SOURCE_INVENTORY.md)
- [`INTERFACE_AND_REPORT_STANDARDS.md`](INTERFACE_AND_REPORT_STANDARDS.md)
- [`ADOPTION.md`](ADOPTION.md)

Protected read-only sources in the local Health Hub checkout:

- `docs/Claude-foundation.md`
- `docs/Claude-Addendum-HA.md`
- `docs/Preliminary.md`

## Protected-source snapshot

Review the protected documents at Health Hub commit `d38bef06a01aaaeb28b1b997b49bddf44403d07e` and confirm these SHA-256 values before relying on the comparison:

| Source | SHA-256 |
|---|---|
| `Claude-foundation.md` | `4bbd19a2b8c6dd757f0fd13b6f4884152908c7a342d7dae692510e68f4b282c3` |
| `Claude-Addendum-HA.md` | `6c3009630a131e5d7928cbacd6efd5438e172d86c86d3a88183ece001027a805` |
| `Preliminary.md` | `42e91223f969210cb252ad365247c35a1f43acbc8d6f4d2e6fa056b3d71c6d00` |

Do not edit, rename, replace, or delete those three files.

## Required checks

1. Confirm that daemon authority, Hub authority, and the physical-device/driver boundary are internally consistent.
2. Confirm that MQTT remains a near-real-time event channel while REST remains the operational, query, report, assignment, and recovery channel. Review guided MQTT administration for separate connectivity/authentication/TLS/ACL/event/retained-state checks, synthetic previews, last-known-good preservation, and the prohibition on general broker tooling.
3. Confirm that the draft never makes a Hub cache or MQTT retained message authoritative history.
4. Check identity separation among account, person, actor, subject, daemon profile, physical device, daemon instance, logical source, transport identifier, and source record.
5. Check unassigned-reading preservation and its exclusion from person-specific output until authorized assignment.
6. Check `taken_at`, `received_at`, and `entered_at` semantics, including missing clocks and manual entry.
7. Check the OpenAPI 3.1 requirement and optional history/manual-entry capability contracts for feasibility and compatibility with current daemon APIs.
8. Check that daemons remain independently usable without the Hub and retain PDF generation through their APIs.
9. Check daemon-owned exact-byte PDF handling, asynchronous report-job expectations, Samba report access, and the prohibition on exposing databases or secrets.
10. Check roles, composability, individual role-management previews and revocation, granular owner-controlled health-data delegation and optional expiration, sole-SHA protections, SHA access disclosure, show-once and replacement-first secret handling, the capability-scoped notification center and its acknowledgment/resolution semantics, audit protection, scoped read-only audit search and safe export, persistent integrity-failure handling, separation of operational logs from audit history, the separately assigned minimum diagnostic-metadata capability that excludes health-content access, recent reauthentication plus execution-time revalidation for high-risk Web UI actions, and the account-disable/delegation lifecycle.
11. Check SQLite, SQLAlchemy 2.0 style, per-component Alembic, migration, backup, restore, and no-cross-database rules. Review the advanced backup and optional rclone UI boundary for safe schema-driven coverage without arbitrary flags, raw configuration, or shell construction. Review storage administration for truthful usage/pressure states, component-owned cleanup, last-copy protection, partial results, and the prohibition on Hub deletion of daemon readings.
12. Check the distinction between native systemd Hub/daemon services and containerized infrastructure such as MQTT and Mailpit, including fixed capability-scoped Web UI operations, allowlisted restart handling, rate limiting, the prohibition on browser-supplied system commands, and the update-information-only Web UI boundary with host-side SHA installation.
13. Check capability-driven manufacturer-neutral expansion, device replacement, Home Assistant optionality, unknown-capability tolerance, and the schema-driven daemon-configuration UI boundary with daemon-side validation/storage and truthful partial-result handling.
14. Check that detailed presentation and report behavior is delegated consistently to the interface/report and adoption standards without weakening an architecture boundary, and review the attention-first administration overview for capability scoping, health-content exclusion, state semantics, and accessible refresh.
15. Compare the traceability and consolidation tables against every protected-source heading and report any unsupported coverage claim.

## Review constraints

- Treat approved AR dispositions as owner decisions. Do not silently revert them to an older source statement.
- Identify a conflict between an approved decision and implementation as implementation work or migration risk, not a reason to rewrite the decision without owner review.
- Do not infer that a currently implemented framework, endpoint, topic, schema, path, service name, or package layout is permanent architecture.
- Do not turn named devices, manufacturers, personal names, example topics, example routes, or display sizes into fixed system identifiers or support limits.
- Do not modify application code during this review.
- Do not mark the draft canonical or change the disposition of the protected sources.

## Required response format

Return findings ordered by severity:

- **Blocking:** contradiction, unsafe authority transfer, missing security/data-integrity boundary, or requirement that cannot be implemented coherently.
- **Important:** material omission, ambiguity, incompatibility, or traceability error that should be corrected before adoption.
- **Editorial:** wording or organization improvement that does not change the architecture.

For each finding provide:

1. a short title;
2. the exact draft section and relevant source/contract section;
3. why it matters;
4. the smallest proposed correction; and
5. whether project-owner input is required.

Then provide:

- a list of checks that passed;
- a list of deferred questions that remain intentionally unresolved;
- a statement confirming whether the protected-source hashes matched; and
- one conclusion: `ready for owner adoption review`, `ready after listed corrections`, or `not ready`.

Do not edit files until the project owner has reviewed the findings and authorized the correction set.

## Owner review gate

After Claude Code returns its findings, the project owner and Codex will review each Blocking or Important item. Accepted corrections will be applied to the draft, traceability matrix, and consolidation check together. The Phase 5 joint-review TODO remains incomplete until that process finishes.
