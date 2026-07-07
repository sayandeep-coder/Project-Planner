import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \TaskCategory.name) private var categories: [TaskCategory]
    @Query private var allAssignees: [Assignee]

    var editingTask: TodoItem?

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var priority: Priority = .high
    @State private var selectedCategory: TaskCategory?
    @State private var dueDate: Date = .now
    @State private var dueTime: Date = .now
    @State private var reminder = "On time"
    @State private var subtaskTitles: [String] = []
    @State private var newSubtaskTitle = ""
    @State private var selectedAssigneeNames: Set<String> = []
    @State private var activeTab: DetailTab = .details
    @State private var showingCategoryPicker = false

    private let reminderOptions = ["On time", "5 minutes before", "15 minutes before", "1 hour before", "1 day before"]
    private let availableAssigneeNames = ["Alex Morgan", "Sarah Johnson", "John Doe", "Emma Wilson"]

    enum DetailTab: String, CaseIterable {
        case details = "Task Details"
        case subtasks = "Subtasks"
    }

    private var isEditing: Bool { editingTask != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshBackdrop()
                VStack(spacing: 0) {
                    Picker("Tab", selection: $activeTab) {
                        ForEach(DetailTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(16)

                    ScrollView {
                        if activeTab == .details {
                            detailsForm
                        } else {
                            subtasksForm
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTask() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private var detailsForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            fieldLabel("Task Title")
            TextField("Enter task title", text: $title)
                .textFieldStyle(TodoTextFieldStyle())

            fieldLabel("Description")
            TextField("Add task description", text: $descriptionText, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(TodoTextFieldStyle())

            fieldLabel("Priority")
            HStack(spacing: 10) {
                ForEach(Priority.allCases) { p in
                    SelectablePriorityChip(priority: p, isSelected: priority == p) {
                        priority = p
                    }
                }
            }

            fieldLabel("Category")
            Menu {
                ForEach(categories) { category in
                    Button(category.name) { selectedCategory = category }
                }
            } label: {
                HStack {
                    Text(selectedCategory?.name ?? "Select category")
                        .foregroundStyle(selectedCategory == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            fieldLabel("Due Date")
            DatePicker("", selection: $dueDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: .rect(cornerRadius: 16))

            fieldLabel("Due Time")
            DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: .rect(cornerRadius: 16))

            fieldLabel("Assignee")
            HStack(spacing: -8) {
                ForEach(availableAssigneeNames.filter { selectedAssigneeNames.contains($0) }, id: \.self) { name in
                    AvatarView(initials: initials(from: name), colorHex: "4F6BFF", size: 32)
                        .overlay(Circle().stroke(Color.screenBackground, lineWidth: 2))
                }
                Menu {
                    ForEach(availableAssigneeNames, id: \.self) { name in
                        Button {
                            if selectedAssigneeNames.contains(name) {
                                selectedAssigneeNames.remove(name)
                            } else {
                                selectedAssigneeNames.insert(name)
                            }
                        } label: {
                            Label(name, systemImage: selectedAssigneeNames.contains(name) ? "checkmark" : "")
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 32, height: 32)
                        .glassEffect(.regular.interactive(), in: .circle)
                }
                .padding(.leading, selectedAssigneeNames.isEmpty ? 0 : 8)
                Spacer()
            }

            fieldLabel("Reminder")
            Menu {
                ForEach(reminderOptions, id: \.self) { option in
                    Button(option) { reminder = option }
                }
            } label: {
                HStack {
                    Text(reminder)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private var subtasksForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                TextField("Add a subtask", text: $newSubtaskTitle)
                    .textFieldStyle(TodoTextFieldStyle())
                Button {
                    let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    subtaskTitles.append(trimmed)
                    newSubtaskTitle = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.todoBlue)
                }
            }

            if subtaskTitles.isEmpty {
                EmptyStateView(icon: "checklist", title: "No subtasks yet", message: "Break this task into smaller steps.")
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(subtaskTitles.enumerated()), id: \.offset) { index, subtitle in
                        HStack {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                            Text(subtitle)
                            Spacer()
                            Button {
                                subtaskTitles.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 10)
                        if index != subtaskTitles.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(12)
                .glassEffect(.regular, in: .rect(cornerRadius: 18))
            }
        }
        .padding(16)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        return String(parts.prefix(2).compactMap { $0.first }).uppercased()
    }

    private func loadIfEditing() {
        guard let task = editingTask else {
            if selectedCategory == nil { selectedCategory = categories.first }
            return
        }
        title = task.title
        descriptionText = task.taskDescription
        priority = task.priority
        selectedCategory = task.category
        dueDate = task.dueDate
        dueTime = task.dueDate
        reminder = task.reminder
        subtaskTitles = task.subtaskList.map(\.title)
        selectedAssigneeNames = Set((task.assignees ?? []).map(\.name))
    }

    private func saveTask() {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: dueTime)
        let combinedDate = calendar.date(
            bySettingHour: timeComponents.hour ?? 9,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: dueDate
        ) ?? dueDate

        let task = editingTask ?? TodoItem(title: title)
        task.title = title.trimmingCharacters(in: .whitespaces)
        task.taskDescription = descriptionText
        task.priority = priority
        task.category = selectedCategory
        task.dueDate = combinedDate
        task.reminder = reminder

        (task.subtasks ?? []).forEach { modelContext.delete($0) }
        task.subtasks = subtaskTitles.enumerated().map { index, subtitle in
            Subtask(title: subtitle, isCompleted: false, order: index)
        }

        (task.assignees ?? []).forEach { modelContext.delete($0) }
        task.assignees = selectedAssigneeNames.map { name in
            Assignee(name: name, colorHex: ["4F6BFF", "F0554A", "34C759", "F5A623"].randomElement() ?? "4F6BFF")
        }

        if editingTask == nil {
            modelContext.insert(task)
        }
        try? modelContext.save()
        dismiss()
    }
}

struct TodoTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }
}
