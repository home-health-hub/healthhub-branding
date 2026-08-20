# Health Hub architecture review findings

This document records evidence and proposed dispositions during the read-only review. A proposal is not an approved architecture decision until the project owner accepts it. The protected Health Hub source documents remain unchanged.

## Finding statuses

- **Awaiting owner decision** — evidence and a proposal are ready, but no resolution is approved.
- **Approved** — the project owner accepted the stated resolution.
- **Needs verification** — current code, hardware, protocol, or primary external documentation must be checked first.
- **Unresolved** — evidence is incomplete or competing requirements remain.

## AR-001: System scope and single-appliance assumptions

**Status:** Awaiting owner decision
**Classifications:** Consistent, Duplicate, Stale, Unverified, Outside scope

### Source evidence

- `Claude-foundation.md` sections 1–5 and 50 describe a unified Hub over independent daemons. They say components normally run on the same physical machine, daemon APIs remain the boundary, and daemons remain usable without the Hub.
- `Preliminary.md` sections 1–4 describe a personal or household appliance rather than a hospital, clinic, enterprise, or multi-station system. It says all Health Hub components are installed on the same physical machine while standalone daemons remain independently installable and useful.
- `Preliminary.md` section 27 repeats the single-household, normally-one-machine, independent-service, daemon-authority, and API-boundary constraints.
- `Claude-Addendum-HA.md` sections 1, 18, and 20 treat Home Assistant as an optional consumer and prohibit it from becoming a Hub or daemon dependency.
- Current interface/report contracts agree that Health Hub owns browser presentation while daemons remain independent authorities for their data, synchronization state, and PDFs.

### Consistent core

- The product is designed first for an individual or household.
- A normal integrated Health Hub deployment is one local appliance rather than a distributed clinical system.
- Health Hub and its supported daemons remain separate services with API boundaries even when colocated.
- A daemon can be installed and used without Health Hub.
- Optional integrations and displays are consumers and do not define the core system.

### Ambiguities and stale examples

- “All components are installed on the same physical machine” can be misread as prohibiting standalone daemon-only installations. The surrounding text indicates it describes an integrated Hub deployment, not every valid daemon deployment.
- “Not required” for remote discovery, registration, and WAN-facing daemon APIs does not necessarily mean “permanently forbidden.” The documents place them outside current scope.
- The four named daemon integrations and their diagrams are an initial set, not an architectural allowlist. They omit the later BBT work and any future supported manufacturer or device.
- A local Unix socket and localhost HTTP are examples of acceptable transports; selecting one requires an implementation decision.
- The detailed household-administration, host, and deployment model is outside branding scope and ultimately belongs in the consolidated Health Hub architecture specification.
- `Claude-foundation.md` section 25 and `Preliminary.md` section 10 explicitly revise an earlier external-consumer-only position: the Hub subscribes to each daemon's MQTT feed for near-real-time new-reading delivery rather than polling or adding webhooks. They reserve REST for on-demand queries, configuration, reports, assignment, and capability discovery. They do not describe MQTT commands or a broader general-purpose coordination protocol.

### Proposed resolution

Define the deployment boundary as follows:

1. Health Hub is a personal or household health-data appliance, not a hospital, clinic, enterprise, or multi-station medical-record system.
2. A normal integrated deployment runs one Hub and its configured daemon services on one physical machine or equivalent single-host environment.
3. Supported daemons remain independently installable and usable without Health Hub; “single appliance” constrains the Hub deployment, not standalone daemon use.
4. The reviewed sources already assign MQTT the daemon-to-Hub near-real-time new-reading push role in an integrated deployment, with the Hub subscribing to daemon-owned raw topics.
5. The reviewed sources assign on-demand queries, configuration, reports, profile assignment, and capability discovery to daemon REST APIs. Whether MQTT should now become a broader coordination backbone is a separate decision for the detailed MQTT review.
6. A standalone daemon remains functional for its core synchronization, durable data, operational status, and PDF responsibilities without Health Hub. Its standalone requirements do not depend on Home Assistant or another external MQTT consumer.
7. Local-only API transports are preferred for the integrated deployment, but the architecture does not hardcode Unix sockets versus localhost HTTP.
8. Distributed Hub nodes, remote daemon registration, multi-Hub coordination, and WAN-exposed daemon APIs are outside current scope rather than declared impossible forever.
9. Device and daemon names in the source documents are examples of the initial integration set. New devices and manufacturers fit the same authority, MQTT, and API boundaries without changing the system architecture.
10. Optional displays, Home Assistant, scripts, and other external MQTT consumers remain optional clients. They consume the Hub's interfaces but do not define the Hub-to-daemon coordination model.

