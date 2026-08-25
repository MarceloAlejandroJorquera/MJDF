# Uninstall and Recovery

MJDF v1 is a single executable, but it creates persistent per-user/runtime integration state. Removing the EXE without first restoring route/browser/startup state is not the preferred uninstall procedure.

## Recommended removal

1. Use MJDF to select direct DNS and wait for the final native state to settle.
2. Disable MJDF autostart from the tray.
3. Exit MJDF normally.
4. Confirm Windows DNS is no longer pointed at `127.0.0.1` / `::1`.
5. Only then remove `MJDFv1.exe`.
6. If you want a complete data reset, review and remove `%LOCALAPPDATA%\MJDF` after confirming no rollback information is still needed.

## Do not delete rollback state too early

`dns-session.json` can contain the captured pre-MJDF DNS configuration. Preserve it until the original adapter DNS settings have been restored.

## Startup-gate recovery

The executable contains management switches for startup-gate recovery. Use them only from an elevated console and only when you understand the current route state:

```bat
MJDFv1.exe --disarm-startup-gate
```

This removes MJDF-owned fail-closed startup-gate policy; it does not perform a complete uninstall.

## Manual Windows recovery

If MJDF cannot run, use Windows Settings or an elevated networking shell to restore a known-good DNS configuration. Do not broadly delete unrelated WFP filters, certificates or browser policies.
