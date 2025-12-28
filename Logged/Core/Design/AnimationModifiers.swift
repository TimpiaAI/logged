import SwiftUI

// MARK: - Staggered Appearance
struct StaggeredWrapper<Content: View>: View {
    var content: Content
    var index: Int
    var total: Int
    
    @State private var offset: CGFloat = 20
    @State private var opacity: Double = 0
    
    init(index: Int, total: Int, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.index = index
        self.total = total
    }
    
    var body: some View {
        content
            .opacity(opacity)
            .offset(y: offset)
            .onAppear {
                let delay = Double(index) * 0.05
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}

// MARK: - Press Scale Button Style
struct PressMapStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func staggered(index: Int, total: Int) -> some View {
        StaggeredWrapper(index: index, total: total) {
            self
        }
    }
    
    func pressableScale() -> some View {
        self.buttonStyle(PressMapStyle())
    }
}
