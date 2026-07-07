import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Bindable var task: TodoItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        ZStack {
            MeshBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    titleRow
                    if !task.taskDescription.isEmpty {
                        descriptionSection
                    }
                    infoSection
                    if !task.subtaskList.isEmpty {
                        subtasksSection
                    }
                    completeButton
                }
                .padding(16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit", systemImage: "pencil") { showingEdit = true }
                    Button("Delete", systemImage: "trash", role: .destructive) { showingDeleteConfirm = true }
                } label: {
                    Text("Edit")
                        .foregroundStyle(Color.todoBlue)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddTaskView(editingTask: task)
        }
        .confirmationDialog("Delete this task?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(task)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var titleRow: some View {
        HStack(alignment: .top) {
            Button {
                withAnimation {
                    task.isCompleted.toggle()
                    task.completedAt = task.isCompleted ? .now : nil
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(task.isCompleted ? Color.todoGreen : Color.secondary.opacity(0.4))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.title3.weight(.semibold))
                    .strikethrough(task.isCompleted)
                Text(task.category?.name ?? "General")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            PriorityBadge(priority: task.priority)
        }
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(task.taskDescription)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private var infoSection: some View {
        VStack(spacing: 0) {
            infoRow(label: "Due Date", value: task.dueDate.formatted(date: .abbreviated, time: .omitted))
            Divider()
            infoRow(label: "Due Time", value: task.dueDate.formatted(date: .omitted, time: .shortened))
            Divider()
            assigneeRow
            if !task.subtaskList.isEmpty {
                Divider()
                infoRow(label: "Subtasks", value: "\(task.completedSubtaskCount) / \(task.subtaskList.count) Completed")
            }
        }
        .padding(.horizontal, 18)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 14)
    }

    private var assigneeRow: some View {
        HStack {
            Text("Assignee")
                .foregroundStyle(.secondary)
            Spacer()
            AvatarStackView(assignees: task.assignees ?? [], size: 26)
            if let first = task.assignees?.first {
                Text(first.name)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 14)
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subtasks")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ForEach(task.subtaskList) { subtask in
                    HStack {
                        Button {
                            subtask.isCompleted.toggle()
                        } label: {
                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(subtask.isCompleted ? Color.todoGreen : Color.secondary.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                        Text(subtask.title)
                            .strikethrough(subtask.isCompleted)
                            .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    if subtask.id != task.subtaskList.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private var completeButton: some View {
        Button {
            withAnimation {
                task.isCompleted.toggle()
                task.completedAt = task.isCompleted ? .now : nil
            }
        } label: {
            Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Completed")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .glassButton(cornerRadius: 18, tint: task.isCompleted ? .secondary : .todoBlue)
    }
}
