import SwiftUI
import SwiftData

@main
struct TodoApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            TodoItem.self,
            TaskCategory.self,
            Subtask.self,
            Assignee.self,
            AppNotification.self,
            UserProfile.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AuthGateView()
        }
        .modelContainer(container)
    }
}
