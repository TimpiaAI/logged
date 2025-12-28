import SwiftUI

struct FrequencyStep: View {
    @Binding var frequency: Int
    let onSelect: () -> Void

    private let options = [3, 4, 5, 6]

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            Text("workouts per week?")
                .font(.loggedTitle)

            Text("we'll track your progress against this goal")
                .font(.loggedCallout)
                .foregroundStyle(.secondary)

            VStack(spacing: LoggedSpacing.m) {
                ForEach(options, id: \.self) { option in
                    ChoiceButton(title: "\(option)x per week") {
                        frequency = option
                        onSelect()
                    }
                }
            }
            .padding(.top, LoggedSpacing.xl)
        }
    }
}

#Preview {
    FrequencyStep(frequency: .constant(4)) { }
}
