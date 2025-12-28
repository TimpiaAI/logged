import SwiftUI
import SwiftData

struct LogTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutCard.sortOrder) private var cards: [WorkoutCard]
    @Query private var users: [User]

    @State private var showNewCardSheet = false
    @State private var selectedCard: WorkoutCard?

    private var currentUser: User? { users.first }
    @State private var showImportSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                    headerView

                    if cards.isEmpty {
                        EmptyStateView(
                            title: "nothing logged yet.",
                            message: "create your first workout card to start tracking",
                            action: { showNewCardSheet = true },
                            actionTitle: "create card"
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, LoggedSpacing.xxxl)
                    } else {
                        cardsGrid
                    }

                    quickStats
                }
                .padding(LoggedSpacing.xl)
            }
            .background(Color.loggedBackground)
            .navigationDestination(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
            .sheet(isPresented: $showNewCardSheet) {
                NewCardSheet { title, emoji in
                    createCard(title: title, emoji: emoji)
                }
            }
            .sheet(isPresented: $showImportSheet) {
                ImportNotesSheet()
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
                Text("good \(greeting), \(currentUser?.name.lowercased() ?? "there")")
                    .font(.loggedCallout)
                    .foregroundStyle(.secondary)

                HStack(spacing: 0) {
                    Text("logged")
                        .font(.loggedTitle)
                    Text(".")
                        .font(.loggedTitle)
                        .foregroundStyle(Color.loggedAccent)
                }
            }

            Spacer()

            HStack(spacing: LoggedSpacing.s) {
                Button {
                    showImportSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.loggedCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.loggedBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    showNewCardSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.loggedAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var cardsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                Button {
                    selectedCard = card
                } label: {
                    WorkoutCardView(
                        title: card.title,
                        emoji: card.emoji,
                        lastUsed: card.lastUsedAt,
                        workoutCount: card.workouts.count
                    )
                }
                .buttonStyle(PressMapStyle())
                .staggered(index: index, total: cards.count)
            }

            Button {
                showNewCardSheet = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(.tertiary)
                    Text("new card")
                        .font(.loggedCaption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color.loggedCardBackground.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                        .stroke(Color.loggedBorder.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                )
            }
            .buttonStyle(PressMapStyle())
            .staggered(index: cards.count, total: cards.count + 1)
        }
    }

    private var quickStats: some View {
        HStack(spacing: LoggedSpacing.m) {
            StatCard(
                label: "this week",
                value: "\(workoutsThisWeek)",
                suffix: "/\(currentUser?.frequency ?? 4)"
            )

            StatCard(
                label: "streak",
                value: "\(currentStreak)",
                suffix: "days",
                tint: currentStreak > 0 ? .loggedAccent : nil
            )
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }

    private var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return cards.flatMap { $0.workouts }.filter { workout in
            guard let completedAt = workout.completedAt else { return false }
            return completedAt >= startOfWeek
        }.count
    }

    private var currentStreak: Int {
        // Simplified streak calculation
        // Full implementation would check consecutive days
        return 0
    }

    private func createCard(title: String, emoji: String?) {
        let card = WorkoutCard(title: title, emoji: emoji, sortOrder: cards.count)
        modelContext.insert(card)
    }
}

