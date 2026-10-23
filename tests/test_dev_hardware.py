import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SWIFT_FILES = sorted((ROOT / "DevHardware").rglob("*.swift"))
TEXT_FILES = SWIFT_FILES + [ROOT / "generate_pbxproj.py", ROOT / "DevHardware" / "Info.plist",
                            ROOT / ".github" / "workflows" / "ios-build.yml", ROOT / "tests" / "test_dev_hardware.py"]
EMOJI = re.compile("[\U0001F000-\U0001FAFF\u2600-\u27BF\u2B50\u2B55\uFE0F\u200D]")
STRING = re.compile(r'"(?:\\.|[^"\\\n])*"')
COMMENT = re.compile(r"//[^\n]*")
PAIRS = {")": "(", "]": "[", "}": "{"}


def strip_literals(source: str) -> str:
    return STRING.sub('""', COMMENT.sub("", STRING.sub('""', source)))


class DevHardwareTests(unittest.TestCase):
    def test_sources_exist(self):
        names = {p.name for p in SWIFT_FILES}
        for required in ("DevHardwareApp.swift", "AppTheme.swift", "HardwareModels.swift",
                         "SystemInspectorService.swift", "NetworkInspectorService.swift",
                         "LocalizationManager.swift", "HardwareView.swift", "NetworkView.swift",
                         "DevToolsView.swift", "SettingsView.swift"):
            self.assertIn(required, names)

    def test_brackets_balanced(self):
        for path in SWIFT_FILES:
            stack = []
            for char in strip_literals(path.read_text(encoding="utf-8")):
                if char in "([{":
                    stack.append(char)
                elif char in PAIRS:
                    self.assertTrue(stack and stack.pop() == PAIRS[char], f"unbalanced in {path.name}")
            self.assertFalse(stack, f"unclosed bracket in {path.name}")

    def test_no_emoji(self):
        for path in TEXT_FILES:
            self.assertIsNone(EMOJI.search(path.read_text(encoding="utf-8")), f"emoji in {path.name}")

    def test_modules_connected(self):
        sources = {p: p.read_text(encoding="utf-8") for p in SWIFT_FILES}
        combined = "\n".join(sources.values())
        for path, text in sources.items():
            for name in re.findall(r"^\s*(?:private |final )*(?:struct|class|enum)\s+(\w+)", text, re.M):
                if name == "DevHardwareApp":
                    continue
                uses = len(re.findall(rf"\b{name}\b", combined))
                self.assertGreater(uses, 1, f"{name} in {path.name} is never used")

    def test_project_lists_all_sources(self):
        pbx = (ROOT / "DevHardware.xcodeproj" / "project.pbxproj").read_text(encoding="utf-8")
        for path in SWIFT_FILES:
            self.assertIn(f"{path.name} in Sources", pbx)
        for setting in ("IPHONEOS_DEPLOYMENT_TARGET = 16.0", "SDKROOT = iphoneos", "ARCHS = arm64",
                        'TARGETED_DEVICE_FAMILY = "1,2"'):
            self.assertIn(setting, pbx)

    def test_info_plist_keys(self):
        plist = (ROOT / "DevHardware" / "Info.plist").read_text(encoding="utf-8")
        for fragment in ("<key>CFBundleSupportedPlatforms</key>", "<string>iPhoneOS</string>",
                         "<key>UIDeviceFamily</key>", "<integer>1</integer>", "<integer>2</integer>",
                         "<key>UIRequiredDeviceCapabilities</key>", "<string>arm64</string>",
                         "<key>LSRequiresIPhoneOS</key>\n\t<true/>"):
            self.assertIn(fragment, plist.replace("\r\n", "\n"))

    def test_real_system_apis_used(self):
        system = (ROOT / "DevHardware" / "Services" / "SystemInspectorService.swift").read_text(encoding="utf-8")
        network = (ROOT / "DevHardware" / "Services" / "NetworkInspectorService.swift").read_text(encoding="utf-8")
        for api in ("task_info", "MACH_TASK_BASIC_INFO", "host_statistics64", "thermalState",
                    "MTLCreateSystemDefaultDevice", "supportsFamily", "maximumFramesPerSecond"):
            self.assertIn(api, system)
        for api in ("getifaddrs", "NWPathMonitor"):
            self.assertIn(api, network)


if __name__ == "__main__":
    unittest.main()
