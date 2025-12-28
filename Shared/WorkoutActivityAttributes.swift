import ActivityKit
import Foundation

// Shared between main app and widget extension
public struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var timerEndDate: Date?
        public var timerDuration: TimeInterval
        public var isTimerRunning: Bool
        public var currentExercise: String
        public var setsCompleted: Int
        public var totalVolume: Int
        public var workoutStatus: WorkoutStatus

        public init(
            timerEndDate: Date? = nil,
            timerDuration: TimeInterval = 0,
            isTimerRunning: Bool = false,
            currentExercise: String = "",
            setsCompleted: Int = 0,
            totalVolume: Int = 0,
            workoutStatus: WorkoutStatus = .active
        ) {
            self.timerEndDate = timerEndDate
            self.timerDuration = timerDuration
            self.isTimerRunning = isTimerRunning
            self.currentExercise = currentExercise
            self.setsCompleted = setsCompleted
            self.totalVolume = totalVolume
            self.workoutStatus = workoutStatus
        }
    }

    public var workoutName: String
    public var workoutEmoji: String?
    public var startTime: Date

    public init(workoutName: String, workoutEmoji: String? = nil, startTime: Date = Date()) {
        self.workoutName = workoutName
        self.workoutEmoji = workoutEmoji
        self.startTime = startTime
    }
}

public enum WorkoutStatus: String, Codable, Hashable {
    case active = "active"
    case resting = "resting"
    case completed = "completed"
}
