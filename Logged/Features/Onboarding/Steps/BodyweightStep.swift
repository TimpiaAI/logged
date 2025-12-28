import SwiftUI

struct BodyweightStep: View {
    @Binding var weight: String
    let units: User.Units
    let onContinue: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.xxl) {
            Text("current bodyweight?")
                .font(.loggedTitle)

            HStack(alignment: .firstTextBaseline) {
                TextField("", text: $weight)
                    .font(.loggedLargeTitle)
                    .textFieldStyle(.plain)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .frame(width: 100)

                Text(units.displayName)
                    .font(.loggedBody)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, LoggedSpacing.s)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 2)
            }

            Text("used for strength benchmarks")
                .font(.loggedCaption)
                .foregroundStyle(.tertiary)

            LoggedButton(
                title: "continue",
                action: onContinue,
                isEnabled: !weight.isEmpty && Double(weight) != nil
            )
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    BodyweightStep(weight: .constant(""), units: .kg) { }
}
