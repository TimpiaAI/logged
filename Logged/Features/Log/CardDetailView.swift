import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Bindable var card: WorkoutCard
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @AppStorage("defaultRestTime") private var defaultRestTime: Double = 90
    @AppStorage("autoStartTimer") private var autoStartTimer: Bool = true

    @State private var rawText = ""
    @State private var viewMode: ViewMode = .text
    @State private var currentWorkout: Workout?
    @State private var showDoneConfirmation = false
    @State private var timerManager = RestTimerManager()
    @State private var previousLineCount = 0

    @Namespace private var modeNamespace

    enum ViewMode: String, CaseIterable {
        case text, preview
    }

    // Track parsed exercises for Live Activity updates
    private var exercises: [ParsedExercise] {
        WorkoutParser.parse(text: rawText)
    }

    private var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    private var totalVolume: Int {
        Int(exercises.reduce(0.0) { total, exercise in
            guard let weight = exercise.weight else { return total }
            let repsSum = exercise.sets.reduce(0, +)
            return total + (weight * Double(repsSum))
        })
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView

            viewModeToggle
                .padding(.horizontal, LoggedSpacing.xl)
                .padding(.vertical, LoggedSpacing.m)

            if viewMode == .text {
                TextModeView(text: $rawText, onNewLine: handleNewLine)
            } else {
                PreviewModeView(text: rawText)
            }

            Spacer()

            bottomBar
        }
        .navigationBarHidden(true)
        .onAppear {
            setupWorkout()
            timerManager.defaultRestTime = defaultRestTime
            timerManager.autoStartEnabled = autoStartTimer
            startLiveActivity()
        }
        .onDisappear {
            saveWorkout()
        }
        .onChange(of: rawText) { _, newValue in
            updateLiveActivity()
        }
    }

    // MARK: - Live Activity

    private func startLiveActivity() {
        WorkoutActivityManager.shared.startWorkoutActivity(
            workoutName: card.title,
            emoji: card.emoji
        )
    }

    private func updateLiveActivity() {
        let currentExercise = exercises.last?.name ?? "ready..."
        WorkoutActivityManager.shared.updateWorkoutProgress(
            currentExercise: currentExercise,
            setsCompleted: totalSets,
            totalVolume: totalVolume
        )
    }

    // MARK: - Auto Timer

    private func handleNewLine() {
        // Auto-start timer when a new exercise line is completed
        guard autoStartTimer, !timerManager.isActive else { return }

        let lineCount = rawText.components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .count

        // If we added a new line with content, start the timer
        if lineCount > previousLineCount {
            let lastLine = rawText.components(separatedBy: "\n")
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                .last ?? ""

            // Only start if the line parsed as an exercise
            if WorkoutParser.parseLine(lastLine).exercise != nil {
                timerManager.start()
            }
        }
        previousLineCount = lineCount
    }

    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("← back")
                    .font(.loggedBody)
                    .foregroundStyle(Color.loggedAccent)
            }

            Spacer()

            // Show compact timer in header when active
            if timerManager.isActive {
                CompactRestTimerView(timerManager: timerManager)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text(card.title.lowercased())
                    .font(.loggedHeadline)

                Text("today")
                    .font(.loggedCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(LoggedSpacing.xl)
    }

    private var viewModeToggle: some View {
        GlassEffectContainer {
            HStack(spacing: 0) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewMode = mode
                        }
                    } label: {
                        Text(mode.rawValue)
                            .font(.loggedCaption)
                            .fontWeight(viewMode == mode ? .semibold : .regular)
                            .foregroundStyle(viewMode == mode ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .glassEffectID(mode.rawValue, in: modeNamespace)
                }
            }
            .padding(3)
        }
    }

    private var bottomBar: some View {
        VStack(spacing: LoggedSpacing.m) {
            // Rest timer
            if timerManager.isActive {
                RestTimerView(timerManager: timerManager)
            } else {
                HStack(spacing: LoggedSpacing.m) {
                    RestTimerStartButton(timerManager: timerManager, duration: defaultRestTime)

                    Spacer()

                    // Quick timer presets
                    HStack(spacing: LoggedSpacing.s) {
                        TimerPresetButton(seconds: 60, timerManager: timerManager)
                        TimerPresetButton(seconds: 90, timerManager: timerManager)
                        TimerPresetButton(seconds: 120, timerManager: timerManager)
                    }
                }
            }

            LoggedButton(title: "done") {
                completeWorkout()
            }
        }
        .padding(LoggedSpacing.xl)
    }

    private func setupWorkout() {
        // Check if there's an active workout for this card today
        let today = Calendar.current.startOfDay(for: Date())
        if let existingWorkout = card.workouts.first(where: {
            $0.completedAt == nil && Calendar.current.isDate($0.startedAt, inSameDayAs: today)
        }) {
            currentWorkout = existingWorkout
            rawText = existingWorkout.rawText
        } else {
            // Create new workout
            let workout = Workout(card: card)
            modelContext.insert(workout)
            currentWorkout = workout
        }
    }

    private func saveWorkout() {
        currentWorkout?.rawText = rawText
    }

    private func completeWorkout() {
        currentWorkout?.rawText = rawText
        currentWorkout?.completedAt = Date()
        currentWorkout?.calculateStats()
        card.lastUsedAt = Date()

        // End Live Activity
        WorkoutActivityManager.shared.endWorkoutActivity()

        dismiss()
    }
}

// MARK: - Text Mode View
struct TextModeView: View {
    @Binding var text: String
    var onNewLine: (() -> Void)?

