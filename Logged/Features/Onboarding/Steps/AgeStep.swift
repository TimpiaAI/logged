import SwiftUI

struct AgeStep: View {
    @Binding var age: String
    let onContinue: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.xxl) {
            Text("how old are you?")
                .font(.loggedTitle)

            HStack(alignment: .firstTextBaseline) {
                TextField("", text: $age)
                    .font(.loggedLargeTitle)
                    .textFieldStyle(.plain)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .frame(width: 80)

                Text("years")
                    .font(.loggedBody)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, LoggedSpacing.s)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 2)
            }

            LoggedButton(
                title: "continue",
                action: onContinue,
                isEnabled: !age.isEmpty && Int(age) != nil
            )
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    AgeStep(age: .constant("")) { }
}
