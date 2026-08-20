# Health Hub daemon implementation verification

## Purpose

This is a read-only verification of implementation claims recorded during the cross-document architecture review. It describes current repository behavior; it does not approve that behavior as the final architecture. The protected Health Hub source documents were not changed.

## Snapshot

The review used each repository's fetched `origin/main` on 2026-08-20. The first four local checkouts were one Docker-removal commit behind, but those commits do not change daemon source, configuration, API, MQTT, report, storage, or systemd files.

| Daemon | Reviewed `origin/main` |
|---|---|
| TRUE METRIX | `6a34836223a13ea9c8ad0b24311fd5e82a073656` |
| Viatom O2Ring | `b9b7c4aab6362cc375fc85e57cc6a93d6dfa0648` |
| Etekcity scale | `641f059831256f3ee8655ba126565732c635ad7b` |
| Etekcity blood pressure | `fe1b4c335c6e9143e3685ea84ce52af0e7464a42` |
| Health thermometer | `547d36af1fd55531fa4994e9a4aec2c5a81c3c4f` |

This verification covers repository source and configuration. It does not claim installed-service, live-broker, hardware, or network validation.

## Verified common behavior

### REST API

All five daemons:

- depend on `aiohttp` and implement their API with `aiohttp.web`;
- place routes under `/api/v1/`;
- expose unauthenticated `GET /api/v1/health` and `GET /api/v1/capabilities`;
- expose `GET /api/v1/latest` and `GET /api/v1/report`;
- default the API to disabled and, when configured, to `127.0.0.1:8080`;
- optionally require one configured bearer token on routes other than health and capabilities;
- generate PDF or CSV reports in the daemon and return the resulting bytes from the report endpoint.

The API is supported local HTTP, not a Unix socket in the current implementations. The shared bearer token is daemon-level authentication, not Hub user authorization or per-client scope.

Route differences are intentional:

- TRUE METRIX exposes `GET` and `POST /api/v1/assign-device` because its configured relationship is meter-to-profile.
- Scale, blood-pressure, and health-thermometer daemons expose `GET` and `POST /api/v1/assign-profile` for per-reading tagging.
- O2Ring exposes `/api/v1/sessions` and `/api/v1/session-records` and has no assignment endpoint.

### Storage

All five daemons use Python's direct `sqlite3` API and component-owned SQLite files. None currently declares SQLAlchemy or Alembic, and none contains an Alembic revision tree.

This confirms SQLite and separate daemon ownership but identifies an implementation gap against the newly approved project persistence contract: SQLAlchemy 2.0-style models and Alembic migrations remain future work. Existing `CREATE TABLE IF NOT EXISTS` and ad hoc schema adjustment code must not be described as Alembic-managed migrations.

O2Ring has separate `live_readings`, `sessions`, and `session_records` tables with foreign-key enforcement and supporting indexes. The other reviewed daemons use one primary readings or measurements table, with their own source-specific columns and assignment behavior.

### MQTT

All five daemons implement optional publish-on-new-reading MQTT output:

- disabled by default;
- configured per daemon with broker, topic prefix, QoS, and retained-message settings;
- default QoS `0` and retained state enabled;
- published beneath `<daemon topic prefix>/<device identifier>/state`;
- attempted after durable local insertion, with broker failure logged rather than blocking or undoing local storage.

The implementations publish reading state only. No reviewed daemon implements MQTT command handling. This supports the documented split: MQTT supplies near-real-time reading events while REST remains responsible for query, configuration, report, assignment, and capability operations.

The current MQTT payload/topic contracts remain daemon-specific. Code inspection does not establish a shared event ID, schema version, replay contract, correction/deletion event, acknowledgement, or common delivery guarantee. Retained QoS-0 state is therefore a convenience projection, not durable transport or authoritative history.

### Reports

All five daemons contain ReportLab PDF generation, CSV generation, a CLI report entry point, and an on-demand `/api/v1/report` route. The four BLE daemons include weekly scheduled-report service/timer units; TRUE METRIX exposes report generation but does not contain the same weekly report timer in the reviewed tree.

