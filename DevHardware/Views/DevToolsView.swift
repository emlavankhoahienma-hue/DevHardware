import SwiftUI

struct DevToolsView: View {
    private enum Tool: String, CaseIterable, Identifiable {
        case json, jwt, hash
        var id: String { rawValue }
    }

    @EnvironmentObject private var loc: LocalizationManager
    @State private var tool: Tool = .json
    @State private var input = ""

    var body: some View {
        ScreenScaffold(title: loc.t("tab_tools")) {
            Picker("", selection: $tool) {
                ForEach(Tool.allCases) { item in
                    Text(loc.t(item.rawValue)).tag(item)
                }
            }
            .pickerStyle(.segmented)

            CardView(title: loc.t("input"), symbol: "square.and.pencil") {
                TextEditor(text: $input)
                    .font(AppTheme.Typography.value)
                    .scrollContentBackground(.hidden)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .frame(minHeight: 120)
                    .padding(AppTheme.Space.xs)
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
            }

            switch tool {
            case .json: jsonOutput
            case .jwt: jwtOutput
            case .hash: hashOutput
            }
        }
    }

    private var jsonOutput: some View {
        CardView(title: loc.t("output"), symbol: "curlybraces") {
            if input.isEmpty {
                EmptyView()
            } else {
                switch DevToolsService.formatJSON(input) {
                case .success(let text): outputText(text, isError: false)
                case .failure(let error): outputText(error.localizedDescription, isError: true)
                }
            }
        }
    }

    private var jwtOutput: some View {
        CardView(title: loc.t("output"), symbol: "key") {
            if input.isEmpty {
                EmptyView()
            } else if let jwt = DevToolsService.decodeJWT(input) {
                section(loc.t("header"), jwt.header)
                section(loc.t("payload"), jwt.payload)
            } else {
                outputText(loc.t("invalid_jwt"), isError: true)
            }
        }
    }

    private var hashOutput: some View {
        CardView(title: loc.t("output"), symbol: "number") {
            if !input.isEmpty {
                section(loc.t("sha256"), DevToolsService.sha256(input))
                section(loc.t("base64_enc"), DevToolsService.base64Encode(input))
                if let decoded = DevToolsService.base64Decode(input) {
                    section(loc.t("base64_dec"), decoded)
                } else {
                    section(loc.t("base64_dec"), loc.t("invalid_base64"))
                }
            }
        }
    }

    private func section(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.textSecondary)
            outputText(text, isError: false)
        }
    }

    private func outputText(_ text: String, isError: Bool) -> some View {
        Text(text)
            .font(AppTheme.Typography.value)
            .foregroundStyle(isError ? Color.red : AppTheme.textPrimary)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
