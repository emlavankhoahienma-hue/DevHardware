import SwiftUI

struct HardwareView: View {
    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var system: SystemInspectorService

    private static let uptimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 3
        return formatter
    }()

    var body: some View {
        let snap = system.snapshot
        ScreenScaffold(title: loc.t("tab_hardware")) {
            memoryCard(snap.memory)
            cpuCard(snap.cpu)
            thermalCard(snap.cpu.thermal)
            gpuCard(snap.gpu)
            displayCard(snap.display)
        }
        .onAppear { system.start() }
    }

    private func memoryCard(_ memory: MemorySnapshot) -> some View {
        CardView(title: loc.t("memory"), symbol: "memorychip") {
            MetricRow(label: loc.t("app_ram"), value: String(format: "%.1f MB", memory.appUsedMB))
            MeterBar(label: loc.t("active"), value: gigabytes(memory.activeGB), fraction: memory.fraction(of: memory.activeGB))
            MeterBar(label: loc.t("wired"), value: gigabytes(memory.wiredGB), fraction: memory.fraction(of: memory.wiredGB))
            MeterBar(label: loc.t("free"), value: gigabytes(memory.freeGB), fraction: memory.fraction(of: memory.freeGB))
            MetricRow(label: loc.t("total"), value: gigabytes(memory.totalGB))
        }
    }

    private func cpuCard(_ cpu: CPUInfo) -> some View {
        CardView(title: loc.t("cpu"), symbol: "cpu") {
            MeterBar(
                label: loc.t("active_cores"),
                value: "\(cpu.activeProcessorCount) / \(cpu.processorCount)",
                fraction: Double(cpu.activeProcessorCount) / Double(max(cpu.processorCount, 1))
            )
            MetricRow(label: loc.t("uptime"), value: HardwareView.uptimeFormatter.string(from: cpu.uptime) ?? "-")
            MetricRow(label: loc.t("low_power"), value: loc.t(cpu.lowPowerMode ? "on" : "off"))
        }
    }

    private func thermalCard(_ thermal: ThermalLevel) -> some View {
        CardView(title: loc.t("thermal"), symbol: "thermometer.medium") {
            MeterBar(label: loc.t(thermal.titleKey), value: "", fraction: thermal.fraction)
        }
    }

    private func gpuCard(_ gpu: GPUInfo) -> some View {
        CardView(title: loc.t("gpu"), symbol: "square.stack.3d.up") {
            MetricRow(label: loc.t("gpu_name"), value: gpu.name)
            MetricRow(label: loc.t("gpu_family"), value: gpu.family)
            MetricRow(label: loc.t("gpu_memory"), value: String(format: "%.0f MB", gpu.maxWorkingSetMB))
            MetricRow(label: loc.t("raytracing"), value: loc.t(gpu.supportsRaytracing ? "supported" : "unsupported"))
        }
    }

    private func displayCard(_ display: DisplayInfo) -> some View {
        CardView(title: loc.t("display"), symbol: "iphone") {
            MetricRow(label: loc.t("resolution"), value: "\(display.nativeWidth) x \(display.nativeHeight)")
            MetricRow(label: loc.t("scale"), value: "@\(display.scale)x")
            MetricRow(
                label: loc.t("refresh"),
                value: "\(display.maxFramesPerSecond) Hz" + (display.isProMotion ? " " + loc.t("promotion") : "")
            )
        }
    }

    private func gigabytes(_ value: Double) -> String {
        String(format: "%.2f GB", value)
    }
}
