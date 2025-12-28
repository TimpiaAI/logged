import SwiftUI

struct GenderStep: View {
    @Binding var gender: User.Gender?
    let name: String
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            Text("hey \(name.lowercased()).")
                .font(.loggedTitle)

            Text("quick question for accurate stats:")
                .font(.loggedCallout)
                .foregroundStyle(.secondary)

            VStack(spacing: LoggedSpacing.m) {
                ForEach(User.Gender.allCases, id: \.self) { option in
                    ChoiceButton(title: option.displayName) {
                        gender = option
                        onSelect()
                    }
                }
            }
            .padding(.top, LoggedSpacing.xl)
        }
    }
}

#Preview {
    GenderStep(gender: .constant(nil), name: "Ovidiu") { }
}
