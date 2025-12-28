import SwiftUI

struct UnitsStep: View {
    @Binding var units: User.Units
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            Text("kg or lbs?")
                .font(.loggedTitle)

            Text("you can change this later in settings")
                .font(.loggedCallout)
                .foregroundStyle(.secondary)

            VStack(spacing: LoggedSpacing.m) {
                ForEach(User.Units.allCases, id: \.self) { option in
                    ChoiceButton(title: option.displayName) {
                        units = option
                        onSelect()
                    }
                }
            }
            .padding(.top, LoggedSpacing.xl)
        }
    }
}

#Preview {
    UnitsStep(units: .constant(.kg)) { }
}