### Destination if approved

The eventual consolidated Health Hub architecture specification. The branding repository should retain only the browser-presentation, daemon-authority, identification, and report boundaries that directly govern branding/interface adoption.

## AR-002: Hub, daemon, driver, and device authority

**Status:** Awaiting owner decision
**Classifications:** Consistent, Duplicate, Outside scope

### Review result

All three sources preserve the same core boundary: a physical device is accessed through its driver and daemon; the daemon owns synchronization, device-specific interpretation, durable measurements, operational status, and reports; the Hub consumes supported daemon interfaces and owns household organization, authorization, cross-device presentation, and browser interaction. Home Assistant and other integrations remain consumers.

The phrase “Hub data store” must not imply that copied or normalized measurements become a second authority. Hub-owned data may include accounts, permissions, preferences, audit records, integration configuration, cached projections, and references to daemon records. A cache must retain source identity and be rebuildable or explicitly classified if it is not.

### Proposed disposition

Adopt the authority chain `physical device -> driver -> daemon -> supported API/event contract -> Hub presentation`. State explicitly that normalization, caching, and aggregation do not transfer measurement authority. Keep daemon configuration and device-specific behavior in the daemon. Put the complete rule in the consolidated architecture; retain its presentation consequences in the interface/report standards.

## AR-003: Person, account, actor, profile, device, and source identity

**Status:** Awaiting owner decision
**Classifications:** Conflict, Stale, Unverified

### Source evidence and conflict

The Foundation and HA addendum often model one physical device as assigned to one profile at a time and preserve a logical person across device replacement. Preliminary later reports differing real daemon models: some readings are unassigned until an explicit assignment, while one O2Ring daemon instance represents one configured wearer. The current interface contracts also separate the person described by a record from the actor entering or changing it.

Those models cannot be collapsed into one universal `device -> profile` rule. A shared thermometer, scale, cuff, or manual entry may require per-record subject selection. Device memory slots are not Hub people. Accounts, people, profiles, actors, devices, daemon instances, transport identifiers, and source records are distinct identities even when a simple installation maps some one-to-one.

### Proposed disposition

Use stable opaque IDs for every identity domain. Model the subject of each measurement independently from the actor and source device. Treat device-level profile assignment as a daemon-reported capability, not a universal invariant. Preserve reassignment history and actor audit data rather than rewriting provenance. Personal names in examples are display labels only and must never form stable identifiers or MQTT uniqueness keys.

## AR-004: Measurement ownership, provenance, timestamps, correction, and retention

**Status:** Awaiting owner decision
**Classifications:** Consistent, Stale, Unverified

### Review result

The sources consistently separate a device-originating measurement time from daemon receipt or download time where hardware permits, and consistently leave long-term device data with the daemon. Preliminary correctly notes that some hardware supplies no trustworthy device clock.

The older two-timestamp model is incomplete for manual entry and later correction. The current contract additionally needs `taken_at` (or the best source event time), `received_at`, and `entered_at`, with time zone/offset, precision, uncertainty, provenance, source-record identity, and correction history where applicable. A missing device time is a known limitation, not permission to fabricate one. Duplicate import and clock correction policies are not defined in the sources.

### Proposed disposition

Require daemons to expose the timestamp semantics and provenance they can actually support. Preserve raw/source values and identifiers alongside normalized display values. Keep corrections append-only or otherwise auditable. Define deduplication and retention per daemon, while the Hub treats projections as non-authoritative. Verify actual schemas, pruning, and correction behavior before fixing a universal data contract.

## AR-005: REST APIs, versioning, authentication, and local transport

**Status:** Needs verification
**Classifications:** Consistent, Unverified, Stale

### Review result

The documents agree that REST remains the supported mechanism for on-demand queries, configuration, reports, assignment, and capability discovery. The Hub API must enforce the same authorization as its UI, while daemon APIs remain usable without the Hub. Localhost HTTP and Unix sockets are examples, not settled transport requirements.

Claims that every daemon currently uses `aiohttp`, `/api/v1`, an unauthenticated `/health`-like capabilities endpoint, and optional shared bearer authentication are dated implementation claims. “Public/user-accessible API” means supported and documented; it must not be read as unauthenticated or exposed beyond the local trust boundary. An unauthenticated capabilities response also needs a defined non-sensitive field set.

