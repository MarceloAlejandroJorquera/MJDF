# MJDF v1 Binary Release Checklist

This checklist is for validating the already-built public `MJDFv1.exe` before publishing it. The public repository does not contain the application source/build tree.

## Binary identity

- [ ] Final artifact is named exactly `MJDFv1.exe`.
- [ ] File launches on the intended Windows x64 test system.
- [ ] Application icon/version metadata are correct.
- [ ] No companion runtime DLL/source/build files are required for normal launch.

## Clean-machine first run

- [ ] UAC elevation works.
- [ ] Tray appears.
- [ ] Dashboard opens in the default browser.
- [ ] `%LOCALAPPDATA%\MJDF` initializes.
- [ ] Local certificate creation/trust works.
- [ ] IPv4 and IPv6 DNS operation works.
- [ ] Local DoH works.

## Routing

- [ ] Tray direct -> filtered works.
- [ ] Tray filtered -> direct works.
- [ ] Sphere direct -> filtered works.
- [ ] Sphere filtered -> direct works.
- [ ] Mixed tray/sphere transitions settle without browser refresh or a second tray click.
- [ ] Sphere/tray end in the same state.
- [ ] Remembered route preference survives restart.

## Enforcement / Rules

- [ ] WFP attach health is verified.
- [ ] TCP/UDP 853 guard behaves as documented while attached.
- [ ] Clear Whitelist; add multiple domains; immediate detach/attach preserves all entries.
- [ ] Repeat with Blacklist and Hidden list.
- [ ] Repeat using ACTION levers and manual editor.
- [ ] Restart/reboot preserves Rules.
- [ ] Plain `example.com` is exact-only.
- [ ] `*.example.com` is required for explicit subdomain matching.

## Dashboard

- [ ] Stop freezes the visible Live table.
- [ ] ACTION levers while stopped do not visually unfreeze it.
- [ ] Play reveals buffered activity.
- [ ] HOST/RES details use the documented effective-policy presentation.
- [ ] Dashboard remains responsive during route changes.

## Startup / shutdown

- [ ] Remembered filtered/autostart boot settles correctly.
- [ ] Remembered direct mode starts direct.
- [ ] Windows shutdown produces no MJDF modal error.
- [ ] Tray Exit leaves the documented safe DNS state.

## Repository hygiene

- [ ] Public branch contains **no application source code**.
- [ ] No `src`, Cargo manifests, build scripts, private development files, runtime Rules, logs, or certificates are present.
- [ ] `MJDFv1.exe` is **not committed to `main`**.
- [ ] README/LICENSE/SECURITY/PRIVACY reviewed.

## Release checksums

Run the checksum generator against the final binary:

```bat
generate-SHA256-MJDFv1.bat "C:\path\to\MJDFv1.exe"
```

Verify:

```bat
verify-SHA256-MJDFv1.bat SHA256SUMS.txt
```

## GitHub Release `v1` assets

- [ ] `MJDFv1.exe`
- [ ] `SHA256SUMS.txt`
- [ ] `generate-SHA256-MJDFv1.bat`
- [ ] `verify-SHA256-MJDFv1.bat`
- [ ] Release body from `RELEASE_NOTES_v1.md`
- [ ] Mark as Latest
- [ ] Do not mark as Pre-release
