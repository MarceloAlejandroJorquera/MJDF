# Changelog

All notable public changes to MJ DNS FILTER are documented here.

The project uses the public release name **MJ DNS FILTER v1 / MJDFv1**. Internal development build-fix numbering is intentionally omitted from the public changelog.

## v1 — 2026-08-24

First public binary release.

### DNS and routing
- Single-EXE Windows x64 release.
- Local IPv4/IPv6 DNS filtering on `127.0.0.1` and `::1`.
- Direct Cloudflare DNS selector for detached operation.
- Dashboard sphere and tray DNS selector normalized to the same native route worker.
- Persisted filtered/direct route preference.
- Verified Windows DNS adapter transitions with IPv4 and IPv6 handling.
- Encrypted local DNS registration and certificate handling.

### Enforcement
- Microsoft inbox BFE/WFP is the normal enforcement plane.
- No release dependency on a custom kernel driver, WDK, TESTSIGNING, Secure Boot changes, or HVCI exceptions.
- Attach-scoped hard blocking of outbound TCP/UDP port 853.
- Hostname-aware WFP policy where Windows supplies peer/effective-name data.
- Read-back/health verification before healthy attached state.
- Whitelist-aware policy rebuild behavior.

### Startup/shutdown safety
- Fail-closed startup gate for remembered filtered/autostart operation.
- Boot-time/persistent WFP handoff with loopback and narrowly scoped network bootstrap exceptions.
- Shutdown-safe handling designed not to raise modal errors while Windows services are disappearing.
- Startup gate handoff must be verified before attached/green publication.

### Visibility
- Local resolver query logging.
- Windows-native lower-level DNS/name-resolution observations.
- HOST/RES provenance display with effective policy projection.
- Process/source normalization where attribution evidence is available.
- Grouped/coalescent Live activity with detail dialogs.

### Dashboard
- Default-browser dashboard served on loopback.
- Live!, Stats, Lists and Rules pages.
- Stop/Play visible-table freeze.
- Query search/filtering and detailed event modals.
- Source/type statistics and drill-down views.
- Favicons/site-icon discovery with local caching and safety checks.
- Self-healing route-state polling so browser presentation follows native route state.

### Rules
- Durable backend-owned Rules state.
- Blacklist, Whitelist and Hiddenlist.
- Live ACTION levers for quick block/allow changes.
- Explicit exact-domain semantics for plain hostnames.
- Wildcard behavior only when explicitly written.
- Whitelist precedence over custom blacklist policy.
- Rules persistence designed to be independent from attach/detach route transitions.

### Lists
- Local blocklist support.
- Remote blocklist download support.
- Scheduled auto-refresh for configured remote lists.

### Build/security
- Pinned Rust `1.97.1-x86_64-pc-windows-msvc` toolchain.
- Locked dependency graph.
- cargo-deny RustSec/source checks integrated in the Windows release build.
- Release PE icon verification.
- Exactly one runtime artifact in `dist`: `MJDFv1.exe`.