### Proposed disposition

Standardize behavior and versioning before standardizing framework or transport. Require least-privilege Hub credentials, bounded timeouts, stable error semantics, pagination where needed, and explicit capability-schema versioning. Keep daemon authentication distinct from Hub user authorization. Verify routes and current authentication in every repository before consolidation.

## AR-006: MQTT coordination, state, topics, and publisher authority

**Status:** Awaiting owner decision
**Classifications:** Consistent, Duplicate, Unverified

### Review result

Foundation section 25, Preliminary sections 10/27/28, and the supplied Claude Code handoff agree: MQTT is a second channel, not a REST replacement. Daemons publish new-reading events through their existing off-by-default feature; the Hub subscribes for near-real-time intake. REST handles queries, configuration, reports, profile assignment, and capabilities. Daemons may publish only their own topics, the Hub only its own topics, and every other client is subscribe-only through broker ACLs.

The sources do not approve MQTT command topics. Their topic names, personal-name segments, JSON shapes, QoS, retained flags, event identity, replay behavior, ordering, duplicate handling, session payloads, and deletion/correction events remain examples or omissions. Retained current state is useful for consumers but cannot replace daemon SQLite history or prove that an event was ingested.

### Proposed disposition

Preserve the REST/event split. Define a machine-stable topic namespace using opaque profile/source IDs and human-readable labels only in payloads. Require event IDs or source-record IDs, schema versions, event time plus publication time, idempotent Hub ingestion, explicit QoS/retain rules, and broker-enforced ACL tests. Reserve command/control unless separately approved. Treat retained messages as current-state projections, never authoritative history.

## AR-007: Home Assistant discovery and independence

**Status:** Needs verification
**Classifications:** Consistent, Duplicate, Unverified

### Review result

The HA addendum largely duplicates Foundation sections 30–39. Both correctly make Home Assistant optional, generate discovery from actual capabilities, preserve stable logical identity across device replacement where appropriate, and separate Hub/device availability from measurement freshness.

Discovery topic formats, identifiers, device/entity grouping, retained cleanup, configuration-change behavior, supported units/device classes, and availability semantics depend on current Home Assistant requirements. Per-sample O2Ring entities are explicitly rejected; useful summaries are acceptable.

### Proposed disposition

Keep a generic normalized MQTT contract independent of Home Assistant and implement discovery as an adapter. Use stable opaque unique IDs, publish only capability-supported entities, and remove obsolete retained discovery records when configuration changes. Verify the exact contract against current official Home Assistant documentation before implementation.

## AR-008: Browser UI, dashboards, displays, sessions, and input

**Status:** Awaiting owner decision
**Classifications:** Consistent, Conflict, Stale

### Review result

Preliminary calls the Web UI primary, while Foundation contains numerous five-inch HDMI, rotation, and night-mode examples. These are compatible if a small local display is one responsive browser client, not a separate UI authority. Current approved interface work broadens this to keyboard, mouse, tablet, and other touch displays with appropriate alternative text and screen-reader support.

Preliminary also says the station has a physical screen for confirmation codes. That is a stronger deployment requirement than merely supporting an optional display and could prevent headless or browser-only deployments. Explicit session initiation is consistent; presence or biometric identity detection is rejected. USB keys are optional examples.

### Proposed disposition

Keep all browser presentation in the Hub and require responsive, keyboard-, mouse-, touch-, and assistive-technology-friendly interaction. Treat exact display size, rotation hardware, and USB keys as deployment options. Decide separately whether a local screen is mandatory for the approved session-confirmation threat model or whether another local trusted channel can satisfy it.

## AR-009: Charts, summaries, notifications, goals, and diagnostic restraint

**Status:** Awaiting owner decision
**Classifications:** Consistent, Unverified

### Review result

The sources consistently limit the Hub to descriptive current/recent views, trends, summaries, and changes over time. They reject diagnosis and clinical interpretation. Device-specific continuous sessions remain distinct from point readings.

Preliminary assigns the Hub a substantial alert engine while daemons already provide Apprise-based device notifications. Ownership, deduplication across daemon and Hub alerts, threshold provenance, escalation, acknowledgment, and missing-data behavior are not defined. User goals and optional thresholds can easily appear clinical if language and defaults are careless.

### Proposed disposition

