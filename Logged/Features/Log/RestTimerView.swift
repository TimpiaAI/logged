import SwiftUI

struct RestTimerView: View {
    @Bindable var timerManager: RestTimerManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("rest")
                    .font(.loggedMicro)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(timerManager.formattedTime)
                    .font(.loggedLargeTitle)
                    .fontWeight(.light)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            Spacer()

            Button("skip") {
                timerManager.skip()
            }
            .font(.loggedCallout)
            .foregroundStyle(.secondary)
        }
        .padding(LoggedSpacing.l)
        .glassEffect()
    }
}

// MARK: - Compact Timer View (for toolbar)
struct CompactRestTimerView: View {
    @Bindable var timerManager: RestTimerManager

    var body: some View {
        if timerManager.isActive {
            HStack(spacing: LoggedSpacing.s) {
                Circle()
                    .fill(Color.loggedAccent)
                    .frame(width: 8, height: 8)

                Text(timerManager.formattedTime)
                    .font(.loggedCaption)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, LoggedSpacing.m)
            .padding(.vertical, LoggedSpacing.s)
            .glassEffect()
            .onTapGesture {
                timerManager.skip()
            }
        }
    }
}

// MARK: - Timer Start Button
struct RestTimerStartButton: View {
    @Bindable var timerManager: RestTimerManager
    var duration: TimeInterval = 90

    var body: some View {
        Button {
            if timerManager.isActive {
                timerManager.skip()
            } else {
                timerManager.start(duration: duration)
            }
        } label: {
            HStack(spacing: LoggedSpacing.s) {
                Image(systemName: timerManager.isActive ? "stop.fill" : "timer")
                    .font(.system(size: 14))

                if timerManager.isActive {
                    Text(timerManager.formattedTime)
                        .font(.loggedCaption)
                        .monospacedDigit()
                } else {
                    Text("rest")
                        .font(.loggedCaption)
                }
            }
            .padding(.horizontal, LoggedSpacing.m)
            .padding(.vertical, LoggedSpacing.s)
        }
        .buttonStyle(.loggedGlass)
    }
}

// MARK: - Timer Preset Button
struct TimerPresetButton: View {
    let seconds: Int
    @Bindable var timerManager: RestTimerManager

    var body: some View {
        Button {
            timerManager.start(duration: TimeInterval(seconds))
        } label: {
            Text(formattedTime)
                .font(.loggedMicro)
                .foregroundStyle(.secondary)
                .padding(.horizontal, LoggedSpacing.s)
                .padding(.vertical, LoggedSpacing.xs)
                .background(Color.loggedCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))
                .overlay(
                    RoundedRectangle(cornerRadius: LoggedCornerRadius.s)
                        .stroke(Color.loggedBorder, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }

    private var formattedTime: String {
        let minutes = seconds / 60
        let secs = seconds % 60
        if secs == 0 {
            return "\(minutes)m"
        }
        return "\(minutes):\(String(format: "%02d", secs))"
    }
}

#Preview("Rest Timer View") {
    let manager = RestTimerManager()
    manager.isActive = true
    manager.defaultRestTime = 90

    return RestTimerView(timerManager: manager)
        .padding()
}

#Preview("Start Button") {
    RestTimerStartButton(timerManager: RestTimerManager())
        .padding()
}
