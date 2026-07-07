import Foundation
import SwiftData

@Model
final class Assignee {
    var name: String
    var colorHex: String

    var task: TodoItem?

    init(name: String, colorHex: String = "4F6BFF") {
        self.name = name
        self.colorHex = colorHex
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
