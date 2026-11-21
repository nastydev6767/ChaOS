# ChaOS Driver Lab — hardware inventory prototype

This is the first executable ChaOS component. It collects a **read-only** inventory
of PCI and USB devices from Linux sysfs so a future compatibility database can match
hardware IDs to documented Linux driver and firmware support.

## Requirements

- Linux (including Bazzite) with Python 3.10+
- No third-party Python packages
- No root privileges required for ordinary sysfs metadata

## Run

From this directory:

```bash
python3 chaos-hw-scan.py
python3 chaos-hw-scan.py --output hardware-report.json
```

The JSON includes PCI/USB vendor and device IDs, kernel modaliases, and the currently
bound driver when exposed by sysfs. USB serial numbers are intentionally excluded.

## Safety and scope

- The scanner does not install, remove, load, or unload drivers.
- It does not write to sysfs, alter firmware, or change boot configuration.
- It does not claim that a device is compatible based on its ID alone.
- A future compatibility database must cite upstream driver documentation and record
  tested kernel/device versions. Unknown must remain unknown, not be guessed.

## Next steps

1. Add fixture-based unit tests for sysfs parsing.
2. Add a versioned compatibility database with source URLs and test evidence.
3. Add diagnostics for missing firmware and unbound devices without attempting repairs.
4. Integrate the report into a ChaOS UI only after the data model stabilizes.
