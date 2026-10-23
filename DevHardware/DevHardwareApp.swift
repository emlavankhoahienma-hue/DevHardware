import SwiftUI

@main
struct DevHardwareApp: App {
    @StateObject private var loc = LocalizationManager()
    @StateObject private var system = SystemInspectorService()
    @StateObject private var network = NetworkInspectorService()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.surface)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        let navigation = UINavigationBarAppearance()
        navigation.configureWithOpaqueBackground()
        navigation.backgroundColor = UIColor(AppTheme.background)
        navigation.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigation.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navigation
        UINavigationBar.appearance().scrollEdgeAppearance = navigation
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(loc)
                .environmentObject(system)
                .environmentObject(network)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootTabView: View {
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        TabView {
            HardwareView()
                .tabItem { Label(loc.t("tab_hardware"), systemImage: "cpu") }
            NetworkView()
                .tabItem { Label(loc.t("tab_network"), systemImage: "network") }
            DevToolsView()
                .tabItem { Label(loc.t("tab_tools"), systemImage: "wrench.and.screwdriver") }
            SettingsView()
                .tabItem { Label(loc.t("tab_settings"), systemImage: "gearshape") }
        }
        .tint(AppTheme.accent)
    }
}