Keep graphs descriptive, show units, time basis, missing/stale data, and provenance, and do not imply causation or diagnosis. Separate operational alerts from user-configured health-data notifications. Do not ship clinical thresholds as medical advice. Treat goals as explicit personal annotations. Verify daemon notification behavior before defining Hub deduplication.

## AR-010: Daemon-owned PDFs and Hub coordination

**Status:** Awaiting owner decision
**Classifications:** Consistent, Duplicate

### Review result

Foundation, Preliminary, and the approved report contract agree that daemons arbitrate device-specific doctor-facing PDF generation. The Hub requests, displays, and downloads the exact daemon-produced bytes for an authorized person; it must not silently reconstruct, restyle, merge, or become the authority for those reports. A daemon must still generate PDFs through its API without the Hub.

Preliminary permits Hub-created cross-device summaries. These must be clearly different artifacts and must not be presented as daemon clinical reports. The approved branding direction excludes decorative iconography from doctor-facing PDFs.

### Proposed disposition

Retain daemon report authority and define media type, filename, content disposition, authorization, streaming/error behavior, and integrity metadata at the API boundary. Identify the generating daemon and report parameters in Hub presentation. If cross-device summaries are later approved, give them a separate artifact type, provenance, and non-diagnostic label.

## AR-011: Roles, permissions, delegation, recovery, and audit

**Status:** Awaiting owner decision
**Classifications:** Conflict, Unverified, Outside scope

### Review result

Preliminary alone specifies exactly one Security/Health Administrator, separate Hub, User, and System Recovery Administrators, key rules, and no two-person approval. These are consequential security choices rather than examples, but they are not corroborated by the other sources or a threat model. The role names also risk conflating technical authority with access to another person's health data, which Preliminary itself says must remain separate.

The audit principles are sound: record actor, action, time, result, security-sensitive changes, and protect audit history from ordinary administrators. The documents do not settle emergency access, minors/dependents, incapacity, account deletion, delegation expiry, recovery without health-data disclosure, or audit retention.

### Proposed disposition

Define permissions as capabilities and keep actor, subject, technical administration, health-data delegation, and recovery authority orthogonal. Treat the named roles as one policy proposal pending owner review and threat modeling. Require explicit, revocable, persisted delegation and tamper-evident or append-only audit behavior. Decide household recovery and dependent-person cases before fixing role counts.

## AR-012: Backup, restore, unrecoverable data, Samba, and filesystems

**Status:** Awaiting owner decision
**Classifications:** Conflict, Unverified, Outside scope

### Review result

This material appears mainly in Preliminary. Local backup as a default and clear warnings about disk/theft/fire risk are reasonable. However, saying Samba provides convenient authorized access can be read as mandatory even though direct filesystem exposure expands the health-data attack surface and bypasses application-level authorization unless carefully designed.

A consistent backup cannot be assumed from independent live SQLite files. The sources do not fully define database snapshots, encryption keys, credentials, report files, audit logs, integrity verification, restore ordering, schema compatibility, or partial-daemon failure. “Unrecoverable” must distinguish data never captured from data lost after capture.

### Proposed disposition

Make backup capability mandatory but individual transports such as Samba and rclone optional adapters. Define a manifest-based component backup contract using safe SQLite backup/snapshot procedures, encrypted secrets handling, integrity checks, version metadata, and tested restore. Preserve daemon authority after restoration. Do not expose raw health-data directories merely for convenience.

## AR-013: Installation, services, host OS, Python environments, and updates

**Status:** Needs verification
**Classifications:** Consistent, Stale, Unverified, Outside scope

### Review result

Independent systemd services and daemon independence are compatible with the single-host appliance model. Exact Debian/Ubuntu versions, paths, service names, Python tooling, and virtual-environment commands are implementation and packaging choices, not enduring architecture. The Web UI may report update availability while CLI tooling performs updates; that policy is distinct from whether future safe update automation is ever allowed.

The persistence standard now selected for project databases is SQLite with SQLAlchemy 2.0 style and Alembic migrations. That choice applies to each component database, without creating a shared cross-daemon database or moving daemon-owned measurements into the Hub.

### Proposed disposition

Specify lifecycle outcomes—isolated service identity, least-privilege files, deterministic configuration, migrations, backup compatibility, health checks, rollback/recovery, and independent daemon operation—separately from a particular distribution or Python installer. Verify current units and packaging before writing deployment requirements.

## AR-014: Device capabilities, replacement, and manufacturer-neutral expansion

**Status:** Needs verification
**Classifications:** Consistent, Stale, Unverified

### Review result

