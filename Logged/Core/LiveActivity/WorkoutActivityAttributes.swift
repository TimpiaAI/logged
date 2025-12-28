import Foundation
import ActivityKit

// MARK: - Workout Activity Attributes
struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Timer state
        var timerEndDate: Date?
        var timerDuration: TimeInterval
        var isTimerRunning: Bool

        // Workout state
        var currentExercise: String
        var setsCompleted: Int
        var totalVolume: Int // in kg

        // Status
        var workoutStatus: WorkoutStatus
    }

    // Fixed attributes (don't change during activity)
    var workoutName: String
    var workoutEmoji: String?
    var startTime: Date
}

// MARK: - Workout Status
enum WorkoutStatus: String, Codable, Hashable {
    case active = "active"
    case resting = "resting"
    case completed = "completed"
}

// MARK: - Activity Manager
@Observable
class WorkoutActivityManager {
    static let shared = WorkoutActivityManager()

    private var currentActivity: Activity<WorkoutActivityAttributes>?

    var isActivityActive: Bool {
        currentActivity != nil
    }

    // Start a new workout activity
    func startWorkoutActivity(workoutName: String, emoji: String?) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not enabled")
            return
        }

        let attributes = WorkoutActivityAttributes(
            workoutName: workoutName,
            workoutEmoji: emoji,
            startTime: Date()
        )

        let initialState = WorkoutActivityAttributes.ContentState(
            timerEndDate: nil,
            timerDuration: 0,
            isTimerRunning: false,
            currentExercise: "starting...",
            setsCompleted: 0,
            totalVolume: 0,
            workoutStatus: .active
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            print("Started workout activity: \(activity.id)")
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

    // Update workout progress
    func updateWorkoutProgress(
        currentExercise: String,
        setsCompleted: Int,
        totalVolume: Int,
        status: WorkoutStatus = .active
    ) {
        guard let activity = currentActivity else { return }

        let updatedState = WorkoutActivityAttributes.ContentState(
            timerEndDate: activity.content.state.timerEndDate,
            timerDuration: activity.content.state.timerDuration,
            isTimerRunning: activity.content.state.isTimerRunning,
            currentExercise: currentExercise,
            setsCompleted: setsCompleted,
            totalVolume: totalVolume,
            workoutStatus: status
        )

        Task {
            await activity.update(.init(state: updatedState, staleDate: nil))
        }
    }

    // Start rest timer
    func startRestTimer(duration: TimeInterval) {
        guard let activity = currentActivity else { return }

        let endDate = Date().addingTimeInterval(duration)

        let updatedState = WorkoutActivityAttributes.ContentState(
            timerEndDate: endDate,
            timerDuration: duration,
            isTimerRunning: true,
            currentExercise: activity.content.state.currentExercise,
            setsCompleted: activity.content.state.setsCompleted,
            totalVolume: activity.content.state.totalVolume,
            workoutStatus: .resting
        )

        Task {
            await activity.update(.init(state: updatedState, staleDate: nil))
        }
    }

    // Stop rest timer
    func stopRestTimer() {
        guard let activity = currentActivity else { return }

        let updatedState = WorkoutActivityAttributes.ContentState(
            timerEndDate: nil,
            timerDuration: 0,
            isTimerRunning: false,
            currentExercise: activity.content.state.currentExercise,
            setsCompleted: activity.content.state.setsCompleted,
            totalVolume: activity.content.state.totalVolume,
            workoutStatus: .active
        )

        Task {
            await activity.update(.init(state: updatedState, staleDate: nil))
        }
    }

    // End workout activity
    func endWorkoutActivity() {
        guard let activity = currentActivity else { return }

        let finalState = WorkoutActivityAttributes.ContentState(
            timerEndDate: nil,
            timerDuration: 0,
            isTimerRunning: false,
            currentExercise: "completed!",
            setsCompleted: activity.content.state.setsCompleted,
            totalVolume: activity.content.state.totalVolume,
            workoutStatus: .completed
        )

        Task {
            await activity.end(
                .init(state: finalState, staleDate: nil),
                dismissalPolicy: .after(.now + 5)
            )
            await MainActor.run {
                currentActivity = nil
            }
        }
    }
}
