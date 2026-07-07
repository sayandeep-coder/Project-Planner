import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query private var allTasks: [TodoItem]

    private var completedCount: Int { allTasks.filter { $0.isCompleted }.count }
    private var inProgressCount: Int { allTasks.filter { !$0.isCompleted && !$0.isUpcoming }.count }
    private var upcomingCount: Int { allTasks.filter { $0.isUpcoming }.count }

    private var completionRate: Int {
        allTasks.isEmpty ? 0 : Int(Double(completedCount) / Double(allTasks.count) * 100)
    }

    private var weeklyCompletion: [DayCompletion] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let weekdaySymbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        guard let weekStart = calendar.date(byAdding: .day, value: -Int((calendar.component(.weekday, from: today) + 5) % 7), to: today) else {
            return []
        }

        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: weekStart) ?? weekStart
            let dayTasks = allTasks.filter { calendar.isDate($0.dueDate, inSameDayAs: day) }
            let completed = dayTasks.filter { $0.isCompleted }.count
            let rate = dayTasks.isEmpty ? 0 : Double(completed) / Double(dayTasks.count) * 100
            return DayCompletion(label: weekdaySymbols[offset], rate: rate)
        }
    }

    private var priorityBreakdown: [PrioritySlice] {
        Priority.allCases.map { p in
            PrioritySlice(priority: p, count: allTasks.filter { $0.priority == p }.count)
        }.filter { $0.count > 0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        overviewGrid
                        completionChart
                        priorityChart
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("This Week") {}
                        Button("This Month") {}
                    } label: {
                        Label("This Week", systemImage: "chevron.down")
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    private var overviewGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            GlassEffectContainer(spacing: 12) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatTile(value: allTasks.count, label: "Total Tasks", systemImage: "list.bullet.clipboard", color: Color.todoBlue)
                    StatTile(value: completedCount, label: "Completed", systemImage: "checkmark", color: Color.todoGreen)
                    StatTile(value: inProgressCount, label: "In Progress", systemImage: "clock", color: Color.todoOrange)
                    StatTile(value: upcomingCount, label: "Upcoming", systemImage: "calendar", color: Color.todoPurple)
                }
            }
        }
    }

    private var completionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Task Completion")
                    .font(.headline)
                Spacer()
                Text("\(completionRate)%")
                    .font(.title3.weight(.bold))
                Text("+10% from last week")
                    .font(.caption2)
                    .foregroundStyle(Color.todoGreen)
            }
            Chart(weeklyCompletion) { day in
                LineMark(x: .value("Day", day.label), y: .value("Rate", day.rate))
                    .foregroundStyle(Color.todoBlue)
                    .interpolationMethod(.catmullRom)
                    .symbol(Circle())
                AreaMark(x: .value("Day", day.label), y: .value("Rate", day.rate))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.todoBlue.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom)
                    )
                    .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(values: [0, 50, 100]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)%")
                        }
                    }
                }
            }
            .frame(height: 180)
        }
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private var priorityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Priority")
                .font(.headline)
            HStack(spacing: 20) {
                Chart(priorityBreakdown) { slice in
                    SectorMark(angle: .value("Count", slice.count), innerRadius: .ratio(0.6), angularInset: 2)
                        .foregroundStyle(slice.priority.color)
                        .cornerRadius(4)
                }
                .frame(width: 140, height: 140)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(priorityBreakdown) { slice in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(slice.priority.color)
                                .frame(width: 8, height: 8)
                            Text(slice.priority.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text("\(slice.count) (\(percentage(slice.count))%)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }

    private func percentage(_ count: Int) -> Int {
        allTasks.isEmpty ? 0 : Int(Double(count) / Double(allTasks.count) * 100)
    }
}

struct DayCompletion: Identifiable {
    let id = UUID()
    let label: String
    let rate: Double
}

struct PrioritySlice: Identifiable {
    var id: Priority { priority }
    let priority: Priority
    let count: Int
}
