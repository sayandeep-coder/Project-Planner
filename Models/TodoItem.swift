import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var taskDescription: String
    var isCompleted: Bool
    var priorityRaw: String
    var dueDate: Date
    var hasDueTime: Bool
    var reminder: String
    var createdAt: Date
    var completedAt: Date?

    var category: TaskCategory?

    @Relationship(deleteRule: .cascade, inverse: \Subtask.task)
    var subtasks: [Subtask]? = []

    @Relationship(deleteRule: .cascade, inverse: \Assignee.task)
    var assignees: [Assignee]? = []

    init(
        title: String,
        taskDescription: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        dueDate: Date = .now,
        hasDueTime: Bool = true,
        reminder: String = "On time",
        category: TaskCategory? = nil
    ) {
        self.title = title
        self.taskDescription = taskDescription
        self.isCompleted = isCompleted
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
        self.hasDueTime = hasDueTime
        self.reminder = reminder
        self.createdAt = .now
        self.completedAt = nil
        self.category = category
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var subtaskList: [Subtask] {
        (subtasks ?? []).sorted { $0.order < $1.order }
    }

    var completedSubtaskCount: Int {
        subtaskList.filter { $0.isCompleted }.count
    }

    var isUpcoming: Bool {
        !isCompleted && dueDate > .now
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(dueDate)
    }

    var isInProgress: Bool {
        !isCompleted
    }
}
