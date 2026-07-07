import SwiftUI

struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }
}

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    var tint: Color? = nil
    @ViewBuilder var content: Content

    var body: some View {
        content
            .glassEffect(
                tint.map { .regular.tint($0.opacity(0.18)) } ?? .regular,
                in: .rect(cornerRadius: cornerRadius)
            )
    }
}

struct GlassButtonBackground: ViewModifier {
    var cornerRadius: CGFloat = 18
    var tint: Color = .todoBlue

    func body(content: Content) -> some View {
        content.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassButton(cornerRadius: CGFloat = 18, tint: Color = .todoBlue) -> some View {
        modifier(GlassButtonBackground(cornerRadius: cornerRadius, tint: tint))
    }
}
