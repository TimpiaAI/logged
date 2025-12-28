import Foundation

// MARK: - Parsed Set (individual set with weight and reps)
struct ParsedSet: Equatable {
    let weight: Double?
    let reps: Int
}

// MARK: - Parsed Exercise
struct ParsedExercise: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let weight: Double? // Primary/common weight (for display)
    let isBodyweight: Bool
    let sets: [Int]
    let detailedSets: [ParsedSet]? // Optional detailed sets with individual weights
    let notes: String?

    static func == (lhs: ParsedExercise, rhs: ParsedExercise) -> Bool {
        lhs.id == rhs.id
    }

    // Convenience initializer for simple exercises
    init(name: String, weight: Double?, isBodyweight: Bool, sets: [Int], notes: String?) {
        self.name = name
        self.weight = weight
        self.isBodyweight = isBodyweight
        self.sets = sets
        self.detailedSets = nil
        self.notes = notes
    }

    // Full initializer with detailed sets
    init(name: String, weight: Double?, isBodyweight: Bool, sets: [Int], detailedSets: [ParsedSet]?, notes: String?) {
        self.name = name
        self.weight = weight
        self.isBodyweight = isBodyweight
        self.sets = sets
        self.detailedSets = detailedSets
        self.notes = notes
    }
}

// MARK: - Parsed Line
struct ParsedLine {
    let originalText: String
    let exercise: ParsedExercise?
    let isComment: Bool
}

// MARK: - Workout Parser
enum WorkoutParser {
    /// Parse workout text into structured exercises
    static func parse(text: String) -> [ParsedExercise] {
        let lines = text.components(separatedBy: "\n")
        return lines.compactMap { parseLine($0).exercise }
    }

    /// Parse a single line
    static func parseLine(_ line: String) -> ParsedLine {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Empty line
        guard !trimmed.isEmpty else {
            return ParsedLine(originalText: line, exercise: nil, isComment: false)
        }

        // Try to parse as exercise first (this handles lines with notes like ".... (note)")
        if let exercise = parseExercise(trimmed) {
            return ParsedLine(originalText: line, exercise: exercise, isComment: false)
        }

        // Comment line - only if it couldn't be parsed as an exercise and contains ....
        if trimmed.contains("....") {
            return ParsedLine(originalText: line, exercise: nil, isComment: true)
        }

        // Unknown format
        return ParsedLine(originalText: line, exercise: nil, isComment: false)
    }

