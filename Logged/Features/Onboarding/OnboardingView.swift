import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            // Dark background
            Color.loggedBackground
                .ignoresSafeArea()

            VStack {
                // Progress dots
                ProgressDots(current: viewModel.currentStep, total: viewModel.totalSteps)
                    .padding(.top, 20)

                Spacer()

                // Current step content
                Group {
                    switch viewModel.currentStep {
                    case 0: WelcomeStep(onContinue: viewModel.nextStep)
                    case 1: NameStep(name: $viewModel.name, onContinue: viewModel.nextStep)
                    case 2: GenderStep(gender: $viewModel.gender, name: viewModel.name, onSelect: viewModel.nextStep)
                    case 3: AgeStep(age: $viewModel.age, onContinue: viewModel.nextStep)
                    case 4: UnitsStep(units: $viewModel.units, onSelect: viewModel.nextStep)
                    case 5: BodyweightStep(weight: $viewModel.bodyweight, units: viewModel.units, onContinue: viewModel.nextStep)
                    case 6: ExperienceStep(experience: $viewModel.experience, onSelect: viewModel.nextStep)
                    case 7: GoalStep(goal: $viewModel.goal, onSelect: viewModel.nextStep)
                    case 8: FrequencyStep(frequency: $viewModel.frequency, onSelect: viewModel.nextStep)
                    case 9: SummaryStep(viewModel: viewModel) {
                        completeOnboarding()
                    }
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, LoggedSpacing.xxl)

                Spacer()
                Spacer()
            }
        }
    }

    private func completeOnboarding() {
        // Create user in SwiftData
        let user = User(
            name: viewModel.name,
            gender: viewModel.gender?.rawValue,
            age: Int(viewModel.age),
            bodyweight: Double(viewModel.bodyweight),
            units: viewModel.units.rawValue,
            experience: viewModel.experience?.rawIdentifier,
            goal: viewModel.goal?.rawIdentifier,
            frequency: viewModel.frequency
        )
        modelContext.insert(user)

        // Seed default exercises
        Exercise.seedDefaults(in: modelContext)

        // Mark onboarding complete
        hasCompletedOnboarding = true
    }
}

// MARK: - Progress Dots
struct ProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.loggedAccent : Color.secondary.opacity(0.3))
                    .frame(width: index == current ? 20 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [User.self, WorkoutCard.self, Workout.self, WorkoutSet.self, Exercise.self], inMemory: true)
}
