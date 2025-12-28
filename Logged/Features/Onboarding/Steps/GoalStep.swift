import SwiftUI

struct GoalStep: View {
    @Binding var goal: User.Goal?
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            Text("main goal?")
                .font(.loggedTitle)

            VStack(spacing: LoggedSpacing.m) {
                ForEach(User.Goal.allCases, id: \.self) { option in
                    ChoiceButton(title: option.rawValue) {
                        goal = option
                        onSelect()
                    }
                }
            }
            .padding(.top, LoggedSpacing.xl)
        }
    }
}

#Preview {
    GoalStep(goal: .constant(nil)) { }
}
