# Installation

MJ DNS FILTER v1 is intentionally a single-EXE release.

## Install / first launch

1. Download `MJDFv1.exe` and `SHA256SUMS.txt` from the same GitHub Release.
2. Verify SHA-256.
3. Move `MJDFv1.exe` to a permanent folder.
4. Run it and accept UAC.
5. Confirm the tray appears and the loopback dashboard opens.
6. Confirm route status before relying on filtering.

MJDF initializes mutable state under `%LOCALAPPDATA%\MJDF`.

## Firewall review

The shipped config binds IPv4 DNS to `0.0.0.0:53` and IPv4 DoH to `0.0.0.0:8080`. Windows uses the loopback addresses for the desktop filtering route, but wildcard binds can be reachable from other interfaces if firewall rules permit them. Restrict inbound 53/8080 when remote resolver access is not intended.

## Autostart

Use the tray's autostart option. In filtered mode, orderly shutdown can arm the next-boot fail-closed gate so ordinary non-loopback egress stays closed until MJDF's runtime plane is ready.

## Updating

1. Switch to direct DNS or exit MJDF cleanly.
2. Keep `%LOCALAPPDATA%\MJDF` intact.
3. Replace the executable with the new verified release.
4. Start MJDF and verify route/Rules state.
