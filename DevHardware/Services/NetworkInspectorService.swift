import Foundation
import Darwin
import Network

final class NetworkInspectorService: ObservableObject {
    @Published private(set) var interfaces: [NetworkInterface] = []
    @Published private(set) var path = PathSnapshot(isConnected: false, typeKey: "if_other", isExpensive: false)

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "devhardware.network.monitor")

    init() {
        interfaces = NetworkInspectorService.readInterfaces()
        monitor.pathUpdateHandler = { [weak self] newPath in
            let snapshot = PathSnapshot(
                isConnected: newPath.status == .satisfied,
                typeKey: NetworkInspectorService.typeKey(for: newPath),
                isExpensive: newPath.isExpensive
            )
            let list = NetworkInspectorService.readInterfaces()
            DispatchQueue.main.async {
                self?.path = snapshot
                self?.interfaces = list
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    func refresh() {
        interfaces = NetworkInspectorService.readInterfaces()
    }

    private static func typeKey(for path: NWPath) -> String {
        if path.usesInterfaceType(.wifi) { return "if_wifi" }
        if path.usesInterfaceType(.cellular) { return "if_cellular" }
        if path.usesInterfaceType(.wiredEthernet) { return "if_wired" }
        if path.usesInterfaceType(.loopback) { return "if_loopback" }
        return "if_other"
    }

    private static func readInterfaces() -> [NetworkInterface] {
        var head: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&head) == 0, let first = head else { return [] }
        defer { freeifaddrs(head) }

        var result: [NetworkInterface] = []
        var cursor: UnsafeMutablePointer<ifaddrs>? = first
        while let current = cursor {
            let entry = current.pointee
            cursor = entry.ifa_next
            guard let address = entry.ifa_addr else { continue }
            let family = Int32(address.pointee.sa_family)
            guard family == AF_INET || family == AF_INET6 else { continue }
            guard entry.ifa_flags & UInt32(IFF_UP) != 0 else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let length = socklen_t(family == AF_INET ? MemoryLayout<sockaddr_in>.size : MemoryLayout<sockaddr_in6>.size)
            guard getnameinfo(address, length, &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 else { continue }

            result.append(NetworkInterface(
                name: String(cString: entry.ifa_name),
                address: String(cString: host),
                isIPv6: family == AF_INET6
            ))
        }
        return result.sorted { ($0.name, $0.isIPv6 ? 1 : 0) < ($1.name, $1.isIPv6 ? 1 : 0) }
    }
}