    @FocusState private var isFocused: Bool
    @State private var previousText = ""

    private let placeholderText = """
        bench 80kg 8/8/6
        incline 60kg 10/10/8
        push-ups bw 15/12/10
        """

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholderText)
                            .font(.loggedBody)
                            .foregroundStyle(.tertiary)
                            .padding(LoggedSpacing.l)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }

                    TextEditor(text: $text)
                        .font(.loggedBody)
                        .scrollContentBackground(.hidden)
                        .focused($isFocused)
                        .frame(minHeight: 300)
                        .padding(LoggedSpacing.l)
                }
            }
            .background(Color.loggedCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l))
            .overlay(
                RoundedRectangle(cornerRadius: LoggedCornerRadius.l)
                    .stroke(Color.loggedBorder, lineWidth: 0.5)
            )
            .padding(.horizontal, LoggedSpacing.xl)
        }
        .onAppear {
            isFocused = true
            previousText = text
        }
        .onChange(of: text) { oldValue, newValue in
            // Detect when user pressed Enter (new line added)
            let oldLines = oldValue.components(separatedBy: "\n").count
            let newLines = newValue.components(separatedBy: "\n").count

            if newLines > oldLines && newValue.last == "\n" || (newValue.hasSuffix("\n") && !oldValue.hasSuffix("\n")) {
                onNewLine?()
            }
        }
    }
}

// MARK: - Preview Mode View
struct PreviewModeView: View {
    let text: String

    private var parsedLines: [ParsedLine] {
        text.components(separatedBy: "\n").map { WorkoutParser.parseLine($0) }
    }

    private var exercises: [ParsedExercise] {
        parsedLines.compactMap { $0.exercise }
    }

    private var unparseableLines: [String] {
        parsedLines
            .filter { line in
                let trimmed = line.originalText.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmed.isEmpty && line.exercise == nil && !line.isComment
            }
            .map { $0.originalText.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: LoggedSpacing.m) {
                if exercises.isEmpty && unparseableLines.isEmpty {
                    EmptyStateView(
                        title: "no exercises yet",
                        message: "switch to text mode and write your workout"
                    )
                    .padding(.top, LoggedSpacing.xxxl)
                } else {
                    ForEach(exercises) { exercise in
                        ExercisePreviewCard(exercise: exercise)
                    }

                    // Show unparseable lines as warnings
                    if !unparseableLines.isEmpty {
                        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                            Text("couldn't parse:")
                                .font(.loggedMicro)
                                .foregroundStyle(.secondary)

                            ForEach(unparseableLines, id: \.self) { line in
                                Text(line)
                                    .font(.loggedCaption)
                                    .foregroundStyle(Color.loggedError)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(LoggedSpacing.m)
                        .background(Color.loggedError.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))
                    }

                    if !exercises.isEmpty {
                        summaryCard
                    }
                }
            }
            .padding(.horizontal, LoggedSpacing.xl)
        }
    }

    private var summaryCard: some View {
        HStack {
            SummaryItem(value: "\(exercises.count)", label: "exercises")
            SummaryItem(value: "\(totalSets)", label: "sets")
            SummaryItem(value: "\(totalVolume)", label: "volume")
        }
        .padding(LoggedSpacing.m)
        .background(Color.loggedAccent)
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
    }

    private var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    private var totalReps: Int {
        exercises.reduce(0) { $0 + $1.sets.reduce(0, +) }
    }

    private var totalVolume: String {
        let volume = exercises.reduce(0.0) { total, exercise in
            guard let weight = exercise.weight else { return total }
            let repsSum = exercise.sets.reduce(0, +)
            return total + (weight * Double(repsSum))
        }
        if volume == 0 { return "0" }
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return "\(Int(volume))"
    }
}

// MARK: - Exercise Preview Card
struct ExercisePreviewCard: View {
    let exercise: ParsedExercise

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            HStack {
                Text(exercise.name.lowercased())
                    .font(.loggedCallout)
                    .fontWeight(.semibold)

                Spacer()

                Text(exercise.isBodyweight ? "bw" : "\(Int(exercise.weight ?? 0))kg")
                    .font(.loggedCallout)
                    .foregroundStyle(Color.loggedAccent)
                    .fontWeight(.medium)
            }

            // Sets as bars
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(exercise.sets.enumerated()), id: \.offset) { index, reps in
                    VStack(spacing: 4) {
                        Text("\(reps)")
                            .font(.loggedMicro)
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.loggedAccent)
                            .opacity(0.7 + Double(index) * 0.1)
                            .frame(height: barHeight(for: reps))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 60)

            // Set labels
            HStack(spacing: 6) {
                ForEach(Array(exercise.sets.enumerated()), id: \.offset) { index, _ in
                    Text("S\(index + 1)")
                        .font(.loggedMicro)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Notes (if present)
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.loggedMicro)
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.top, LoggedSpacing.xs)
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l))
        .overlay(
            RoundedRectangle(cornerRadius: LoggedCornerRadius.l)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }

    private func barHeight(for reps: Int) -> CGFloat {
        let maxReps = exercise.sets.max() ?? 1
        let percentage = CGFloat(reps) / CGFloat(maxReps)
        return max(8, 50 * percentage)
    }
}

// MARK: - Summary Item
struct SummaryItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.loggedTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text(label)
                .font(.loggedMicro)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: WorkoutCard(title: "Push Day", emoji: "💪", sortOrder: 0))
    }
    .modelContainer(for: [User.self, WorkoutCard.self, Workout.self, WorkoutSet.self, Exercise.self], inMemory: true)
}
