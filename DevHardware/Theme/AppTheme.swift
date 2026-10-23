import SwiftUI

enum AppTheme {
    static let background = Color(hex: 0x0B0E14)
    static let surface = Color(hex: 0x141923)
    static let border = Color(hex: 0x222938)
    static let accent = Color(hex: 0x06B6D4)
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.56)

    enum Space {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
    }

    enum Radius {
        static let card: CGFloat = 16
        static let control: CGFloat = 8
    }

    enum Typography {
        static let headline = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 14, weight: .regular, design: .default)
        static let value = Font.system(size: 14, weight: .medium, design: .monospaced)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
    }
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
