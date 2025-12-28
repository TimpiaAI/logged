import SwiftUI
import SwiftData

// MARK: - Badge Model
struct Badge: Identifiable {
    let id: String
    let title: String
    let icon: String
    let requirement: String

    static let allBadges: [Badge] = [
        Badge(id: "first_workout", title: "First Rep", icon: "figure.strengthtraining.traditional", requirement: "Complete your first workout"),
        Badge(id: "week_streak", title: "Weekly Warrior", icon: "flame.fill", requirement: "Work out every day for a week"),
        Badge(id: "ten_workouts", title: "Committed", icon: "star.fill", requirement: "Complete 10 workouts"),
        Badge(id: "pr_crusher", title: "PR Crusher", icon: "trophy.fill", requirement: "Set 5 personal records"),
        Badge(id: "volume_king", title: "Volume King", icon: "chart.bar.fill", requirement: "Lift 100,000kg total"),
        Badge(id: "early_bird", title: "Early Bird", icon: "sunrise.fill", requirement: "Work out before 7am")
    ]
}

// MARK: - Badge Manager
struct BadgeManager {
    static func checkBadges(user: User, workouts: [Workout]) -> [Badge] {
        var newBadges: [Badge] = []
        let completedWorkouts = workouts.filter { $0.completedAt != nil }

        // First workout badge
        if !user.badges.contains("first_workout") && !completedWorkouts.isEmpty {
            if let badge = Badge.allBadges.first(where: { $0.id == "first_workout" }) {
                newBadges.append(badge)
            }
        }

        // 10 workouts badge
        if !user.badges.contains("ten_workouts") && completedWorkouts.count >= 10 {
            if let badge = Badge.allBadges.first(where: { $0.id == "ten_workouts" }) {
                newBadges.append(badge)
            }
        }

        // Volume king badge (100,000kg total)
        let totalVolume = completedWorkouts.flatMap { $0.sets }.reduce(0.0) { total, set in
            guard let weight = set.weight else { return total }
            return total + (weight * Double(set.reps))
        }
        if !user.badges.contains("volume_king") && totalVolume >= 100_000 {
            if let badge = Badge.allBadges.first(where: { $0.id == "volume_king" }) {
                newBadges.append(badge)
            }
        }

        return newBadges
    }
}

struct BoardTabView: View {
    @Query private var users: [User]
    @Query(sort: \Workout.completedAt, order: .reverse) private var workouts: [Workout]

    @State private var showAddFriends = false

    private var currentUser: User? { users.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
                    Text("progress")
                        .font(.loggedTitle)

                    Text("your journey so far")
                        .font(.loggedCaption)
                        .foregroundStyle(.secondary)
                }

