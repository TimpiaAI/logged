import SwiftUI

// MARK: - Spacing
enum LoggedSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - Corner Radius
enum LoggedCornerRadius {
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - Typography
extension Font {
    static let loggedLargeTitle = Font.system(size: 32, weight: .light, design: .monospaced)
    static let loggedTitle = Font.system(size: 24, weight: .semibold, design: .monospaced)
    static let loggedTitle2 = Font.system(size: 18, weight: .semibold, design: .monospaced)
    static let loggedHeadline = Font.system(size: 16, weight: .semibold, design: .monospaced)
    static let loggedBody = Font.system(size: 14, weight: .regular, design: .monospaced)
    static let loggedCallout = Font.system(size: 13, weight: .regular, design: .monospaced)
    static let loggedCaption = Font.system(size: 11, weight: .regular, design: .monospaced)
    static let loggedMicro = Font.system(size: 10, weight: .regular, design: .monospaced)
}

// MARK: - Colors
extension Color {
    // Accent colors
    static let loggedAccent = Color(red: 0.29, green: 0.87, blue: 0.50) // #4ADE80 - Vibrant green
    static let loggedPR = Color(red: 0.98, green: 0.75, blue: 0.15)     // #FBBF24 - Gold
    static let loggedError = Color(red: 0.94, green: 0.27, blue: 0.27) // #EF4444 - Red

    // Background colors for dark mode
    static let loggedBackground = Color(red: 0.04, green: 0.04, blue: 0.04)       // #0A0A0A
    static let loggedCardBackground = Color(red: 0.10, green: 0.10, blue: 0.10)   // #1A1A1A
    static let loggedBorder = Color(red: 0.16, green: 0.16, blue: 0.16)           // #2A2A2A

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions
extension View {
    func loggedBackground() -> some View {
        self.background(Color.loggedBackground)
    }
}

// MARK: - Button Styles
struct LoggedGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, LoggedSpacing.m)
            .padding(.vertical, LoggedSpacing.s)
            .background(Color.loggedCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LoggedCornerRadius.s, style: .continuous)
                    .stroke(Color.loggedBorder, lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension ButtonStyle where Self == LoggedGlassButtonStyle {
    static var loggedGlass: LoggedGlassButtonStyle { LoggedGlassButtonStyle() }
}

// MARK: - Press Map Style (scale effect on press)
struct PressMapStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Staggered Animation Modifier
struct StaggeredModifier: ViewModifier {
    let index: Int
    let total: Int

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3).delay(Double(index) * 0.05)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggered(index: Int, total: Int) -> some View {
        modifier(StaggeredModifier(index: index, total: total))
    }
}
