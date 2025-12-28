import SwiftUI

struct SummaryStep: View {
    let viewModel: OnboardingViewModel
    let onComplete: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: LoggedSpacing.xl) {
            TypewriterText(text: "you're in.") {
                withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                    showContent = true
                }
            }

            VStack(alignment: .leading, spacing: LoggedSpacing.m) {
                summaryRow(label: "name", value: viewModel.name.lowercased())
                summaryRow(label: "goal", value: viewModel.goal?.rawValue ?? "-")
                summaryRow(label: "frequency", value: "\(viewModel.frequency)x/week")
                summaryRow(label: "units", value: viewModel.units.displayName)

                if let weight = Double(viewModel.bodyweight) {
                    summaryRow(label: "bodyweight", value: "\(Int(weight))\(viewModel.units.displayName)")
                }
            }
            .padding(LoggedSpacing.l)
            .glassEffect()
            .animatedContent(isVisible: showContent)

            LoggedButton(title: "start logging", action: onComplete)
                .animatedContent(isVisible: showContent, delay: 0.1)
        }
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.loggedCaption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.loggedBody)
        }
    }
}

#Preview {
    let vm = OnboardingViewModel()
    vm.name = "Ovidiu"
    vm.goal = .strength
    vm.frequency = 4
    vm.units = .kg
    vm.bodyweight = "80"

    return SummaryStep(viewModel: vm) { }
}
