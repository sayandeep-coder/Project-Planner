import Foundation
import SwiftData

@Model
final class Subtask {
    var title: String
    var isCompleted: Bool
    var order: Int

    var task: TodoItem?

    init(title: String, isCompleted: Bool = false, order: Int = 0) {
        self.title = title
        self.isCompleted = isCompleted
        self.order = order
    }
}
