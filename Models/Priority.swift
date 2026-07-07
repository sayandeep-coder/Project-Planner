import SwiftUI

enum Priority: String, Codable, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .high: return .todoRed
        case .medium: return .todoOrange
        case .low: return .todoGreen
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}
