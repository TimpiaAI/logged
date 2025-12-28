import SwiftUI
import UserNotifications

@MainActor
@Observable
class RestTimerManager {
    var isActive = false
    var timeRemaining: TimeInterval = 0
    var defaultRestTime: TimeInterval = 90 // 1:30
    var autoStartEnabled = true // Auto-start timer after logging a set

    private var timer: Timer?
    private var endTime: Date?

    // Callback when timer completes
    var onTimerComplete: (() -> Void)?

    // MARK: - Timer Control

    func start(duration: TimeInterval? = nil) {
        timeRemaining = duration ?? defaultRestTime
        endTime = Date().addingTimeInterval(timeRemaining)
        isActive = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        scheduleNotification()

        // Update Live Activity (if available)
        WorkoutActivityManager.shared.startRestTimer(duration: timeRemaining)
    }

    func skip() {
        complete()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard let endTime = endTime else { return }
        timeRemaining = max(0, endTime.timeIntervalSinceNow)

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    // MARK: - Private Methods

    private func tick() {
        guard let endTime = endTime else { return }
        timeRemaining = max(0, endTime.timeIntervalSinceNow)

        if timeRemaining <= 0 {
            complete()
        }
    }

    private func complete() {
        timer?.invalidate()
        timer = nil
        isActive = false
        timeRemaining = 0
        endTime = nil

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Cancel any pending notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["restTimer"])

        // Update Live Activity (if available)
        WorkoutActivityManager.shared.stopRestTimer()

        // Callback
        onTimerComplete?()
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "rest over."
        content.body = "time for the next set"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: "restTimer", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Formatting

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard defaultRestTime > 0 else { return 0 }
        return 1 - (timeRemaining / defaultRestTime)
    }
}

// MARK: - Notification Permission
extension RestTimerManager {
    static func requestNotificationPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }
}

// MARK: - Workout Activity Manager (Live Activity)
import ActivityKit

// WorkoutActivityAttributes and WorkoutStatus are defined in Shared/WorkoutActivityAttributes.swift

@MainActor
@Observable
class WorkoutActivityManager {
    static let shared = WorkoutActivityManager()

    private var currentActivity: Activity<WorkoutActivityAttributes>?

    var isActivityActive: Bool {
        currentActivity != nil
    }

    func startWorkoutActivity(workoutName: String, emoji: String?) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

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
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

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
