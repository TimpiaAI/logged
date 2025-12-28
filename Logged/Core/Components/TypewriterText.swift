import SwiftUI

struct TypewriterText: View {
    let text: String
    var characterDelay: Double = 0.08
    var onComplete: (() -> Void)? = nil

    @State private var displayedText = ""
    @State private var showCursor = true
    @State private var isComplete = false
    @State private var cursorTimer: Timer?

    var body: some View {
        HStack(spacing: 0) {
            Text(displayedText)
                .font(.loggedLargeTitle)

            if !isComplete {
                Text("|")
                    .font(.loggedLargeTitle)
                    .foregroundStyle(Color.loggedAccent)
                    .opacity(showCursor ? 1 : 0)
            }
        }
        .task {
            await startTyping()
        }
        .onAppear {
            startCursorBlink()
        }
        .onDisappear {
            cursorTimer?.invalidate()
        }
    }

    private func startTyping() async {
        displayedText = ""
        for character in text {
            try? await Task.sleep(for: .milliseconds(Int(characterDelay * 1000)))
            displayedText += String(character)
        }

        try? await Task.sleep(for: .milliseconds(500))
        withAnimation(.easeIn(duration: 0.3)) {
            isComplete = true
        }
        cursorTimer?.invalidate()
        onComplete?()
    }

    private func startCursorBlink() {
        cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                if !isComplete {
                    showCursor.toggle()
                }
            }
        }
    }
}

// MARK: - Animated Content Modifier
struct AnimatedContent: ViewModifier {
    let isVisible: Bool
    var delay: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(delay), value: isVisible)
    }
}

extension View {
    func animatedContent(isVisible: Bool, delay: Double = 0) -> some View {
        modifier(AnimatedContent(isVisible: isVisible, delay: delay))
    }
}

#Preview {
    VStack {
        TypewriterText(text: "hey.") {
            print("complete!")
        }
    }
    .padding()
}