    /// Parse an exercise line
    private static func parseExercise(_ text: String) -> ParsedExercise? {
        // Extract notes (anything after ....)
        var workingText = text
        var notes: String?

        if let noteRange = text.range(of: "....") {
            notes = String(text[noteRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            if notes?.hasPrefix("(") == true && notes?.hasSuffix(")") == true {
                notes = String(notes!.dropFirst().dropLast())
            }
            workingText = String(text[..<noteRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }

        // Normalize the text - handle multiple spaces, normalize separators
        workingText = normalizeInput(workingText)

        // Try different patterns (order matters - most specific first)
        if let result = tryMultiWeightFormat(workingText, notes: notes) {
            return result
        }
        if let result = tryStandardFormat(workingText, notes: notes) {
            return result
        }
        if let result = tryBodyweightFormat(workingText, notes: notes) {
            return result
        }
        if let result = trySetsTimesRepsFormat(workingText, notes: notes) {
            return result
        }
        if let result = tryWeightFirstFormat(workingText, notes: notes) {
            return result
        }
        if let result = tryImplicitBodyweightFormat(workingText, notes: notes) {
            return result
        }
        if let result = trySingleSetFormat(workingText, notes: notes) {
            return result
        }
        if let result = tryFlexibleFormat(workingText, notes: notes) {
            return result
        }

        return nil
    }

    // MARK: - Input Normalization
    private static func normalizeInput(_ text: String) -> String {
        var result = text

        // Normalize multiple spaces to single space
        while result.contains("  ") {
            result = result.replacingOccurrences(of: "  ", with: " ")
        }

        // Normalize "kg" variations (handle space before kg)
        result = result.replacingOccurrences(of: " kg", with: "kg", options: .caseInsensitive)
        result = result.replacingOccurrences(of: " lbs", with: "lbs", options: .caseInsensitive)
        result = result.replacingOccurrences(of: " lb", with: "lb", options: .caseInsensitive)

        return result
    }

    // MARK: - Pattern: Multiple weight/rep pairs "Exercise 10kg 13 / 34kg 12"
    private static func tryMultiWeightFormat(_ text: String, notes: String?) -> ParsedExercise? {
        // Look for pattern with "/" or "," separating weight-rep pairs
        // Example: "dumbell rows 10kg 13 / 34kg 12" or "bench 80kg 8, 70kg 10"

        // First, try to find the exercise name by looking for where numbers start
        guard let firstNumberIndex = text.firstIndex(where: { $0.isNumber }) else {
            return nil
        }

        let nameEndIndex = text.index(before: firstNumberIndex)
        var exerciseName = String(text[...nameEndIndex]).trimmingCharacters(in: .whitespaces)

        // Check if name ends with a number (could be part of exercise name like "lat pulldown")
        // We need to be smarter about this
        let restOfText = String(text[firstNumberIndex...])

        // Check if this contains separator for multiple sets
        let hasSeparator = restOfText.contains("/") || restOfText.contains(",")

        guard hasSeparator else { return nil }

        // Split by separators
        let setParts = restOfText
            .replacingOccurrences(of: ",", with: "/")
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard setParts.count >= 2 else { return nil }

        var detailedSets: [ParsedSet] = []
        var simpleSets: [Int] = []
        var primaryWeight: Double?

        for part in setParts {
            if let setData = parseWeightRepsPair(part) {
                detailedSets.append(ParsedSet(weight: setData.weight, reps: setData.reps))
                simpleSets.append(setData.reps)
                if primaryWeight == nil {
                    primaryWeight = setData.weight
                }
            }
        }

        guard !detailedSets.isEmpty else { return nil }

        return ParsedExercise(
            name: normalizeExerciseName(correctSpelling(exerciseName)),
            weight: primaryWeight,
            isBodyweight: primaryWeight == nil,
            sets: simpleSets,
            detailedSets: detailedSets,
            notes: notes
        )
    }

    /// Parse a weight/reps pair like "10kg 13" or "13" or "80 8"
    private static func parseWeightRepsPair(_ text: String) -> (weight: Double?, reps: Int)? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        // Pattern: "80kg 8" or "80 8" or just "8"
        let pattern = #"^(\d+(?:\.\d+)?)\s*(?:kg|lbs?|lb)?\s*(\d+)$"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
           match.numberOfRanges >= 3,
           let weightRange = Range(match.range(at: 1), in: trimmed),
           let repsRange = Range(match.range(at: 2), in: trimmed) {
            let weight = Double(trimmed[weightRange])
            let reps = Int(trimmed[repsRange]) ?? 0
            if reps > 0 {
                return (weight, reps)
            }
        }

        // Just a number (reps only)
        if let reps = Int(trimmed), reps > 0 {
            return (nil, reps)
        }

        // Pattern: "8x80kg" or "8 x 80"
        let reversePattern = #"^(\d+)\s*[x×]\s*(\d+(?:\.\d+)?)\s*(?:kg|lbs?|lb)?$"#
        if let regex = try? NSRegularExpression(pattern: reversePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
           match.numberOfRanges >= 3,
           let repsRange = Range(match.range(at: 1), in: trimmed),
           let weightRange = Range(match.range(at: 2), in: trimmed) {
            let reps = Int(trimmed[repsRange]) ?? 0
            let weight = Double(trimmed[weightRange])
            if reps > 0 {
                return (weight, reps)
            }
        }

        return nil
    }

    // MARK: - Pattern: "Exercise 80kg 8/8/6" or "Exercise 80 8/8/6"
    private static func tryStandardFormat(_ text: String, notes: String?) -> ParsedExercise? {
        // Pattern: name weight reps
        // Example: "Bench 80kg 8/8/6" or "Bench 80 8/8/6"
        let pattern = #"^(.+?)\s+(\d+(?:\.\d+)?)\s*(?:kg|lbs?)?\s+(\d+(?:[/,]\d+)+)$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges >= 4 else {
            return nil
        }

        guard let nameRange = Range(match.range(at: 1), in: text),
              let weightRange = Range(match.range(at: 2), in: text),
              let repsRange = Range(match.range(at: 3), in: text) else {
            return nil
        }

        let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        let weight = Double(text[weightRange])
        let repsString = String(text[repsRange])
        let sets = repsString
            .replacingOccurrences(of: ",", with: "/")
            .components(separatedBy: "/")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

        guard !sets.isEmpty else { return nil }

        return ParsedExercise(
            name: normalizeExerciseName(correctSpelling(name)),
            weight: weight,
            isBodyweight: false,
            sets: sets,
            notes: notes
        )
    }

    // MARK: - Pattern: "Exercise BW 10/8/7"
    private static func tryBodyweightFormat(_ text: String, notes: String?) -> ParsedExercise? {
        let pattern = #"^(.+?)\s+(?:BW|bw|bodyweight)\s+(\d+(?:[/,]\d+)+)$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges >= 3 else {
            return nil
        }

        guard let nameRange = Range(match.range(at: 1), in: text),
              let repsRange = Range(match.range(at: 2), in: text) else {
            return nil
        }

        let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        let repsString = String(text[repsRange])
        let sets = repsString
            .replacingOccurrences(of: ",", with: "/")
            .components(separatedBy: "/")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

        guard !sets.isEmpty else { return nil }

        return ParsedExercise(
            name: normalizeExerciseName(correctSpelling(name)),
            weight: nil,
            isBodyweight: true,
            sets: sets,
            notes: notes
        )
    }

    // MARK: - Pattern: "Exercise 3x5 140" or "Exercise 3x5 140kg"
    private static func trySetsTimesRepsFormat(_ text: String, notes: String?) -> ParsedExercise? {
        let pattern = #"^(.+?)\s+(\d+)[x×](\d+)\s+(\d+(?:\.\d+)?)\s*(?:kg|lbs?)?$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges >= 5 else {
            return nil
        }

        guard let nameRange = Range(match.range(at: 1), in: text),
              let setCountRange = Range(match.range(at: 2), in: text),
              let repsRange = Range(match.range(at: 3), in: text),
              let weightRange = Range(match.range(at: 4), in: text) else {
            return nil
        }

        let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        let setCount = Int(text[setCountRange]) ?? 0
        let reps = Int(text[repsRange]) ?? 0
        let weight = Double(text[weightRange])

        guard setCount > 0, reps > 0 else { return nil }

        return ParsedExercise(
            name: normalizeExerciseName(correctSpelling(name)),
            weight: weight,
            isBodyweight: false,
            sets: Array(repeating: reps, count: setCount),
            notes: notes
        )
    }

    // MARK: - Pattern: "Exercise 140 3x5" or "Exercise 140kg 3x5"
    private static func tryWeightFirstFormat(_ text: String, notes: String?) -> ParsedExercise? {
        let pattern = #"^(.+?)\s+(\d+(?:\.\d+)?)\s*(?:kg|lbs?)?\s+(\d+)[x×](\d+)$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges >= 5 else {
            return nil
        }

        guard let nameRange = Range(match.range(at: 1), in: text),
              let weightRange = Range(match.range(at: 2), in: text),
              let setCountRange = Range(match.range(at: 3), in: text),
              let repsRange = Range(match.range(at: 4), in: text) else {
            return nil
        }

        let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        let weight = Double(text[weightRange])
        let setCount = Int(text[setCountRange]) ?? 0
        let reps = Int(text[repsRange]) ?? 0

        guard setCount > 0, reps > 0 else { return nil }

        return ParsedExercise(
            name: normalizeExerciseName(correctSpelling(name)),
            weight: weight,
            isBodyweight: false,
            sets: Array(repeating: reps, count: setCount),
            notes: notes
        )
    }