Current report API generation is synchronous within the request and writes a temporary output before reading it into the HTTP response. It is not the asynchronous, restart-safe, bounded report-job model approved in the interface/report contract. Daemon report authority is implemented, but the durable job contract remains future implementation work.

### Configuration and services

All five use INI configuration and ship separate systemd units for the acquisition daemon and HTTP API. Each unit runs under a daemon-specific user and group. BLE services declare Bluetooth ordering/wants; TRUE METRIX uses its USB/HID-specific service arrangement.

All five ship scheduled alert checks. O2Ring schedules checks every 15 minutes; the other reviewed daemons use hourly timers. Scheduled reports and alerts are implementation features, not proof that notification policy, deduplication, or clinical thresholds have been approved for the Hub.

## Per-daemon identity and timestamp findings

| Daemon | Current subject/profile model | Current time model |
|---|---|---|
| TRUE METRIX | Meter IDs resolve to configured or dynamic profiles through an assignment store; the database reading is not rewritten into a universal Hub identity model. | Preserves meter `device_time`; ingestion/synchronization metadata exists separately. |
| O2Ring | No per-reading assignment endpoint; one daemon/configuration context represents its wearer while physical addresses remain source identity. | Live `recorded_at` is separate from session `start_time` and download/session metadata. |
| Etekcity scale | Reading has a nullable profile and may be tagged after capture. | Arrival-oriented `recorded_at`; device capabilities must be consulted before assuming device time. |
| Etekcity blood pressure | Reading has a nullable profile; the cuff's user slot remains separate from the Hub profile. | Arrival-oriented `recorded_at`; the claimed lack of a device clock still requires driver/protocol verification. |
| Health thermometer | Reading has a nullable profile and may be tagged after capture. | Stores `recorded_at` and a nullable `measured_at`, exposing the distinction through capabilities. |

The implementation evidence confirms that one universal device-to-profile rule would be wrong. The Hub must consume each daemon's declared model and still maintain its own distinct person, actor, source, and authorization identities.

## Claim-register disposition

| Claim | Result |
|---|---|
| Versioned API and capabilities endpoint | Confirmed in all five current daemon source trees. |
| Off-by-default MQTT publish on new reading | Confirmed in all five current daemon source trees. |
| `aiohttp.web` and optional shared bearer token | Confirmed as current implementation, not required architecture. |
| SQLite as daemon-owned durable storage | Confirmed; SQLAlchemy/Alembic are not yet implemented. |
| Different assignment/profile models | Confirmed; precise hardware meaning remains device-specific. |
| O2Ring split live/session storage | Confirmed. |
| Daemon alert checks | Confirmed as scheduled source/config features; live delivery was not tested. |
| Daemon PDF generation | Confirmed; durable asynchronous report jobs are not implemented. |
| Retention/pruning policy | Not completed in this pass. |
| Hardware/protocol limitations | Not completed in this pass. |
| Installed systemd behavior | Unit files inspected; live installation/runtime behavior not tested. |
| Home Assistant discovery compatibility | Requires current official Home Assistant documentation and Hub implementation review. |

## Architecture versus implementation

The following are verified current behavior:

- independent daemon-owned SQLite data;
- local versioned REST APIs and capability documents;
- optional daemon-to-broker publish-on-reading MQTT;
- daemon-owned PDF/CSV generation;
- separate daemon and API systemd services;
- capability-specific identity and timestamp semantics.

The following remain desired architecture or migration work:

- SQLAlchemy 2.0-style persistence and Alembic revisions;
- durable asynchronous report jobs;
- a finalized common MQTT envelope, delivery, replay, correction, and topic contract;
- Hub-issued scoped authorization mapped safely to daemon credentials;
- complete backup/restore, audit, retention, and migration behavior;
- a consolidated capability schema with explicit schema compatibility rules.

## Next verification boundary

The next review should inspect the daemon/driver code for hardware and protocol limits, particularly device-clock availability, physical memory slots, acquisition completeness, pairing/discovery behavior, O2Ring session finalization, and retention/pruning. Those conclusions must remain separate from statements inferred only from API descriptions.
