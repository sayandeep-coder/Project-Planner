import SwiftUI
import SwiftData

struct TasksListView: View {
    @Query(sort: \TodoItem.dueDate) private var allTasks: [TodoItem]
    @State private var searchText = ""
    @State private var filter: TaskFilter
    @State private var showingAddTask = false
    @Namespace private var filterNamespace

    init(initialFilter: TaskFilter = .all) {
        _filter = State(initialValue: initialFilter)
    }

    private var filteredTasks: [TodoItem] {
        var tasks = allTasks
        switch filter {
        case .all: break
        case .today: tasks = tasks.filter { $0.isToday && !$0.isCompleted }
        case .upcoming: tasks = tasks.filter { $0.isUpcoming }
        case .completed: tasks = tasks.filter { $0.isCompleted }
        }
        if !searchText.isEmpty {
            tasks = tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return tasks
    }

    private var groupedByPriority: [(Priority, [TodoItem])] {
        Dictionary(grouping: filteredTasks, by: \.priority)
            .sorted { $0.key.sortOrder < $1.key.sortOrder }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshBackdrop()
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search tasks", text: $searchText)
                    }
                    .padding(12)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        GlassEffectContainer(spacing: 8) {
                            HStack(spacing: 8) {
                                ForEach(TaskFilter.allCases, id: \.self) { f in
                                    FilterChip(title: f.rawValue, isSelected: filter == f) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            filter = f
                                        }
                                    }
                                    .glassEffectID(f.rawValue, in: filterNamespace)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 12)

                    if filteredTasks.isEmpty {
                        Spacer()
                        EmptyStateView(icon: "tray", title: "No tasks found", message: "Try a different filter or search term.")
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(groupedByPriority, id: \.0) { priority, tasks in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "flag.fill")
                                                .font(.caption)
                                                .foregroundStyle(priority.color)
                                            Text("\(priority.rawValue) Priority")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(priority.color)
                                        }
                                        VStack(spacing: 0) {
                                            ForEach(tasks) { task in
                                                NavigationLink(value: task) {
                                                    TaskRow(task: task)
                                                }
                                                .buttonStyle(.plain)
                                                if task.id != tasks.last?.id {
                                                    Divider()
                                                }
                                            }
                                        }
                                        .padding(12)
                                        .glassEffect(.regular, in: .rect(cornerRadius: 20))
                                    }
                                }
                            }
                            .padding(16)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .navigationDestination(for: TodoItem.self) { task in
                TaskDetailView(task: task)
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .glassEffect(isSelected ? .regular.tint(Color.todoBlue).interactive() : .regular.interactive(), in: .capsule)
    }
}
