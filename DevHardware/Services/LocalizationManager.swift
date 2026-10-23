import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case vietnamese = "vi"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vietnamese: return "Tiếng Việt"
        case .english: return "English"
        }
    }
}

final class LocalizationManager: ObservableObject {
    private static let storageKey = "devhardware.language"

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: LocalizationManager.storageKey) }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: LocalizationManager.storageKey)
        language = stored.flatMap(AppLanguage.init(rawValue:)) ?? .english
    }

    func t(_ key: String) -> String {
        let table = language == .vietnamese ? LocalizationManager.vietnamese : LocalizationManager.english
        return table[key] ?? key
    }

    private static let english: [String: String] = [
        "tab_hardware": "Hardware", "tab_network": "Network", "tab_tools": "Dev Tools", "tab_settings": "Settings",
        "memory": "Memory", "app_ram": "App RAM", "active": "Active", "wired": "Wired", "free": "Free", "total": "Total",
        "cpu": "CPU", "active_cores": "Active cores", "uptime": "Uptime", "low_power": "Low Power Mode",
        "on": "On", "off": "Off", "thermal": "Thermal State",
        "nominal": "Nominal", "fair": "Fair", "serious": "Serious", "critical": "Critical",
        "gpu": "Metal GPU", "gpu_name": "Chip", "gpu_family": "GPU family", "gpu_memory": "Max working set",
        "raytracing": "Raytracing", "supported": "Supported", "unsupported": "Unsupported",
        "display": "Display", "resolution": "Native resolution", "scale": "Scale", "refresh": "Max refresh rate",
        "promotion": "ProMotion", "network_status": "Connection", "connected": "Connected", "disconnected": "Offline",
        "connection_type": "Type", "expensive": "Expensive path", "interfaces": "Interfaces", "no_interfaces": "No active interfaces",
        "if_wifi": "Wi-Fi", "if_cellular": "Cellular", "if_vpn": "VPN", "if_loopback": "Loopback", "if_wired": "Ethernet", "if_other": "Other",
        "json": "JSON", "jwt": "JWT", "hash": "Hash", "input": "Input", "output": "Output",
        "header": "Header", "payload": "Payload", "invalid_jwt": "Invalid JWT token",
        "sha256": "SHA-256", "base64_enc": "Base64 encode", "base64_dec": "Base64 decode", "invalid_base64": "Invalid Base64",
        "report_copy": "Copy Full Markdown Diagnostic Report", "report_copied": "Report copied to clipboard",
        "language": "Language", "about": "About", "developer": "Developer", "version": "Version"
    ]

    private static let vietnamese: [String: String] = [
        "tab_hardware": "Phần cứng", "tab_network": "Mạng", "tab_tools": "Công cụ", "tab_settings": "Cài đặt",
        "memory": "Bộ nhớ", "app_ram": "RAM ứng dụng", "active": "Đang dùng", "wired": "Wired", "free": "Trống", "total": "Tổng",
        "cpu": "CPU", "active_cores": "Nhân hoạt động", "uptime": "Thời gian chạy", "low_power": "Nguồn điện thấp",
        "on": "Bật", "off": "Tắt", "thermal": "Trạng thái nhiệt",
        "nominal": "Bình thường", "fair": "Hơi nóng", "serious": "Nóng", "critical": "Nguy hiểm",
        "gpu": "GPU Metal", "gpu_name": "Chip", "gpu_family": "Kiến trúc GPU", "gpu_memory": "Bộ nhớ tối đa",
        "raytracing": "Raytracing", "supported": "Hỗ trợ", "unsupported": "Không hỗ trợ",
        "display": "Màn hình", "resolution": "Độ phân giải gốc", "scale": "Tỷ lệ", "refresh": "Tần số quét tối đa",
        "promotion": "ProMotion", "network_status": "Kết nối", "connected": "Đã kết nối", "disconnected": "Ngoại tuyến",
        "connection_type": "Loại", "expensive": "Đường truyền tính phí", "interfaces": "Cổng giao tiếp", "no_interfaces": "Không có cổng hoạt động",
        "if_wifi": "Wi-Fi", "if_cellular": "Di động", "if_vpn": "VPN", "if_loopback": "Loopback", "if_wired": "Ethernet", "if_other": "Khác",
        "json": "JSON", "jwt": "JWT", "hash": "Băm", "input": "Đầu vào", "output": "Kết quả",
        "header": "Header", "payload": "Payload", "invalid_jwt": "JWT không hợp lệ",
        "sha256": "SHA-256", "base64_enc": "Mã hóa Base64", "base64_dec": "Giải mã Base64", "invalid_base64": "Base64 không hợp lệ",
        "report_copy": "Sao chép báo cáo chẩn đoán Markdown", "report_copied": "Đã chép báo cáo vào bộ nhớ tạm",
        "language": "Ngôn ngữ", "about": "Thông tin", "developer": "Nhà phát triển", "version": "Phiên bản"
    ]
}
