# MJ DNS FILTER v1 — First Public Binary Release

MJ DNS FILTER v1 is the first public Windows x64 release of MJDF.

The release is distributed as a **single executable**: `MJDFv1.exe`.

## Highlights

- Local IPv4 + IPv6 DNS filtering through `127.0.0.1` and `::1`.
- Encrypted upstream DNS-over-HTTPS.
- Local encrypted DNS-over-HTTPS endpoint for supported browser integration.
- Live default-browser dashboard with query/source/type statistics.
- Persistent Blacklist, Whitelist and Hiddenlist Rules.
- Exact-domain semantics by default; wildcard matching only when explicitly written.
- Downloadable/refreshable DNS blocklists.
- Native Windows tray control and dashboard sphere using the same DNS routing worker.
- Microsoft inbox BFE/WFP enforcement; no custom release kernel driver required.
- Outbound TCP/UDP 853 guard while attached.
- Hostname-aware WFP enforcement where Windows exposes hostname information.
- Fail-closed startup gate for remembered filtered/autostart operation.
- Windows x64 single-EXE release; the public GitHub repository is intentionally binary-only.

## Requirements

- 64-bit Windows / x86-64.
- Administrator elevation for DNS/WFP/certificate/browser-policy operations.
- Windows Base Filtering Engine / WFP available.
- Port 53 available for the local resolver.
- A default browser for the full dashboard.

No WebView2, Sciter, WDK, TESTSIGNING, Secure Boot change, or HVCI disablement is required for normal v1 operation.

## Download

Release assets should include:

- `MJDFv1.exe`
- `SHA256SUMS.txt`
- `generate-SHA256-MJDFv1.bat`

Place `MJDFv1.exe` in a permanent folder and run it. MJDF requests elevation when required, initializes `%LOCALAPPDATA%\MJDF`, starts its native tray, and opens the dashboard in the Windows default browser.

## Verify the download

Use PowerShell:

```powershell
Get-FileHash .\MJDFv1.exe -Algorithm SHA256
```

Compare the result with `SHA256SUMS.txt` attached to **this same release**.

## Important behavior

Attached/filtered mode routes Windows DNS to `127.0.0.1` and `::1`. The direct selector uses Cloudflare DNS instead. The dashboard sphere and tray selector represent the same native route state.

A plain custom rule such as `example.com` applies only to that exact hostname. Use an explicit wildcard such as `*.example.com` when subdomain matching is intended.

## Security boundary

MJDF does not decrypt arbitrary TLS/QUIC traffic and does not invent a hostname for a hard-coded-IP encrypted flow when Windows does not expose one. Standard outbound TCP/UDP port 853 is blocked while attached, and supported browser DoH policy is managed as part of the local encrypted-DNS route.

See the repository README, `SECURITY.md`, and `docs/SECURITY-MODEL.md` for the full architecture and limitations.

## Distribution model

MJDF v1 is published as a binary-only application. The public repository contains documentation and release metadata, not the application source tree. GitHub-generated source archives for the `v1` tag therefore contain only the public repository contents.
