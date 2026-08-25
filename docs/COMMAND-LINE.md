# Command-Line Reference

Most users should launch `MJDFv1.exe` normally and use the tray/dashboard. These switches exist for development, automation or recovery.

| Switch | Purpose |
| --- | --- |
| `--config <path>` | Use an explicit configuration path |
| `--headless` | Run without the normal desktop/dashboard host |
| `--hidden` | Start the desktop host without opening the browser immediately |
| `--install-cert` | Generate/install the MJDF local certificate trust |
| `--arm-startup-gate` | Arm MJDF-owned fail-closed WFP startup gate |
| `--disarm-startup-gate` | Remove MJDF-owned startup gate |
| `--install-service` | Legacy/development service-management path |
| `--uninstall-service` | Legacy/development service-management path |

`--autostart` and `--elevated-session` are host-internal launch markers used by MJDF's native startup/elevation flow and are not normal end-user configuration switches.

Management operations require elevation where Windows policy requires it.
