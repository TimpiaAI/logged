import SwiftUI

struct NameStep: View {
    @Binding var name: String
    let onContinue: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.xxl) {
            Text("what should i call you?")
                .font(.loggedTitle)

            TextField("your name", text: $name)
                .font(.loggedTitle)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .padding(.bottom, LoggedSpacing.s)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 2)
                }

            LoggedButton(
                title: "continue",
                action: onContinue,
                isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty
            )
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    NameStep(name: .constant("")) { }
}
