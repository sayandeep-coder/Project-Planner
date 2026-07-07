import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Query(sort: \AppNotification.createdAt, order: .reverse) private var notifications: [AppNotification]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var filter: NotifFilter = .all

    enum NotifFilter: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case mentions = "Mentions"
    }

    private var filtered: [AppNotification] {
        switch filter {
        case .all: return notifications
        case .unread: return notifications.filter { !$0.isRead }
        case .mentions: return notifications.filter { $0.kind == .comment }
        }
    }

    var body: some View {
        ZStack {
            MeshBackdrop()
            VStack(spacing: 0) {
                Picker("Filter", selection: $filter) {
                    ForEach(NotifFilter.allCases, id: \.self) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(16)

                if filtered.isEmpty {
                    Spacer()
                    EmptyStateView(icon: "bell.slash", title: "No notifications", message: "You're all caught up.")
                    Spacer()
                } else {
                    ScrollView {
                        GlassEffectContainer(spacing: 12) {
                            VStack(spacing: 12) {
                                ForEach(filtered) { notification in
                                    NotificationRow(notification: notification)
                                        .onTapGesture {
                                            notification.isRead = true
                                        }
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Mark all as read") {
                    notifications.forEach { $0.isRead = true }
                }
                .font(.subheadline)
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification

    private var iconAndColor: (String, Color) {
        switch notification.kind {
        case .reminder: return ("bell.fill", .todoOrange)
        case .assigned: return ("person.fill.badge.plus", .todoBlue)
        case .completed: return ("checkmark.circle.fill", .todoGreen)
        case .comment: return ("bubble.left.fill", .todoPurple)
        case .upcoming: return ("calendar", .todoRed)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconAndColor.1.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: iconAndColor.0)
                    .foregroundStyle(iconAndColor.1)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline.weight(.semibold))
                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(notification.createdAt, format: .relative(presentation: .named))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if !notification.isRead {
                    Circle()
                        .fill(Color.todoBlue)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(14)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
    }
}
