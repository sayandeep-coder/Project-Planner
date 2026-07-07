import Foundation
import SwiftData
import CryptoKit

@Model
final class UserProfile {
    var name: String
    var email: String
    var role: String
    var passwordHash: String
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    var isLoggedIn: Bool
    var createdAt: Date

    init(
        name: String = "",
        email: String = "",
        role: String = "Product Manager",
        password: String = "",
        isDarkMode: Bool = false,
        notificationsEnabled: Bool = true,
        isLoggedIn: Bool = false
    ) {
        self.name = name
        self.email = email
        self.role = role
        self.passwordHash = Self.hash(password)
        self.isDarkMode = isDarkMode
        self.notificationsEnabled = notificationsEnabled
        self.isLoggedIn = isLoggedIn
        self.createdAt = .now
    }

    static func hash(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    func setPassword(_ password: String) {
        passwordHash = Self.hash(password)
    }

    func verifyPassword(_ password: String) -> Bool {
        passwordHash == Self.hash(password)
    }
}
