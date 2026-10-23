import Foundation

struct MemorySnapshot {
    let appUsedMB: Double
    let activeGB: Double
    let wiredGB: Double
    let freeGB: Double
    let totalGB: Double

    func fraction(of gigabytes: Double) -> Double {
        totalGB > 0 ? min(gigabytes / totalGB, 1) : 0
    }
}

enum ThermalLevel {
    case nominal, fair, serious, critical

    init(_ state: ProcessInfo.ThermalState) {
        switch state {
        case .nominal: self = .nominal
        case .fair: self = .fair
        case .serious: self = .serious
        case .critical: self = .critical
        @unknown default: self = .critical
        }
    }

    var titleKey: String {
        switch self {
        case .nominal: return "nominal"
        case .fair: return "fair"
        case .serious: return "serious"
        case .critical: return "critical"
        }
    }

    var fraction: Double {
        switch self {
        case .nominal: return 0.25
        case .fair: return 0.5
        case .serious: return 0.75
        case .critical: return 1
        }
    }
}

struct CPUInfo {
    let processorCount: Int
    let activeProcessorCount: Int
    let thermal: ThermalLevel
    let uptime: TimeInterval
    let lowPowerMode: Bool
}

struct GPUInfo {
    let name: String
    let family: String
    let maxWorkingSetMB: Double
    let supportsRaytracing: Bool
}

struct DisplayInfo {
    let nativeWidth: Int
    let nativeHeight: Int
    let scale: Int
    let maxFramesPerSecond: Int

    var isProMotion: Bool { maxFramesPerSecond > 60 }
}

struct HardwareSnapshot {
    let memory: MemorySnapshot
    let cpu: CPUInfo
    let gpu: GPUInfo
    let display: DisplayInfo
}

enum InterfaceKind {
    case wifi, cellular, vpn, loopback, other

    init(name: String) {
        if name == "en0" {
            self = .wifi
        } else if name.hasPrefix("pdp_ip") {
            self = .cellular
        } else if name.hasPrefix("utun") {
            self = .vpn
        } else if name.hasPrefix("lo") {
            self = .loopback
        } else {
            self = .other
        }
    }

    var titleKey: String {
        switch self {
        case .wifi: return "if_wifi"
        case .cellular: return "if_cellular"
        case .vpn: return "if_vpn"
        case .loopback: return "if_loopback"
        case .other: return "if_other"
        }
    }

    var symbol: String {
        switch self {
        case .wifi: return "wifi"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .vpn: return "lock.shield"
        case .loopback: return "arrow.triangle.2.circlepath"
        case .other: return "point.3.connected.trianglepath.dotted"
        }
    }
}

struct NetworkInterface: Identifiable {
    let name: String
    let address: String
    let isIPv6: Bool

    var id: String { name + "-" + address }
    var kind: InterfaceKind { InterfaceKind(name: name) }
}

struct PathSnapshot {
    let isConnected: Bool
    let typeKey: String
    let isExpensive: Bool
}
