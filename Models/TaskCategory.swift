import Foundation
import SwiftData

@Model
final class TaskCategory {
    var name: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \TodoItem.category)
    var tasks: [TodoItem]? = []

    init(name: String, colorHex: String = "4F6BFF") {
        self.name = name
        self.colorHex = colorHex
        self.createdAt = .now
    }
}
