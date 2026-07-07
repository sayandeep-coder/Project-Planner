import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \TodoItem.dueDate) private var allTasks: [TodoItem]
    @State private var displayedMonth: Date = .now
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)

    private let calendar = Calendar.current
    private let weekdaySymbols = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    private var monthDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.end)
        else { return [] }

        var days: [Date?] = []
        var current = firstWeek.start
        while current < lastWeek.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return days
    }

    private var tasksForSelectedDate: [TodoItem] {
        allTasks
            .filter { calendar.isDate($0.dueDate, inSameDayAs: selectedDate) }
            .sorted { $0.dueDate < $1.dueDate }
    }

    private func hasTasks(on date: Date) -> Bool {
        allTasks.contains { calendar.isDate($0.dueDate, inSameDayAs: date) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshBackdrop()
                VStack(spacing: 0) {
                    monthHeader
                    GlassCard(cornerRadius: 26) {
                        VStack(spacing: 0) {
                            weekdayHeader
                            calendarGrid
                        }
                        .padding(.vertical, 14)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    taskListSection
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "calendar")
                }
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
            Spacer()
            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Spacer()
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 8)
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)

        return Button {
            selectedDate = calendar.startOfDay(for: date)
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(
                        isSelected ? .white : (isCurrentMonth ? .primary : .secondary.opacity(0.4))
                    )
                    .frame(width: 34, height: 34)
                    .background(
                        Circle().fill(isSelected ? AnyShapeStyle(Color.todoBlue.gradient) : (isToday ? AnyShapeStyle(Color.todoBlue.opacity(0.12)) : AnyShapeStyle(.clear)))
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
                if hasTasks(on: date) && !isSelected {
                    Circle()
                        .fill(Color.todoBlue)
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear.frame(width: 4, height: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var taskListSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(selectedDate, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                if tasksForSelectedDate.isEmpty {
                    EmptyStateView(icon: "calendar.badge.exclamationmark", title: "No tasks", message: "Nothing scheduled for this day.")
                        .padding(.vertical, 32)
                } else {
                    GlassEffectContainer(spacing: 12) {
                        VStack(spacing: 12) {
                            ForEach(tasksForSelectedDate) { task in
                                NavigationLink(value: task) {
                                    CalendarTaskRow(task: task)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 110)
        }
        .navigationDestination(for: TodoItem.self) { task in
            TaskDetailView(task: task)
        }
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}

struct CalendarTaskRow: View {
    let task: TodoItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                Text(task.dueDate, format: .dateTime.hour().minute())
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60, alignment: .leading)

            Rectangle()
                .fill(task.priority.color)
                .frame(width: 3)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(task.isCompleted)
                Text(task.category?.name ?? "General")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            PriorityBadge(priority: task.priority)
        }
        .padding(14)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
    }
}
