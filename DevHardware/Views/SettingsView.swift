import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var system: SystemInspectorService
    @EnvironmentObject private var network: NetworkInspectorService
    @State private var reportCopied = false

    var body: some View {
        ScreenScaffold(title: loc.t("tab_settings")) {
            Button {
                UIPasteboard.general.string = DiagnosticReportService.markdown(
                    hardware: system.snapshot,
                    interfaces: network.interfaces,
                    path: network.path
                )
                reportCopied = true
            } label: {
                Label(
                    reportCopied ? loc.t("report_copied") : loc.t("report_copy"),
                    systemImage: reportCopied ? "checkmark.circle" : "doc.on.clipboard"
                )
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.background)
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Space.md)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            }

            CardView(title: loc.t("language"), symbol: "globe") {
                Picker("", selection: $loc.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }

            CardView(title: loc.t("about"), symbol: "info.circle") {
                MetricRow(label: loc.t("developer"), value: "ace4youblade")
                MetricRow(label: loc.t("version"), value: appVersion)
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}
