import SwiftUI

@Observable
class OnboardingViewModel {
    // Current step
    var currentStep = 0

    // Collected data
    var name = ""
    var gender: User.Gender?
    var age = ""
    var units: User.Units = .kg
    var bodyweight = ""
    var experience: User.Experience?
    var goal: User.Goal?
    var frequency = 4

    // State
    var isLoading = false
    var error: Error?

    var totalSteps: Int { 10 }

    var canProceed: Bool {
        switch currentStep {
        case 0: return true // Welcome
        case 1: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return gender != nil
        case 3: return !age.isEmpty && Int(age) != nil
        case 4: return true // Units always has default
        case 5: return !bodyweight.isEmpty && Double(bodyweight) != nil
        case 6: return experience != nil
        case 7: return goal != nil
        case 8: return true // Frequency always has default
        case 9: return true // Summary
        default: return false
        }
    }

    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }

    func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }
}
