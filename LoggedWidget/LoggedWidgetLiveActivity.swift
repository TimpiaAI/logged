import ActivityKit
import WidgetKit
import SwiftUI

struct LoggedWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock Screen / Banner view
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        if let emoji = context.attributes.workoutEmoji {
                            Text(emoji)
                                .font(.title2)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.workoutName.lowercased())
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("\(context.state.setsCompleted) sets")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isTimerRunning, let endDate = context.state.timerEndDate {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("rest")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(timerInterval: Date()...endDate, countsDown: true)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                                .foregroundStyle(.green)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("volume")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(context.state.totalVolume)kg")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        }
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.currentExercise.lowercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        // Timer progress or workout duration
                        if context.state.isTimerRunning, let endDate = context.state.timerEndDate {
                            ProgressView(
                                timerInterval: Date()...endDate,
                                countsDown: true
                            ) {
                                EmptyView()
                            }
                            .progressViewStyle(.linear)
                            .tint(.green)
                        } else {
                            // Show elapsed time
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                Text(context.attributes.startTime, style: .timer)
                                    .font(.caption)
                                    .monospacedDigit()
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Compact leading
                if context.state.isTimerRunning {
                    Image(systemName: "timer")
                        .foregroundStyle(.green)
                } else if let emoji = context.attributes.workoutEmoji {
                    Text(emoji)
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(.green)
                }
            } compactTrailing: {
                // Compact trailing
                if context.state.isTimerRunning, let endDate = context.state.timerEndDate {
                    Text(timerInterval: Date()...endDate, countsDown: true)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(.green)
                        .frame(minWidth: 40)
                } else {
                    Text("\(context.state.setsCompleted)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
            } minimal: {
                // Minimal view (when another activity takes priority)
                if context.state.isTimerRunning {
                    Image(systemName: "timer")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenView: View {
    let context: ActivityViewContext<WorkoutActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Left: Workout info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if let emoji = context.attributes.workoutEmoji {
                        Text(emoji)
                            .font(.title3)
                    }
                    Text(context.attributes.workoutName.lowercased())
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Text(context.state.currentExercise.lowercased())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right: Timer or stats
            if context.state.isTimerRunning, let endDate = context.state.timerEndDate {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("rest")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timerInterval: Date()...endDate, countsDown: true)
                        .font(.title)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(.green)
                }
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(context.state.setsCompleted)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("sets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("\(context.state.totalVolume)kg")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Previews
#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: WorkoutActivityAttributes(workoutName: "Push Day", workoutEmoji: "💪", startTime: Date())) {
    LoggedWidgetLiveActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState(
        timerEndDate: nil,
        timerDuration: 0,
        isTimerRunning: false,
        currentExercise: "Bench Press",
        setsCompleted: 5,
        totalVolume: 1250,
        workoutStatus: .active
    )
}

#Preview("Dynamic Island Timer", as: .dynamicIsland(.expanded), using: WorkoutActivityAttributes(workoutName: "Push Day", workoutEmoji: "💪", startTime: Date())) {
    LoggedWidgetLiveActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState(
        timerEndDate: Date().addingTimeInterval(90),
        timerDuration: 90,
        isTimerRunning: true,
        currentExercise: "Bench Press",
        setsCompleted: 5,
        totalVolume: 1250,
        workoutStatus: .resting
    )
}
