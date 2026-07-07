import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    let hasExistingAccount: Bool

    @State private var mode: Mode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isAnimatingIn = false
    @FocusState private var focusedField: Field?

    enum Mode { case login, signUp }
    enum Field { case name, email, password, confirmPassword }

    init(hasExistingAccount: Bool) {
        self.hasExistingAccount = hasExistingAccount
        _mode = State(initialValue: hasExistingAccount ? .login : .signUp)
    }

    var body: some View {
        ZStack {
            AnimatedAuthBackdrop()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 40)
                    brandHeader
                    formCard
                    switchModeFooter
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .opacity(isAnimatingIn ? 1 : 0)
        .scaleEffect(isAnimatingIn ? 1 : 0.96)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { isAnimatingIn = true }
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient.heroGradient)
                    .frame(width: 84, height: 84)
                    .shadow(color: Color.todoBlue.opacity(0.4), radius: 20, y: 10)
                Image(systemName: "checklist")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(mode == .login ? "Welcome Back" : "Create Account")
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text(mode == .login ? "Sign in to continue to your tasks" : "Let's set up your task workspace")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    private var formCard: some View {
        GlassEffectContainer {
            VStack(spacing: 16) {
                if mode == .signUp {
                    fieldRow(icon: "person.fill", placeholder: "Full name", text: $name, field: .name)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                fieldRow(icon: "envelope.fill", placeholder: "Email address", text: $email, field: .email, keyboard: .emailAddress)
                secureFieldRow(icon: "lock.fill", placeholder: "Password", text: $password, field: .password)
                if mode == .signUp {
                    secureFieldRow(icon: "lock.fill", placeholder: "Confirm password", text: $confirmPassword, field: .confirmPassword)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.todoRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                Button(action: submit) {
                    Text(mode == .login ? "Sign In" : "Create Account")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .glassButton(tint: .todoBlue)
                .padding(.top, 4)
            }
            .padding(20)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: mode)
    }

    private func fieldRow(icon: String, placeholder: String, text: Binding<String>, field: Field, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.todoBlue)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(field == .email ? .never : .words)
                .autocorrectionDisabled()
                .focused($focusedField, equals: field)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }

    private func secureFieldRow(icon: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.todoBlue)
                .frame(width: 20)
            SecureField(placeholder, text: text)
                .focused($focusedField, equals: field)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }

    private var switchModeFooter: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                mode = (mode == .login) ? .signUp : .login
                errorMessage = nil
            }
        } label: {
            HStack(spacing: 4) {
                Text(mode == .login ? "Don't have an account?" : "Already have an account?")
                    .foregroundStyle(.secondary)
                Text(mode == .login ? "Sign Up" : "Sign In")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.todoBlue)
            }
            .font(.subheadline)
        }
        .buttonStyle(.plain)
    }

    private func submit() {
        focusedField = nil
        errorMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 4 else {
            errorMessage = "Password must be at least 4 characters."
            return
        }

        switch mode {
        case .login:
            guard let match = profiles.first(where: { $0.email.lowercased() == trimmedEmail }) else {
                errorMessage = "No account found with that email."
                return
            }
            guard match.verifyPassword(password) else {
                errorMessage = "Incorrect password."
                return
            }
            withAnimation { match.isLoggedIn = true }
            try? modelContext.save()

        case .signUp:
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                errorMessage = "Please enter your name."
                return
            }
            guard password == confirmPassword else {
                errorMessage = "Passwords don't match."
                return
            }
            guard !profiles.contains(where: { $0.email.lowercased() == trimmedEmail }) else {
                errorMessage = "An account with that email already exists."
                return
            }
            let newProfile = UserProfile(name: trimmedName, email: trimmedEmail, role: "Product Manager", password: password, isLoggedIn: true)
            modelContext.insert(newProfile)
            try? modelContext.save()
        }
    }
}

struct AnimatedAuthBackdrop: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.screenBackground.ignoresSafeArea()
            Circle()
                .fill(LinearGradient.heroGradient)
                .frame(width: 380, height: 380)
                .blur(radius: 100)
                .opacity(0.5)
                .offset(x: animate ? -120 : -160, y: animate ? -300 : -260)
            Circle()
                .fill(Color.todoPurple)
                .frame(width: 320, height: 320)
                .blur(radius: 100)
                .opacity(0.35)
                .offset(x: animate ? 160 : 120, y: animate ? -120 : -160)
            Circle()
                .fill(Color.todoPink)
                .frame(width: 300, height: 300)
                .blur(radius: 110)
                .opacity(0.28)
                .offset(x: animate ? 100 : 140, y: animate ? 460 : 420)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
