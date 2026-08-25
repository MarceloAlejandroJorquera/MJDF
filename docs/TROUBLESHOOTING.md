# Troubleshooting

## Where logs are stored

```text
%LOCALAPPDATA%\MJDF\logs
```

Start with the newest log corresponding to the failing run.

## Port 53 already in use

MJDF needs the local DNS listener. Identify the current owner before stopping anything. Do not terminate unrelated system/security/DNS software automatically.

Useful elevated commands:

```powershell
Get-NetTCPConnection -LocalPort 53 -ErrorAction SilentlyContinue
Get-NetUDPEndpoint -LocalPort 53 -ErrorAction SilentlyContinue
```

## Attached state fails

Check:

- local listeners on IPv4 and IPv6;
- local DoH on port 8080;
- BFE service availability;
- enterprise WFP restrictions;
- Windows DNS adapter state;
- local CA trust;
- browser integration diagnostics;
- route error shown in the sphere tooltip.

## Tray green but sphere stale

The v1 route model requires browser presentation to follow authoritative native state automatically. Confirm you are using the final v1 build. Capture the route status and browser console/log evidence if a manual refresh or second tray click is still required.

## Rules disappear after route change

This is release-blocking. Record:

1. which list (black/white/hidden);
2. exact sequence used to add entries;
3. whether ACTION lever or manual editor was used;
4. how quickly detach/attach followed the edit;
5. whether tray or sphere was used;
6. state after process restart;
7. sanitized Rules persistence files/log excerpts.

Do not “fix” a live route transition by replaying stale crash-recovery editor WAL over newer immutable rule generations.

## Stop still shows new rows

Stop is intended to freeze the visible Live table. Filtering and buffering continue. If a Rules action causes rows to appear while stopped, report it as a UI freeze regression.

## Browser DoH problems

Browser policy is separate from Windows adapter DNS. Check the default-browser integration diagnostic. Restarting the affected browser may be required after enterprise-policy changes, particularly for Firefox.

## No Process Explorer/system query visible

Generate a fresh resolution that is not already cached. Remember that not every endpoint causes a new query every time. Windows/application caches and existing connections can suppress new DNS activity.

## Emergency cleanup

Prefer the application's direct route/uninstall/recovery behavior so rollback state is preserved. If manual repair is necessary, keep a copy of `%LOCALAPPDATA%\MJDF\config\dns-session.json` until the original adapter DNS configuration has been restored.

The management executable also contains startup-gate management switches used for recovery/development. These should be used only with a clear understanding of the current route state.
