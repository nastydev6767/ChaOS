import tempfile
import unittest
from pathlib import Path

from chaos_hw_scan import build_report


class HardwareScanTests(unittest.TestCase):
    def test_collects_pci_metadata_without_serials(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            device = root / "bus/pci/devices/0000:00:01.0"
            device.mkdir(parents=True)
            (device / "vendor").write_text("0x1234")
            (device / "device").write_text("0xabcd")
            (device / "class").write_text("0x030000")
            (device / "modalias").write_text("pci:v00001234d0000ABCD")
            report = build_report(root)

            self.assertTrue(report["read_only"])
            self.assertEqual(len(report["devices"]), 1)
            self.assertEqual(report["devices"][0]["vendor_id"], "0x1234")
            self.assertIsNone(report["devices"][0]["driver"])
            self.assertNotIn("serial", report["devices"][0])

    def test_missing_sysfs_bus_returns_empty_inventory(self):
        with tempfile.TemporaryDirectory() as temporary:
            report = build_report(Path(temporary))
            self.assertEqual(report["devices"], [])


if __name__ == "__main__":
    unittest.main()
