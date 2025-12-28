import SwiftUI

struct ExperienceStep: View {
    @Binding var experience: User.Experience?
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            Text("how long have you been lifting?")
                .font(.loggedTitle)

            VStack(spacing: LoggedSpacing.m) {
                ForEach(User.Experience.allCases, id: \.self) { option in
                    ChoiceButton(title: option.rawValue) {
                        experience = option
                        onSelect()
                    }
                }
            }
            .padding(.top, LoggedSpacing.xl)
        }
    }
}

#Preview {
    ExperienceStep(experience: .constant(nil)) { }
}