All sources support capability-driven integration and warn against erasing device-specific behavior. Weight-only scales, O2Ring spot/session separation, differing profile models, unavailable device clocks, and replacement history are useful examples. They are not universal contracts. The original four-device list is stale as a support boundary because BBT, non-contact health thermometers, and future devices must fit the architecture without naming a manufacturer.

Claims about exact daemon capabilities and hardware limitations were reported from an earlier code review but remain dated for this review.

### Proposed disposition

Make capability discovery schema-versioned and additive. Separate logical source, physical device, daemon instance, and measurement capability. Preserve history through replacement while retaining physical provenance. Require unknown-capability tolerance and manufacturer-neutral UI language. Verify each daemon and underlying protocol before marking a behavior guaranteed.

## AR-015: Release scope, deferred work, and implementation constraints

**Status:** Awaiting owner decision
**Classifications:** Conflict, Stale, Unverified

### Review result

Foundation's 20-item “initial release” list includes normalized MQTT output, Home Assistant discovery, a five-inch display, rotation, and night mode. Preliminary adds extensive identity, roles, Samba, alerts, backup, host, update, and audit requirements while explicitly saying it is not an implementation specification. These cannot all be assumed to be one minimal release.

The documents mix four kinds of statement: enduring architecture, product requirement, illustrative design, and observed implementation. This is the main cause of apparent conflict and scope growth.

### Proposed disposition

The consolidated work should label each retained item as invariant, required capability, optional adapter, implementation choice, or deferred investigation. Establish a new release plan only after owner decisions and current code verification. Do not inherit the dated initial-release list wholesale.

## Implementation claim register

These claims are not accepted as current merely because Preliminary section 28 labels them confirmed. Current repository verification is recorded in [`ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md`](ARCHITECTURE_IMPLEMENTATION_VERIFICATION.md); hardware and external-system claims still require their own evidence before consolidation.

| ID | Claim | Review state |
|---|---|---|
| CR-001 | Every supported daemon exposes versioned `/api/v1` routes and `GET /api/v1/capabilities`. | Confirmed in the five current daemon source trees. |
| CR-002 | Every supported daemon implements off-by-default MQTT publish-on-new-reading. | Confirmed in the five current daemon source trees; delivery/replay guarantees remain undefined. |
| CR-003 | All daemon HTTP servers use `aiohttp.web` and optional shared bearer tokens. | Confirmed current implementation; framework-specific and not an architecture requirement. |
| CR-004 | Every daemon uses SQLite for authoritative durable measurement storage. | Confirmed; all five use direct `sqlite3`, with no current SQLAlchemy or Alembic implementation. |
| CR-005 | TrueMetrix and Etekcity support assignment models differing from O2Ring's configured-wearer model. | Confirmed in current schemas, configuration, and endpoints; identity must remain capability-driven. |
| CR-006 | The BP protocol has no device-side clock and its memory slot is not a Hub profile. | Confirmed for the implemented reverse-engineered packet protocol; other models remain unverified. |
| CR-007 | O2Ring live readings and downloaded sessions use distinct tables and semantics. | Confirmed in daemon storage and API source; driver/session-finalization behavior remains for hardware review. |
| CR-008 | Daemons provide notifications and scheduled staleness/range checks. | Scheduled alert code/configuration and units confirmed; live provider behavior not tested. |
| CR-009 | Each daemon generates its own device-specific PDFs. | Confirmed; current on-demand API generation is synchronous rather than a durable asynchronous job. |
| CR-010 | Daemon retention/pruning exists and is covered by `test_prune.py`. | Deferred to a separate storage-policy review; not established by the hardware/protocol pass. |
| CR-011 | Current service units, users, paths, dependencies, and update procedures match the preliminary deployment model. | Unit files, daemon-specific users, paths, and dependencies inspected; installed runtime and update behavior not tested. |
| CR-012 | Current Home Assistant discovery requirements match the proposed topics, retained state, IDs, units, and availability model. | Current official Home Assistant documentation required. |

## Cross-document conclusion

The documents are directionally compatible but are not safe to merge mechanically. Their durable center is the independent-daemon authority model, Hub-owned household presentation and access control, REST for request/response operations, MQTT for near-real-time daemon events and optional normalized consumers, daemon-owned PDFs, capability-driven expansion, and non-diagnostic presentation. Identity policy, role design, local-screen requirements, backup/file access, exact MQTT contracts, and release scope still require explicit decisions. All current-behavior claims require verification before the consolidated architecture can call them facts.
