import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \TodoItem.dueDate) private var allTasks: [TodoItem]
    @Query private var profiles: [UserProfile]
    @Query(sort: \AppNotification.createdAt, order: .reverse) private var notifications: [AppNotification]

    @State private var showingNotifications = false
    @State private var showingOverviewList: TaskFilter?

    private var profile: UserProfile? { profiles.first { $0.isLoggedIn } }

    private var todayTasks: [TodoItem] {
        allTasks.filter { $0.isToday }
    }

    private var completedTodayCount: Int {
        todayTasks.filter { $0.isCompleted }.count
    }

    private var progress: Double {
        todayTasks.isEmpty ? 0 : Double(completedTodayCount) / Double(todayTasks.count)
    }

    private var completedCount: Int { allTasks.filter { $0.isCompleted }.count }
    private var inProgressCount: Int { allTasks.filter { !$0.isCompleted && !$0.isUpcoming }.count }
    private var upcomingCount: Int { allTasks.filter { $0.isUpcoming }.count }
    private var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshBackdrop()
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        progressCard
                        overviewSection
                        todaySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingNotifications) {
                NavigationStack { NotificationsView() }
            }
            .navigationDestination(item: $showingOverviewList) { filter in
                TasksListView(initialFilter: filter)
            }
        }
    }

    private var header: some View {
        HStack {
            Circle()
                .fill(LinearGradient.heroGradient)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(initials(from: profile?.name ?? "?"))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                )
                .shadow(color: Color.todoBlue.opacity(0.3), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                showingNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                    if unreadCount > 0 {
                        Circle()
                            .fill(Color.todoRed)
                            .frame(width: 9, height: 9)
                            .offset(x: -4, y: 4)
                    }
                }
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let name = (profile?.name ?? "there").split(separator: " ").first.map(String.init) ?? "there"
        switch hour {
        case 0..<12: return "Good Morning, \(name) 👋"
        case 12..<17: return "Good Afternoon, \(name) 👋"
        default: return "Good Evening, \(name) 👋"
        }
    }

    private var progressCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Progress")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(completedTodayCount)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("/\(todayTasks.count)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .foregroundStyle(.white)
                Text("Tasks Completed")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))

                Capsule()
                    .fill(.white.opacity(0.25))
                    .frame(height: 6)
                    .overlay(alignment: .leading) {
                        GeometryReader { geo in
                            Capsule()
                                .fill(.white)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 6)
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.25), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                Text("\(Int(progress * 100))%")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 66, height: 66)
        }
        .padding(22)
        .background(LinearGradient.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.todoPurple.opacity(0.35), radius: 24, y: 14)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Overview")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Button("View All") { showingOverviewList = .all }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.todoBlue)
            }
            GlassEffectContainer(spacing: 12) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatTile(value: allTasks.count, label: "Total Tasks", systemImage: "list.bullet.clipboard", color: Color.todoBlue)
                        .onTapGesture { showingOverviewList = .all }
                    StatTile(value: completedCount, label: "Completed", systemImage: "checkmark", color: Color.todoGreen)
                        .onTapGesture { showingOverviewList = .completed }
                    StatTile(value: inProgressCount, label: "In Progress", systemImage: "clock", color: Color.todoOrange)
                        .onTapGesture { showingOverviewList = .today }
                    StatTile(value: upcomingCount, label: "Upcoming", systemImage: "calendar", color: Color.todoPurple)
                        .onTapGesture { showingOverviewList = .upcoming }
                }
            }
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Button("View All") { showingOverviewList = .today }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.todoBlue)
            }
            if todayTasks.isEmpty {
                EmptyStateView(icon: "checkmark.circle", title: "No tasks today", message: "Enjoy your free time!")
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular, in: .rect(cornerRadius: 22))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(todayTasks.prefix(4))) { task in
                        NavigationLink(value: task) {
                            TaskRow(task: task)
                        }
                        .buttonStyle(.plain)
                        if task.id != todayTasks.prefix(4).last?.id {
                            Divider()
                        }
                    }
                }
                .padding(12)
                .glassEffect(.regular, in: .rect(cornerRadius: 22))
            }
        }
        .navigationDestination(for: TodoItem.self) { task in
            TaskDetailView(task: task)
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
