import Foundation
import SwiftData

@Model
final class User {
    var name: String
    var email: String?
    var avatarURL: String?
    
    // Customization
    var bio: String?
    var avatarColor: String? // Hex e.g., "#FF0000"
    var avatarEmoji: String? // e.g., "🦁"
    
    // Gamification
    var badges: [String] = [] // List of earned badge IDs

    // Metrics
    var gender: String?      // "male" or "female"
    var age: Int?
    var bodyweight: Double?  // in kg or lbs based on units
    var height: Int?         // in cm

    // Preferences
    var units: String = "kg" // "kg" or "lbs"
    var experience: String?  // "beginner", "intermediate", "advanced"
    var goal: String?        // "strength", "muscle", "lose", "track"
    var frequency: Int = 4   // workouts per week goal

    // Timestamps
    var createdAt: Date
    var updatedAt: Date

    init(
        name: String,
        email: String? = nil,
        gender: String? = nil,
        age: Int? = nil,
        bodyweight: Double? = nil,
        height: Int? = nil,
        units: String = "kg",
        experience: String? = nil,
        goal: String? = nil,
        frequency: Int = 4,
        bio: String? = nil,
        avatarColor: String? = nil,
        avatarEmoji: String? = nil,
        badges: [String] = []
    ) {
        self.name = name
        self.email = email
        self.gender = gender
        self.age = age
        self.bodyweight = bodyweight
        self.height = height
        self.units = units
        self.experience = experience
        self.goal = goal
        self.frequency = frequency
        self.bio = bio
        self.avatarColor = avatarColor
        self.avatarEmoji = avatarEmoji
        self.badges = badges
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Enums for User Properties
extension User {
    enum Gender: String, CaseIterable {
        case male, female

        var displayName: String {
            rawValue
        }
    }

    enum Units: String, CaseIterable {
        case kg, lbs

        var displayName: String {
            rawValue
        }
    }

    enum Experience: String, CaseIterable {
        case beginner = "< 1 year"
        case intermediate = "1-3 years"
        case advanced = "3+ years"

        var rawIdentifier: String {
            switch self {
            case .beginner: return "beginner"
            case .intermediate: return "intermediate"
            case .advanced: return "advanced"
            }
        }
    }

    enum Goal: String, CaseIterable {
        case strength = "get stronger"
        case muscle = "build muscle"
        case lose = "lose fat"
        case track = "just track"

        var rawIdentifier: String {
            switch self {
            case .strength: return "strength"
            case .muscle: return "muscle"
            case .lose: return "lose"
            case .track: return "track"
            }
        }
    }
}
