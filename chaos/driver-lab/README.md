# ChaOS Driver Lab — hardware inventory prototype

First executable ChaOS component: a **read-only** PCI/USB inventory from Linux sysfs.

## Requirements
- Linux (including Bazzite), Python 3.10+
- No third-party packages or root privileges for ordinary sysfs metadata

## Run
```bash
python3 chaos_hw_scan.py
python3 chaos_hw_scan.py --output hardware-report.json
```

Reports vendor/device IDs, modaliases, and bound driver names where exposed. USB serial
numbers are deliberately excluded.

## Safety and scope
- Does not install, remove, load, or unload drivers.
- Does not write to sysfs, alter firmware, or change boot configuration.
- Does not infer compatibility from an ID alone.
- Future compatibility records must cite upstream documentation and tested versions.

## Next steps
1. Add fixture-based unit tests.
2. Add a versioned compatibility database with source links and test evidence.
3. Add read-only diagnostics for missing firmware and unbound devices.
4. Integrate with the ChaOS UI after the data model stabilizes.