// MARK: - Import Notes Sheet
struct ImportNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var inputText = ""
    @State private var cardTitle = ""
    @State private var showPreview = false

    private var parsedExercises: [ParsedExercise] {
        WorkoutParser.parse(text: inputText)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: LoggedSpacing.l) {
                Text("import workout")
                    .font(.loggedTitle)

                Text("paste your workout text from notes, messages, or anywhere else")
                    .font(.loggedCaption)
                    .foregroundStyle(.secondary)

                // Text input
                VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                    HStack {
                        Text("workout text")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        if !inputText.isEmpty {
                            Text("\(parsedExercises.count) exercises")
                                .font(.loggedMicro)
                                .foregroundStyle(parsedExercises.isEmpty ? Color.secondary : Color.loggedAccent)
                        }
                    }

                    TextEditor(text: $inputText)
                        .font(.loggedBody)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 150)
                        .padding(LoggedSpacing.m)
                        .background(Color.loggedCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: LoggedCornerRadius.m, style: .continuous)
                                .stroke(Color.loggedBorder, lineWidth: 0.5)
                        )
                        .overlay(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("bench 80kg 8/8/6\nincline 60kg 10/10/8\npush-ups bw 15/12/10")
                                    .font(.loggedBody)
                                    .foregroundStyle(.tertiary)
                                    .padding(LoggedSpacing.m)
                                    .padding(.top, 8)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                // Card title
                if !parsedExercises.isEmpty {
                    VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                        Text("save as card (optional)")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)

                        TextField("e.g. push day", text: $cardTitle)
                            .font(.loggedBody)
                            .padding(LoggedSpacing.m)
                            .background(Color.loggedCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: LoggedCornerRadius.m, style: .continuous)
                                    .stroke(Color.loggedBorder, lineWidth: 0.5)
                            )
                    }

                    // Preview
                    VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                        Text("preview")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: LoggedSpacing.s) {
                                ForEach(parsedExercises) { exercise in
                                    ImportExercisePreview(exercise: exercise)
                                }
                            }
                        }
                    }
                }

                Spacer()

                LoggedButton(title: "import workout", action: importWorkout, isEnabled: !parsedExercises.isEmpty)
            }
            .padding(LoggedSpacing.xl)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func importWorkout() {
        // Create card if title provided
        let card: WorkoutCard
        if !cardTitle.isEmpty {
            card = WorkoutCard(title: cardTitle, emoji: nil, sortOrder: 0)
            modelContext.insert(card)
        } else {
            card = WorkoutCard(title: "imported workout", emoji: "📥", sortOrder: 0)
            modelContext.insert(card)
        }

        // Create workout
        let workout = Workout(card: card)
        workout.rawText = inputText
        workout.completedAt = Date()
        modelContext.insert(workout)

        // Create sets from parsed exercises
        var setNumber = 1
        for exercise in parsedExercises {
            if let detailedSets = exercise.detailedSets {
                for parsedSet in detailedSets {
                    let workoutSet = WorkoutSet(
                        workout: workout,
                        exerciseName: exercise.name,
                        setNumber: setNumber,
                        weight: parsedSet.weight,
                        reps: parsedSet.reps,
                        isBodyweight: exercise.isBodyweight
                    )
                    modelContext.insert(workoutSet)
                    setNumber += 1
                }
            } else {
                for (index, reps) in exercise.sets.enumerated() {
                    let workoutSet = WorkoutSet(
                        workout: workout,
                        exerciseName: exercise.name,
                        setNumber: setNumber,
                        weight: exercise.weight,
                        reps: reps,
                        isBodyweight: exercise.isBodyweight
                    )
                    modelContext.insert(workoutSet)
                    setNumber += 1
                }
            }
        }

        // Update card
        card.lastUsedAt = Date()

        dismiss()
    }
}

// MARK: - Import Exercise Preview
struct ImportExercisePreview: View {
    let exercise: ParsedExercise

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
            Text(exercise.name.lowercased())
                .font(.loggedCaption)
                .fontWeight(.semibold)
                .lineLimit(1)

            HStack(spacing: LoggedSpacing.xs) {
                Text(exercise.isBodyweight ? "bw" : "\(Int(exercise.weight ?? 0))kg")
                    .font(.loggedMicro)
                    .foregroundStyle(Color.loggedAccent)

                Text("×")
                    .font(.loggedMicro)
                    .foregroundStyle(.tertiary)

                Text(exercise.sets.map { "\($0)" }.joined(separator: "/"))
                    .font(.loggedMicro)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(LoggedSpacing.s)
        .background(Color.loggedBackground)
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s, style: .continuous))
    }
}

// MARK: - New Card Sheet
struct NewCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var emoji = ""

    let onCreate: (String, String?) -> Void

    private let emojiSuggestions = ["💪", "🏋️", "🦵", "🔥", "⚡️", "🎯"]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                Text("new card")
                    .font(.loggedTitle)

                VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                    Text("title")
                        .font(.loggedCaption)
                        .foregroundStyle(.secondary)

                    TextField("e.g. push day", text: $title)
                        .font(.loggedBody)
                        .textFieldStyle(.plain)
                        .padding()
                        .glassEffect()
                }

                VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                    Text("emoji (optional)")
                        .font(.loggedCaption)
                        .foregroundStyle(.secondary)

                    HStack {
                        ForEach(emojiSuggestions, id: \.self) { suggestion in
                            Button {
                                emoji = suggestion
                            } label: {
                                Text(suggestion)
                                    .font(.system(size: 24))
                                    .padding(LoggedSpacing.s)
                                    .background(emoji == suggestion ? Color.loggedAccent.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }

                Spacer()

                LoggedButton(title: "create", action: {
                    onCreate(title, emoji.isEmpty ? nil : emoji)
                    dismiss()
                }, isEnabled: !title.isEmpty)
            }
            .padding(LoggedSpacing.xl)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    LogTabView()
        .modelContainer(for: [User.self, WorkoutCard.self, Workout.self, WorkoutSet.self, Exercise.self], inMemory: true)
}
