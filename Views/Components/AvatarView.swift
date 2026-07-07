import SwiftUI

struct AvatarView: View {
    let initials: String
    let colorHex: String
    var size: CGFloat = 32

    var body: some View {
        Circle()
            .fill(Color(hex: colorHex))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(.white)
            )
    }
}

struct AvatarStackView: View {
    let assignees: [Assignee]
    var size: CGFloat = 28
    var maxShown: Int = 3

    var body: some View {
        HStack(spacing: -8) {
            ForEach(Array(assignees.prefix(maxShown))) { assignee in
                AvatarView(initials: assignee.initials, colorHex: assignee.colorHex, size: size)
                    .overlay(Circle().stroke(Color.cardBackground, lineWidth: 2))
            }
            if assignees.count > maxShown {
                Circle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: size, height: size)
                    .overlay(
                        Text("+\(assignees.count - maxShown)")
                            .font(.system(size: size * 0.34, weight: .semibold))
                            .foregroundStyle(.primary)
                    )
                    .overlay(Circle().stroke(Color.cardBackground, lineWidth: 2))
            }
        }
    }
}
