# DevHardware (iOS 16+)

Real-time hardware, Mach memory, thermal state, Metal GPU, and network interface inspector for iOS developers. Built with SwiftUI and native Darwin/Mach system APIs.

## Features

- **Hardware & Mach Memory**: Inspect physical CPU cores, active Mach task basic info, real-time memory pressure, page allocation, and thermal states.
- **Metal GPU Capabilities**: Direct interrogation via Metal framework (`MTLCreateSystemDefaultDevice`) for GPU feature family support, maximum frame rates, and render limits.
- **Network Interfaces**: Enumerate active interfaces via `getifaddrs` and monitor connection path dynamics in real time with `NWPathMonitor`.
- **Developer Tools**: Built-in memory pressure simulation and diagnostic report generation.
- **Dark Minimalist Interface**: Pure monochromatic slate theme optimized for developer clarity without distraction.
- **Bilingual Support**: Instant runtime switching between English and Vietnamese.

## Architecture

```text
DevHardware/
├── App/
│   └── DevHardwareApp.swift
├── Theme/
│   └── AppTheme.swift
├── Models/
│   └── HardwareModels.swift
├── Services/
│   ├── SystemInspectorService.swift
│   ├── NetworkInspectorService.swift
│   ├── DevToolsService.swift
│   ├── DiagnosticReportService.swift
│   └── LocalizationManager.swift
└── Views/
    ├── Components.swift
    ├── HardwareView.swift
    ├── NetworkView.swift
    ├── DevToolsView.swift
    └── SettingsView.swift
```

## Running Tests

```bash
python tests/test_dev_hardware.py
```

## License
Distributed under the [MIT License](LICENSE).

## Author
**Ace4youblade (VanKhoa)**  
Open-source software developer (born 2012) from Hai Phong, Vietnam.  
GitHub: [@emlavankhoahienma-hue](https://github.com/emlavankhoahienma-hue)
