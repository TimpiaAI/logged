import SwiftUI

struct WelcomeStep: View {
    let onContinue: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: LoggedSpacing.l) {
            TypewriterText(text: "hey.") {
                withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                    showContent = true
                }
            }

            Text("let's set up your log.")
                .font(.loggedBody)
                .foregroundStyle(.secondary)
                .animatedContent(isVisible: showContent)

            LoggedButton(title: "let's go", action: onContinue)
                .padding(.top, LoggedSpacing.xxl)
                .animatedContent(isVisible: showContent, delay: 0.1)
        }
    }
}

#Preview {
    WelcomeStep { }
}
