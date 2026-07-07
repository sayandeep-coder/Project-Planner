import SwiftUI
import SwiftData

struct TaskRow: View {
    @Bindable var task: TodoItem
    var showTime: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    task.isCompleted.toggle()
                    task.completedAt = task.isCompleted ? .now : nil
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(task.isCompleted ? Color.todoGreen : Color.secondary.opacity(0.4))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.caption2)
                    Text(task.category?.name ?? "General")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                PriorityBadge(priority: task.priority)
                if showTime {
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(task.dueDate, format: .dateTime.hour().minute())
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
