import Foundation
import SwiftData

@Model
final class WorkoutCard {
    var title: String
    var emoji: String?
    var color: String?

    // Ordering
    var sortOrder: Int

    // Stats (denormalized for performance)
    var lastUsedAt: Date?
    var timesUsed: Int = 0

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Workout.card)
    var workouts: [Workout] = []

    // Timestamps
    var createdAt: Date
    var updatedAt: Date

    init(
        title: String,
        emoji: String? = nil,
        color: String? = nil,
        sortOrder: Int = 0
    ) {
        self.title = title
        self.emoji = emoji
        self.color = color
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    var displayTitle: String {
        if let emoji = emoji {
            return "\(emoji) \(title)"
        }
        return title
    }

    var recentWorkouts: [Workout] {
        workouts
            .filter { $0.completedAt != nil }
            .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
            .prefix(5)
            .map { $0 }
    }
}