    // MARK: - Pattern: "Exercise 10/8/7" (implicit bodyweight when no weight specified)
    private static func tryImplicitBodyweightFormat(_ text: String, notes: String?) -> ParsedExercise? {
        let pattern = #"^(.+?)\s+(\d+(?:[/,]\d+)+)$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges >= 3 else {
            return nil
        }

        guard let nameRange = Range(match.range(at: 1), in: text),
              let repsRange = Range(match.range(at: 2), in: text) else {
            return nil
        }

        let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        let repsString = String(text[repsRange])
        let sets = repsString
            .replacingOccurrences(of: ",", with: "/")
            .components(separatedBy: "/")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

        guard !sets.isEmpty else { return nil }

        return ParsedExercise(
            name: normalizeExerciseName(correctSpelling(name)),
            weight: nil,
            isBodyweight: true,
            sets: sets,
            notes: notes
        )
    }

    // MARK: - Pattern: "Exercise 80kg 8" (single set)
    private static func trySingleSetFormat(_ text: String, notes: String?) -> ParsedExercise? {
        let pattern = #"^(.+?)\s+(\d+(?:\.\d+)?)\s*(?:kg|lbs?)?\s+(\d+)$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges >= 4 else {
            return nil
        }

        guard let nameRange = Range(match.range(at: 1), in: text),
              let weightRange = Range(match.range(at: 2), in: text),
              let repsRange = Range(match.range(at: 3), in: text) else {
            return nil
        }

        let name = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        let weight = Double(text[weightRange])
        let reps = Int(text[repsRange]) ?? 0

        guard reps > 0 else { return nil }

        return ParsedExercise(
            name: normalizeExerciseName(correctSpelling(name)),
            weight: weight,
            isBodyweight: false,
            sets: [reps],
            notes: notes
        )
    }

    // MARK: - Flexible Format (last resort - try to extract any weight/reps)
    private static func tryFlexibleFormat(_ text: String, notes: String?) -> ParsedExercise? {
        // Extract all numbers from the text
        let numberPattern = #"(\d+(?:\.\d+)?)\s*(?:kg|lbs?|lb)?"#
        guard let regex = try? NSRegularExpression(pattern: numberPattern, options: .caseInsensitive) else {
            return nil
        }

        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard matches.count >= 1 else { return nil }

        // Find where numbers start to extract exercise name
        guard let firstMatch = matches.first,
              let firstRange = Range(firstMatch.range, in: text) else {
            return nil
        }

        let nameEndIndex = firstRange.lowerBound
        var exerciseName = String(text[..<nameEndIndex]).trimmingCharacters(in: .whitespaces)

        guard !exerciseName.isEmpty else { return nil }

        // Extract numbers
        var numbers: [Double] = []
        for match in matches {
            if let range = Range(match.range(at: 1), in: text),
               let num = Double(text[range]) {
                numbers.append(num)
            }
        }

        guard !numbers.isEmpty else { return nil }

        // Heuristic: if first number > 20, it's probably weight, rest are reps
        // If all numbers <= 20, they're probably all reps (bodyweight)
        if numbers.count == 1 {
            // Single number - treat as reps for bodyweight
            return ParsedExercise(
                name: normalizeExerciseName(correctSpelling(exerciseName)),
                weight: nil,
                isBodyweight: true,
                sets: [Int(numbers[0])],
                notes: notes
            )
        }

        // Check if text contains kg/lbs to determine if first number is weight
        let hasWeightUnit = text.lowercased().contains("kg") || text.lowercased().contains("lb")

        if hasWeightUnit || numbers[0] > 20 {
            // First number is weight
            let weight = numbers[0]
            let reps = numbers.dropFirst().map { Int($0) }
            guard !reps.isEmpty else { return nil }

            return ParsedExercise(
                name: normalizeExerciseName(correctSpelling(exerciseName)),
                weight: weight,
                isBodyweight: false,
                sets: reps,
                notes: notes
            )
        } else {
            // All numbers are reps (bodyweight)
            let reps = numbers.map { Int($0) }
            return ParsedExercise(
                name: normalizeExerciseName(correctSpelling(exerciseName)),
                weight: nil,
                isBodyweight: true,
                sets: reps,
                notes: notes
            )
        }
    }

    // MARK: - Helper Methods

    /// Normalize exercise name to proper capitalization
    private static func normalizeExerciseName(_ name: String) -> String {
        // Capitalize first letter of each word
        name.split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }

    /// Correct common spelling mistakes in exercise names
    private static func correctSpelling(_ name: String) -> String {
        let lowercased = name.lowercased()

        // Common misspellings dictionary
        let corrections: [String: String] = [
            // Dumbbell variations
            "dumbell": "dumbbell",
            "dumbel": "dumbbell",
            "dumble": "dumbbell",
            "dumbbel": "dumbbell",
            "dumbells": "dumbbells",
            "dumbel rows": "dumbbell rows",
            "dumbell rows": "dumbbell rows",
            "db": "dumbbell",

            // Barbell variations
            "barbal": "barbell",
            "barbel": "barbell",
            "bb": "barbell",

            // Bench variations
            "banch": "bench",
            "bech": "bench",
            "benchpress": "bench press",

            // Squat variations
            "sqaut": "squat",
            "squats": "squat",
            "squatt": "squat",

            // Deadlift variations
            "deadlif": "deadlift",
            "deadlifts": "deadlift",
            "dealift": "deadlift",
            "dedlift": "deadlift",
            "dl": "deadlift",

            // Row variations
            "rows": "row",
            "rwo": "row",
            "rwos": "rows",

            // Press variations
            "pres": "press",
            "presse": "press",
            "ohp": "overhead press",

            // Pull-up variations
            "pullup": "pull-up",
            "pullups": "pull-ups",
            "pull up": "pull-up",
            "pull ups": "pull-ups",
            "chinup": "chin-up",
            "chinups": "chin-ups",
            "chin up": "chin-up",

            // Push-up variations
            "pushup": "push-up",
            "pushups": "push-ups",
            "push up": "push-up",
            "push ups": "push-ups",

            // Curl variations
            "curls": "curl",
            "bicep": "biceps",
            "bicep curl": "biceps curl",

            // Tricep variations
            "tricep": "triceps",
            "tricep pushdown": "triceps pushdown",
            "tricep extension": "triceps extension",

            // Lateral variations
            "lat": "lateral",
            "lats": "lateral",
            "lat raise": "lateral raise",

            // Incline/Decline
            "inclin": "incline",
            "declin": "decline",

            // Fly variations
            "flys": "fly",
            "flies": "fly",
            "flyes": "fly",

            // Leg variations
            "leg curl": "leg curl",
            "legcurl": "leg curl",
            "leg extension": "leg extension",
            "legextension": "leg extension",
            "leg press": "leg press",
            "legpress": "leg press",

            // Calf variations
            "calf raise": "calf raise",
            "calfraise": "calf raise",
            "calfs": "calves",

            // Shoulder variations
            "sholder": "shoulder",
            "sholders": "shoulders",
            "shouler": "shoulder",

            // Chest variations
            "ches": "chest",

            // Hip thrust
            "hipthrust": "hip thrust",
            "hip trusts": "hip thrust",

            // Lunge variations
            "lunges": "lunge",
            "lungee": "lunge",

            // Plank
            "planks": "plank",

            // Crunch
            "crunchs": "crunch",
            "crunches": "crunch",

            // Shrug
            "shrugs": "shrug",
        ]

        var result = lowercased

        // First try exact matches
        if let correction = corrections[lowercased] {
            return correction
        }

        // Then try partial matches (for compound exercises)
        for (wrong, correct) in corrections {
            if result.contains(wrong) {
                result = result.replacingOccurrences(of: wrong, with: correct)
            }
        }

        // Fuzzy matching for close misspellings
        let words = result.split(separator: " ").map { String($0) }
        let correctedWords = words.map { word -> String in
            // Try to find a close match in our correction keys
            for (wrong, correct) in corrections {
                if levenshteinDistance(word, wrong) <= 2 && wrong.count > 3 {
                    return correct
                }
            }
            return word
        }

        return correctedWords.joined(separator: " ")
    }

    /// Calculate Levenshtein distance between two strings
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count

        if m == 0 { return n }
        if n == 0 { return m }

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,      // deletion
                    matrix[i][j - 1] + 1,      // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }

        return matrix[m][n]
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension WorkoutParser {
    static let sampleWorkout = """
    Bench 80kg 8/8/6
    Incline 60kg 10/10/8
    Dumbbell Press 25kg 12/12/10
    Push-ups BW 15/12/10
    Tricep Pushdown 30kg 12/10/10 .... (arms tired)
    dumbell rows 10kg 13 / 34kg 12
    """

    static var sampleParsed: [ParsedExercise] {
        parse(text: sampleWorkout)
    }
}
#endif
