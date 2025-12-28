import SwiftUI

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(LoggedSpacing.l)
            .glassEffect()
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let label: String
    let value: String
    var suffix: String? = nil
    var tint: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
            Text(label.uppercased())
                .font(.loggedMicro)
                .foregroundStyle(.secondary)
                .tracking(1)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                    .foregroundStyle(tint ?? .primary)
                    .contentTransition(.numericText(value: Double(value) ?? 0))

                if let suffix = suffix {
                    Text(suffix)
                        .font(.loggedCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, LoggedSpacing.l)
        .padding(.vertical, LoggedSpacing.m)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Primary Button
struct LoggedButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
                action()
            }
        }) {
            Text(title)
                .font(.loggedBody)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.loggedAccent)
                .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
    }
}

// MARK: - Choice Button (for onboarding selections)
struct ChoiceButton: View {
    let title: String
    var emoji: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 18))
                }
                Text(title)
                    .font(.loggedBody)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color.loggedCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
            .overlay(
                RoundedRectangle(cornerRadius: LoggedCornerRadius.m)
                    .stroke(Color.loggedBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workout Card View
struct WorkoutCardView: View {
    let title: String
    let emoji: String?
    let lastUsed: Date?
    let workoutCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            HStack {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 20))
                }
                Spacer()
                Text("\(workoutCount)")
                    .font(.loggedCaption)
                    .foregroundStyle(.tertiary)
            }

            Text(title.lowercased())
                .font(.loggedHeadline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            if let lastUsed = lastUsed {
                Text(lastUsed.formatted(.relative(presentation: .named)))
                    .font(.loggedMicro)
                    .foregroundStyle(.tertiary)
            } else {
                Text("never used")
                    .font(.loggedMicro)
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(LoggedSpacing.l)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                .stroke(Color.loggedBorder.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil

    var body: some View {
        VStack(spacing: LoggedSpacing.l) {
            Text(title.lowercased())
                .font(.loggedTitle)

            Text(message.lowercased())
                .font(.loggedBody)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let action = action, let actionTitle = actionTitle {
                LoggedButton(title: actionTitle, action: action)
                    .padding(.top, LoggedSpacing.m)
            }
        }
        .padding(LoggedSpacing.xxl)
    }
}

#Preview("Stat Cards") {
    HStack {
        StatCard(label: "this week", value: "3", suffix: "/4")
        StatCard(label: "streak", value: "7", suffix: "days", tint: .loggedAccent)
    }
    .padding()
}

#Preview("Workout Card") {
    WorkoutCardView(
        title: "Push Day",
        emoji: "💪",
        lastUsed: Date().addingTimeInterval(-86400 * 2),
        workoutCount: 12
    )
    .padding()
}

#Preview("Buttons") {
    VStack(spacing: 16) {
        LoggedButton(title: "continue") { }
        ChoiceButton(title: "beginner", emoji: "🌱") { }
        ChoiceButton(title: "intermediate") { }
    }
    .padding()
}
