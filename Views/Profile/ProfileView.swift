import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @State private var showingEditProfile = false
    @State private var showingStatistics = false
    @State private var showingNotifications = false
    @State private var showingLogoutConfirm = false

    private var profile: UserProfile? {
        profiles.first { $0.isLoggedIn }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MeshBackdrop()
                if let profile {
                    ScrollView {
                        VStack(spacing: 20) {
                            header(profile)
                            menuSection(profile)
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditProfile) {
                if let profile { EditProfileView(profile: profile) }
            }
            .navigationDestination(isPresented: $showingStatistics) {
                StatisticsView()
            }
            .sheet(isPresented: $showingNotifications) {
                NavigationStack { NotificationsView() }
            }
            .confirmationDialog("Log out of your account?", isPresented: $showingLogoutConfirm, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    withAnimation {
                        profile?.isLoggedIn = false
                        try? modelContext.save()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func header(_ profile: UserProfile) -> some View {
        GlassCard(cornerRadius: 28, tint: .todoBlue) {
            VStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(LinearGradient.heroGradient)
                        .frame(width: 88, height: 88)
                        .overlay(
                            Text(initials(from: profile.name))
                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: Color.todoBlue.opacity(0.35), radius: 14, y: 6)
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white, Color.todoBlue)
                        .background(Circle().fill(.white))
                }
                Text(profile.name)
                    .font(.title3.weight(.bold))
                Text(profile.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(profile.role)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.todoBlue.gradient)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
        }
        .onTapGesture { showingEditProfile = true }
    }

    private func menuSection(_ profile: UserProfile) -> some View {
        GlassEffectContainer(spacing: 2) {
            VStack(spacing: 2) {
                menuRow(icon: "person.fill", label: "My Profile") { showingEditProfile = true }
                menuRow(icon: "chart.pie.fill", label: "Statistics") { showingStatistics = true }
                menuRow(icon: "gearshape.fill", label: "Settings") {}
                themeRow(profile)
                menuRow(icon: "bell.fill", label: "Notifications") { showingNotifications = true }
                menuRow(icon: "questionmark.circle.fill", label: "Help & Support") {}
                menuRow(icon: "info.circle.fill", label: "About App") {}
                menuRow(icon: "rectangle.portrait.and.arrow.right", label: "Logout", tint: .todoRed) {
                    showingLogoutConfirm = true
                }
            }
        }
    }

    private func menuRow(icon: String, label: String, tint: Color = .todoBlue, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(tint.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(tint)
                }
                Text(label)
                    .foregroundStyle(label == "Logout" ? tint : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }

    private func themeRow(_ profile: UserProfile) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.todoBlue.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: "moon.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.todoBlue)
            }
            Text("Theme")
            Spacer()
            Text(profile.isDarkMode ? "Dark" : "Light")
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
        .onTapGesture {
            profile.isDarkMode.toggle()
            try? modelContext.save()
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        return String(parts.prefix(2).compactMap { $0.first }).uppercased()
    }
}

struct EditProfileView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Name", text: $profile.name)
                    TextField("Email", text: $profile.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    TextField("Role", text: $profile.role)
                }
                Section("Preferences") {
                    Toggle("Dark Mode", isOn: $profile.isDarkMode)
                    Toggle("Notifications", isOn: $profile.notificationsEnabled)
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
