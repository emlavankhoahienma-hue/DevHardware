import SwiftUI
import UIKit

struct NetworkView: View {
    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var network: NetworkInspectorService
    @State private var copiedID: String?

    var body: some View {
        ScreenScaffold(title: loc.t("tab_network")) {
            CardView(title: loc.t("network_status"), symbol: network.path.isConnected ? "checkmark.circle" : "xmark.circle") {
                MetricRow(label: loc.t("network_status"), value: loc.t(network.path.isConnected ? "connected" : "disconnected"))
                MetricRow(label: loc.t("connection_type"), value: loc.t(network.path.typeKey))
                MetricRow(label: loc.t("expensive"), value: loc.t(network.path.isExpensive ? "on" : "off"))
            }
            CardView(title: loc.t("interfaces"), symbol: "network") {
                if network.interfaces.isEmpty {
                    Text(loc.t("no_interfaces"))
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ForEach(network.interfaces) { item in
                    interfaceRow(item)
                }
            }
        }
        .onAppear { network.refresh() }
    }

    private func interfaceRow(_ item: NetworkInterface) -> some View {
        Button {
            UIPasteboard.general.string = item.address
            copiedID = item.id
        } label: {
            HStack(spacing: AppTheme.Space.sm) {
                Image(systemName: item.kind.symbol)
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name + "  " + (item.isIPv6 ? "IPv6" : "IPv4") + "  " + loc.t(item.kind.titleKey))
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(item.address)
                        .font(AppTheme.Typography.value)
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: copiedID == item.id ? "checkmark" : "doc.on.doc")
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