                if let user = currentUser {
                    // Achievements Section
                    VStack(alignment: .leading, spacing: LoggedSpacing.m) {
                        HStack {
                            Text("achievements")
                                .font(.loggedCaption)
                                .foregroundStyle(.tertiary)
                                .tracking(0.5)
                            Spacer()
                            Text("\(user.badges.count)/\(Badge.allBadges.count)")
                                .font(.loggedCaption)
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: LoggedSpacing.m) {
                            ForEach(Array(Badge.allBadges.enumerated()), id: \.element.id) { index, badge in
                                BadgeView(badge: badge, isUnlocked: user.badges.contains(badge.id))
                                    .staggered(index: index, total: Badge.allBadges.count)
                            }
                        }
                    }
                    .padding(LoggedSpacing.l)
                    .background(Color.loggedCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                            .stroke(Color.loggedBorder, lineWidth: 0.5)
                    )

                    // Personal Records Section
                    VStack(alignment: .leading, spacing: LoggedSpacing.m) {
                        Text("estimated 1rm")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)
                            .tracking(0.5)

                        VStack(spacing: 0) {
                            PRRow(label: "bench press", value: getBestLift("bench"), isLast: false)
                            PRRow(label: "squat", value: getBestLift("squat"), isLast: false)
                            PRRow(label: "deadlift", value: getBestLift("deadlift"), isLast: false)
                            PRRow(label: "ohp", value: getBestLift("press"), isLast: true)
                        }
                    }
                    .padding(LoggedSpacing.l)
                    .background(Color.loggedCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                            .stroke(Color.loggedBorder, lineWidth: 0.5)
                    )
                }

                // Add friends button
                Button {
                    showAddFriends = true
                } label: {
                    HStack {
                        Image(systemName: "person.2")
                            .font(.system(size: 14))
                        Text("friends & leaderboard")
                        Spacer()
                        Text("soon")
                            .font(.loggedMicro)
                            .foregroundStyle(.tertiary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.tertiary)
                    }
                    .font(.loggedBody)
                    .foregroundStyle(.secondary)
                    .padding(LoggedSpacing.l)
                    .background(Color.loggedCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                            .stroke(Color.loggedBorder, lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(LoggedSpacing.xl)
        }
        .background(Color.loggedBackground)
        .sheet(isPresented: $showAddFriends) {
            AddFriendsSheet()
        }
        .onAppear {
            checkForNewBadges()
        }
    }

    private func checkForNewBadges() {
        guard let user = currentUser else { return }
        let newBadges = BadgeManager.checkBadges(user: user, workouts: workouts)

        if !newBadges.isEmpty {
            for badge in newBadges {
                user.badges.append(badge.id)
            }
        }
    }

    private func getBestLift(_ name: String) -> String {
        var maxWeight: Double = 0
        var maxReps: Int = 0

        for workout in workouts {
            for set in workout.sets {
                if set.exerciseName.localizedCaseInsensitiveContains(name) {
                    if let weight = set.weight, weight > maxWeight {
                        maxWeight = weight
                        maxReps = set.reps
                    }
                }
            }
        }

        if maxWeight > 0 {
            // Brzycki formula for estimated 1RM
            let e1rm = maxWeight * (36.0 / (37.0 - Double(maxReps)))
            return "\(Int(e1rm))kg"
        }
        return "--"
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let badge: Badge
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: LoggedSpacing.s) {
            ZStack {
                RoundedRectangle(cornerRadius: LoggedCornerRadius.m, style: .continuous)
                    .fill(isUnlocked ? Color.loggedAccent.opacity(0.1) : Color.loggedBackground)
                    .frame(width: 56, height: 56)

                Image(systemName: badge.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isUnlocked ? Color.loggedAccent : Color.loggedBorder)
            }

            Text(badge.title.lowercased())
                .font(.loggedMicro)
                .multilineTextAlignment(.center)
                .foregroundStyle(isUnlocked ? .primary : .tertiary)
                .lineLimit(2)
        }
        .opacity(isUnlocked ? 1 : 0.6)
    }
}

// MARK: - PR Row
struct PRRow: View {
    let label: String
    let value: String
    var isLast: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.loggedBody)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.loggedBody)
                .fontWeight(.semibold)
                .foregroundStyle(value == "--" ? Color.secondary : Color.loggedPR)
        }
        .padding(.vertical, LoggedSpacing.s)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(Color.loggedBorder.opacity(0.5))
                    .frame(height: 0.5)
            }
        }
    }
}

// MARK: - Add Friends Sheet
struct AddFriendsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                Text("add friends")
                    .font(.loggedTitle)

                VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                    Text("search by username")
                        .font(.loggedCaption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("username", text: $searchText)
                            .font(.loggedBody)
                    }
                    .padding(LoggedSpacing.l)
                    .background(Color.loggedCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: LoggedCornerRadius.m, style: .continuous)
                            .stroke(Color.loggedBorder, lineWidth: 0.5)
                    )
                }

                Spacer()

                Text("leaderboard requires a logged account. coming soon.")
                    .font(.loggedCaption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(LoggedSpacing.xl)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    BoardTabView()
        .modelContainer(for: [User.self, WorkoutCard.self, Workout.self, WorkoutSet.self, Exercise.self], inMemory: true)
}
