import Foundation
import UIKit

enum DiagnosticReportService {
    static func markdown(hardware: HardwareSnapshot, interfaces: [NetworkInterface], path: PathSnapshot) -> String {
        let device = UIDevice.current
        let memory = hardware.memory
        let cpu = hardware.cpu
        let gpu = hardware.gpu
        let display = hardware.display

        var rows: [(String, String)] = [
            ("Device", SystemInspectorService.machineIdentifier),
            ("System", device.systemName + " " + device.systemVersion),
            ("RAM total", String(format: "%.2f GB", memory.totalGB)),
            ("RAM active", String(format: "%.2f GB", memory.activeGB)),
            ("RAM wired", String(format: "%.2f GB", memory.wiredGB)),
            ("RAM free", String(format: "%.2f GB", memory.freeGB)),
            ("App memory", String(format: "%.1f MB", memory.appUsedMB)),
            ("CPU cores", "\(cpu.activeProcessorCount) active / \(cpu.processorCount)"),
            ("Thermal state", cpu.thermal.titleKey),
            ("Uptime", String(format: "%.0f s", cpu.uptime)),
            ("Low Power Mode", cpu.lowPowerMode ? "on" : "off"),
            ("GPU", gpu.name),
            ("GPU family", gpu.family),
            ("GPU working set", String(format: "%.0f MB", gpu.maxWorkingSetMB)),
            ("Raytracing", gpu.supportsRaytracing ? "yes" : "no"),
            ("Display", "\(display.nativeWidth)x\(display.nativeHeight) @\(display.scale)x"),
            ("Max refresh rate", "\(display.maxFramesPerSecond) Hz"),
            ("Network", path.isConnected ? "connected" : "disconnected")
        ]
        rows += interfaces.map { ($0.name, $0.address) }

        let table = rows.map { "| \($0.0) | \($0.1) |" }.joined(separator: "\n")
        return "## DevHardware Diagnostic Report\n\n| Property | Value |\n| --- | --- |\n" + table + "\n"
    }
}
