#!/usr/bin/env python3
"""Read-only hardware inventory prototype for ChaOS Driver Lab.

Reads Linux sysfs metadata only. It does not load/unload drivers, install firmware,
write to devices, or change system configuration.
"""
from __future__ import annotations

import argparse
import json
import platform
from pathlib import Path
from typing import Any


def read_text(path: Path) -> str | None:
    try:
        return path.read_text(encoding="utf-8").strip() or None
    except (OSError, UnicodeError):
        return None


def driver_name(device_path: Path) -> str | None:
    try:
        return (device_path / "driver").resolve(strict=True).name
    except OSError:
        return None


def collect_bus_devices(root: Path, bus: str) -> list[dict[str, Any]]:
    devices_dir = root / "bus" / bus / "devices"
    if not devices_dir.is_dir():
        return []

    records: list[dict[str, Any]] = []
    for device in sorted(devices_dir.iterdir(), key=lambda item: item.name):
        record: dict[str, Any] = {
            "bus": bus,
            "address": device.name,
            "vendor_id": read_text(device / "vendor"),
            "device_id": read_text(device / "device"),
            "class": read_text(device / "class"),
            "modalias": read_text(device / "modalias"),
            "driver": driver_name(device),
        }
        if bus == "usb":
            record.update({
                "manufacturer": read_text(device / "manufacturer"),
                "product": read_text(device / "product"),
                "serial": None,  # Deliberately omit device serial numbers.
            })
        records.append(record)
    return records


def build_report(sysfs: Path) -> dict[str, Any]:
    return {
        "schema_version": 1,
        "tool": "chaos-hw-scan",
        "read_only": True,
        "host": {
            "system": platform.system(),
            "kernel": platform.release(),
            "machine": platform.machine(),
        },
        "devices": (
            collect_bus_devices(sysfs, "pci")
            + collect_bus_devices(sysfs, "usb")
        ),
        "notes": [
            "Inventory only; this report does not determine driver compatibility.",
            "A missing driver field means sysfs did not expose a bound driver.",
            "No device serial numbers are collected.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--sysfs-root",
        type=Path,
        default=Path("/sys"),
        help="sysfs root (default: /sys; useful for isolated tests)",
    )
    parser.add_argument("--output", type=Path, help="write JSON to a file instead of stdout")
    args = parser.parse_args()

    report = build_report(args.sysfs_root)
    rendered = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
