# Roadmap

The v1 release establishes the Windows single-EXE baseline. Future work should preserve that baseline unless a major-version architecture change explicitly replaces it.

## High-priority post-v1 areas

- additional Windows DNS/name-resolution attribution coverage where documented APIs expose reliable evidence;
- stronger diagnostics for flows where WFP lacks a hostname;
- expanded browser encrypted-DNS compatibility testing;
- automated regression tests for Rules persistence and route transitions;
- Windows VM integration tests for attach/detach, reboot, autostart and fail-closed handoff;
- blocklist format validation and source-integrity metadata;
- optional export/import of sanitized configuration and Rules;
- improved accessibility and keyboard navigation in the dashboard;
- release signing / publisher identity when signing infrastructure is available.

## Architectural non-goals for v1.x

- disabling Secure Boot or HVCI as a normal requirement;
- relying on TESTSIGNING;
- claiming arbitrary TLS/QUIC hostname recovery without decryption/instrumentation;
- letting the browser UI become the authority for privileged route state.
