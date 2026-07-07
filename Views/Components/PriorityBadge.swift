import SwiftUI

struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        Label(priority.rawValue, systemImage: "flag.fill")
            .labelStyle(.titleAndIcon)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(priority.color)
    }
}

struct SelectablePriorityChip: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "flag.fill")
                    .font(.caption)
                Text(priority.rawValue)
                    .font(.subheadline.weight(.medium))
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                }
            }
            .foregroundStyle(isSelected ? .white : priority.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
        }
        .buttonStyle(.plain)
        .glassEffect(isSelected ? .regular.tint(priority.color).interactive() : .regular.interactive(), in: .capsule)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}
