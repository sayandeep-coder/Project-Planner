import SwiftUI

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let todoBlue = Color(hex: "4F6BFF")
    static let todoBlueDark = Color(hex: "3A52E0")
    static let todoBlueLight = Color(hex: "7C93FF")
    static let todoRed = Color(hex: "F0554A")
    static let todoOrange = Color(hex: "F5A623")
    static let todoGreen = Color(hex: "34C759")
    static let todoPurple = Color(hex: "8B5CF6")
    static let todoPink = Color(hex: "FF6B9D")
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let screenBackground = Color(.systemGroupedBackground)
}

extension LinearGradient {
    static let heroGradient = LinearGradient(
        colors: [Color(hex: "5B6FFF"), Color(hex: "8B5CF6"), Color(hex: "FF6B9D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let auroraGradient = LinearGradient(
        colors: [Color(hex: "4F6BFF"), Color(hex: "3A52E0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct MeshBackdrop: View {
    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()
            Circle()
                .fill(Color.todoBlue.opacity(0.35))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -140, y: -260)
            Circle()
                .fill(Color.todoPurple.opacity(0.3))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 160, y: -180)
            Circle()
                .fill(Color.todoPink.opacity(0.22))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 120, y: 420)
        }
        .ignoresSafeArea()
    }
}
