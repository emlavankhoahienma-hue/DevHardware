import Foundation
import Darwin
import Metal
import UIKit

final class SystemInspectorService: ObservableObject {
    @Published private(set) var snapshot: HardwareSnapshot
    private var timer: Timer?

    private static let gpu = readGPU()
    private static let display = readDisplay()

    init() {
        snapshot = SystemInspectorService.capture()
    }

    func start() {
        guard timer == nil else { return }
        snapshot = SystemInspectorService.capture()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.snapshot = SystemInspectorService.capture()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    static var machineIdentifier: String {
        var info = utsname()
        uname(&info)
        let size = MemoryLayout.size(ofValue: info.machine)
        return withUnsafePointer(to: &info.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: size) { String(cString: $0) }
        }
    }

    private static func capture() -> HardwareSnapshot {
        HardwareSnapshot(memory: readMemory(), cpu: readCPU(), gpu: gpu, display: display)
    }

    private static func readMemory() -> MemorySnapshot {
        let gigabyte = 1_073_741_824.0
        let total = Double(ProcessInfo.processInfo.physicalMemory) / gigabyte

        var taskInfo = mach_task_basic_info()
        var taskCount = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
        let taskResult = withUnsafeMutablePointer(to: &taskInfo) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(taskCount)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &taskCount)
            }
        }
        let appUsed = taskResult == KERN_SUCCESS ? Double(taskInfo.resident_size) / 1_048_576 : 0

        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)
        var vmStats = vm_statistics64()
        var vmCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let vmResult = withUnsafeMutablePointer(to: &vmStats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(vmCount)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &vmCount)
            }
        }
        guard vmResult == KERN_SUCCESS else {
            return MemorySnapshot(appUsedMB: appUsed, activeGB: 0, wiredGB: 0, freeGB: 0, totalGB: total)
        }
        let page = Double(pageSize)
        return MemorySnapshot(
            appUsedMB: appUsed,
            activeGB: Double(vmStats.active_count) * page / gigabyte,
            wiredGB: Double(vmStats.wire_count) * page / gigabyte,
            freeGB: Double(vmStats.free_count) * page / gigabyte,
            totalGB: total
        )
    }

    private static func readCPU() -> CPUInfo {
        let info = ProcessInfo.processInfo
        return CPUInfo(
            processorCount: info.processorCount,
            activeProcessorCount: info.activeProcessorCount,
            thermal: ThermalLevel(info.thermalState),
            uptime: info.systemUptime,
            lowPowerMode: info.isLowPowerModeEnabled
        )
    }

    private static func readGPU() -> GPUInfo {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return GPUInfo(name: "N/A", family: "N/A", maxWorkingSetMB: 0, supportsRaytracing: false)
        }
        var families: [(MTLGPUFamily, String)] = [
            (.apple8, "Apple 8"), (.apple7, "Apple 7"), (.apple6, "Apple 6"),
            (.apple5, "Apple 5"), (.apple4, "Apple 4"), (.apple3, "Apple 3"),
            (.apple2, "Apple 2"), (.apple1, "Apple 1")
        ]
        if #available(iOS 17.0, *) {
            families.insert((.apple9, "Apple 9"), at: 0)
        }
        let family = families.first { device.supportsFamily($0.0) }?.1 ?? "N/A"
        return GPUInfo(
            name: device.name,
            family: family,
            maxWorkingSetMB: Double(device.recommendedMaxWorkingSetSize) / 1_048_576,
            supportsRaytracing: device.supportsRaytracing
        )
    }

    private static func readDisplay() -> DisplayInfo {
        let screen = UIScreen.main
        let bounds = screen.nativeBounds
        return DisplayInfo(
            nativeWidth: Int(bounds.width),
            nativeHeight: Int(bounds.height),
            scale: Int(screen.nativeScale.rounded()),
            maxFramesPerSecond: screen.maximumFramesPerSecond
        )
    }
}
