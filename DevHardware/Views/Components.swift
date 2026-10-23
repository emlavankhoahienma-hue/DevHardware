import SwiftUI

struct CardView<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Space.sm) {
            Label(title, systemImage: symbol)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.accent)
            content
        }
        .padding(AppTheme.Space.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.card).stroke(AppTheme.border, lineWidth: 1))
    }
}

struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(AppTheme.Typography.value)
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}

struct MeterBar: View {
    let label: String
    let value: String
    let fraction: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            MetricRow(label: label, value: value)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppTheme.border)
                    Capsule()
                        .fill(AppTheme.accent)
                        .frame(width: proxy.size.width * CGFloat(max(0, min(fraction, 1))))
                        .animation(.easeOut(duration: 0.4), value: fraction)
                }
            }
            .frame(height: 6)
        }
    }
}

struct ScreenScaffold<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Space.md) {
                    content
                }
                .padding(AppTheme.Space.md)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }
}
