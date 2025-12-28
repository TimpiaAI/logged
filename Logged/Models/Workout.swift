import Foundation
import SwiftData

@Model
final class Workout {
    // Relationships
    var card: WorkoutCard?

    // Raw text (what user typed)
    var rawText: String = ""

    // Metadata
    var startedAt: Date
    var completedAt: Date?
    var durationSeconds: Int?

    // Stats (denormalized)
    var exerciseCount: Int = 0
    var setCount: Int = 0
    var totalVolume: Double = 0

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workout)
    var sets: [WorkoutSet] = []

    // Timestamps
    var createdAt: Date
    var updatedAt: Date

    init(card: WorkoutCard? = nil) {
        self.card = card
        self.startedAt = Date()
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func calculateStats() {
        // Parse raw text and update stats
        let parsed = WorkoutParser.parse(text: rawText)

        exerciseCount = parsed.count
        setCount = parsed.reduce(0) { $0 + $1.sets.count }
        totalVolume = parsed.reduce(0.0) { total, exercise in
            guard let weight = exercise.weight else { return total }
            let repsSum = exercise.sets.reduce(0, +)
            return total + (weight * Double(repsSum))
        }

        // Calculate duration
        if let completedAt = completedAt {
            durationSeconds = Int(completedAt.timeIntervalSince(startedAt))
        }

        // Update card stats
        card?.timesUsed += 1
        card?.lastUsedAt = completedAt ?? Date()
    }

    var formattedDuration: String {
        guard let seconds = durationSeconds else { return "--" }
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}
