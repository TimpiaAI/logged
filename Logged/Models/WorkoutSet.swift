import Foundation
import SwiftData

@Model
final class WorkoutSet {
    // Relationships
    var workout: Workout?
    var exercise: Exercise?

    // Exercise name (in case exercise is null)
    var exerciseName: String

    // Set data
    var setNumber: Int
    var weight: Double?
    var weightUnit: String = "kg"
    var reps: Int

    // Flags
    var isBodyweight: Bool = false
    var isPR: Bool = false

    // Notes
    var notes: String?

    // Timestamp
    var createdAt: Date

    init(
        workout: Workout? = nil,
        exerciseName: String,
        setNumber: Int,
        weight: Double? = nil,
        weightUnit: String = "kg",
        reps: Int,
        isBodyweight: Bool = false,
        notes: String? = nil
    ) {
        self.workout = workout
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.weight = weight
        self.weightUnit = weightUnit
        self.reps = reps
        self.isBodyweight = isBodyweight
        self.notes = notes
        self.createdAt = Date()
    }

    // MARK: - Computed Properties

    var volume: Double {
        guard let weight = weight else { return 0 }
        return weight * Double(reps)
    }

    var formattedWeight: String {
        if isBodyweight {
            return "BW"
        }
        guard let weight = weight else { return "--" }
        return "\(Int(weight))\(weightUnit)"
    }

    var formattedSet: String {
        "\(formattedWeight) × \(reps)"
    }
}
