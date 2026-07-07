import SwiftUI

enum AppTab: Int, CaseIterable {
    case home, tasks, calendar, profile

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .profile: return "person.crop.circle.fill"
        }
    }

    var label: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .calendar: return "Calendar"
        case .profile: return "Profile"
        }
    }
}

struct RootTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showingAddTask = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .tasks: TasksListView()
                case .calendar: CalendarView()
                case .profile: ProfileView()
                }
            }
            .transition(.opacity)

            FloatingGlassTabBar(selectedTab: $selectedTab, showingAddTask: $showingAddTask)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
    }
}

private struct FloatingGlassTabBar: View {
    @Binding var selectedTab: AppTab
    @Binding var showingAddTask: Bool
    @Namespace private var glassNamespace

    var body: some View {
        GlassEffectContainer(spacing: 18) {
            HStack(spacing: 6) {
                tabButton(.home)
                tabButton(.tasks)

                addButton
                    .padding(.horizontal, 4)

                tabButton(.calendar)
                tabButton(.profile)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private var addButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            showingAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(Color.todoBlue).interactive(), in: .circle)
        .glassEffectID("add-button", in: glassNamespace)
        .shadow(color: Color.todoBlue.opacity(0.35), radius: 10, y: 4)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 19, weight: selectedTab == tab ? .semibold : .regular))
                    .symbolEffect(.bounce, value: selectedTab == tab)
                if selectedTab == tab {
                    Text(tab.label)
                        .font(.system(size: 10, weight: .semibold))
                        .transition(.opacity.combined(with: .scale(scale: 0.7)))
                }
            }
            .foregroundStyle(selectedTab == tab ? Color.todoBlue : Color.secondary)
            .frame(width: selectedTab == tab ? 68 : 44, height: 50)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedTab)
        }
        .buttonStyle(.plain)
        .glassEffect(
            selectedTab == tab ? .regular.tint(Color.todoBlue.opacity(0.16)).interactive() : .regular.interactive(),
            in: .rect(cornerRadius: 20)
        )
        .glassEffectID(tab.rawValue, in: glassNamespace)
    }
}
