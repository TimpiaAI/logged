import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var aliases: [String] = []

    // Categorization
    var muscleGroup: String?   // "chest", "back", "legs", etc.
    var equipment: String?     // "barbell", "dumbbell", "bodyweight", etc.
    var movementType: String?  // "push", "pull", "legs", "core"

    // For benchmarking
    var hasStandards: Bool = false

    // Timestamp
    var createdAt: Date

    init(
        name: String,
        aliases: [String] = [],
        muscleGroup: String? = nil,
        equipment: String? = nil,
        movementType: String? = nil,
        hasStandards: Bool = false
    ) {
        self.name = name
        self.aliases = aliases
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.movementType = movementType
        self.hasStandards = hasStandards
        self.createdAt = Date()
    }
}

// MARK: - Default Exercises
extension Exercise {
    static let defaults: [(name: String, aliases: [String], muscleGroup: String, equipment: String, movementType: String, hasStandards: Bool)] = [
        // Chest
        ("Bench Press", ["bench", "bp", "flat bench"], "chest", "barbell", "push", true),
        ("Incline Bench Press", ["incline bench", "incline"], "chest", "barbell", "push", true),
        ("Dumbbell Press", ["db press", "dumbbell bench"], "chest", "dumbbell", "push", false),
        ("Push-ups", ["pushups", "push ups"], "chest", "bodyweight", "push", false),

        // Back
        ("Deadlift", ["dl", "dead"], "back", "barbell", "pull", true),
        ("Barbell Row", ["bb row", "bent over row", "row"], "back", "barbell", "pull", true),
        ("Pull-ups", ["pullups", "pull ups", "chinups"], "back", "bodyweight", "pull", false),
        ("Lat Pulldown", ["pulldown", "lat pull"], "back", "cable", "pull", false),

        // Legs
        ("Squat", ["squats", "back squat", "bs"], "legs", "barbell", "legs", true),
        ("Romanian Deadlift", ["rdl", "romanian dl"], "legs", "barbell", "legs", false),
        ("Leg Press", ["legpress"], "legs", "machine", "legs", false),
        ("Lunges", ["lunge", "fandări", "fandari"], "legs", "dumbbell", "legs", false),

        // Shoulders
        ("Overhead Press", ["ohp", "shoulder press", "military press"], "shoulders", "barbell", "push", true),
        ("Lateral Raises", ["lateral raise", "side raises", "lat raises"], "shoulders", "dumbbell", "push", false),
        ("Face Pulls", ["face pull", "facepulls"], "shoulders", "cable", "pull", false),

        // Arms
        ("Bicep Curls", ["curls", "bicep curl", "biceps"], "arms", "dumbbell", "pull", false),
        ("Tricep Pushdown", ["pushdown", "tricep pushdowns", "triceps"], "arms", "cable", "push", false),
        ("Skull Crushers", ["skullcrushers", "skull crusher"], "arms", "barbell", "push", false),
    ]

    static func seedDefaults(in context: ModelContext) {
        for exercise in defaults {
            let newExercise = Exercise(
                name: exercise.name,
                aliases: exercise.aliases,
                muscleGroup: exercise.muscleGroup,
                equipment: exercise.equipment,
                movementType: exercise.movementType,
                hasStandards: exercise.hasStandards
            )
            context.insert(newExercise)
        }
    }
}
