import Foundation
import SwiftData

enum NotificationKind: String, Codable {
    case reminder
    case assigned
    case completed
    case comment
    case upcoming
}

@Model
final class AppNotification {
    var kindRaw: String
    var title: String
    var body: String
    var createdAt: Date
    var isRead: Bool

    init(kind: NotificationKind, title: String, body: String, createdAt: Date = .now, isRead: Bool = false) {
        self.kindRaw = kind.rawValue
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.isRead = isRead
    }

    var kind: NotificationKind {
        NotificationKind(rawValue: kindRaw) ?? .reminder
    }
}
