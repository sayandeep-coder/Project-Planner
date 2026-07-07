import Foundation

enum TaskFilter: String, Identifiable, Hashable, CaseIterable {
    case all = "All"
    case today = "Today"
    case upcoming = "Upcoming"
    case completed = "Completed"

    var id: String { rawValue }
}
