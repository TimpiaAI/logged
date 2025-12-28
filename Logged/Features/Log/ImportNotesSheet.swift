import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var notesText: String = ""
    @State private var parsedPreview: [ParsedExercise] = []
    @State private var showPreview = false
    @State private var selectedDate = Date()
    @State private var showDocumentPicker = false
    @State private var importedFileName: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: LoggedSpacing.l) {
                if !showPreview {
                    // Input Mode
                    inputView
                } else {
                    // Preview Mode
                    previewView
                }
            }
            .padding(LoggedSpacing.l)
            .background(Color.loggedBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                    .font(.loggedBody)
                }

                ToolbarItem(placement: .primaryAction) {
                    if showPreview {
                        Button("save") {
                            saveWorkout()
                        }
                        .font(.loggedBody)
                        .fontWeight(.bold)
                    } else {
                        Button("process") {
                            processText()
                        }
                        .font(.loggedBody)
                        .disabled(notesText.isEmpty)
                    }
                }
            }
            .navigationTitle(showPreview ? "preview" : "import notes")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(text: $notesText, fileName: $importedFileName)
        }
    }

    private var inputView: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.l) {
            // Import from file button
            Button {
                showDocumentPicker = true
            } label: {
                HStack(spacing: LoggedSpacing.m) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.loggedAccent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("import from file")
                            .font(.loggedBody)
                            .fontWeight(.medium)
                        Text("select a .txt file from notes or files")
                            .font(.loggedMicro)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.loggedCaption)
                        .foregroundStyle(.tertiary)
                }
                .padding(LoggedSpacing.l)
                .background(Color.loggedCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
                .overlay(
                    RoundedRectangle(cornerRadius: LoggedCornerRadius.m)
                        .stroke(Color.loggedBorder, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            // Divider with "or"
            HStack {
                Rectangle()
                    .fill(Color.loggedBorder)
                    .frame(height: 0.5)
                Text("or paste text")
                    .font(.loggedMicro)
                    .foregroundStyle(.tertiary)
                Rectangle()
                    .fill(Color.loggedBorder)
                    .frame(height: 0.5)
            }

            // Imported file indicator
            if let fileName = importedFileName {
                HStack(spacing: LoggedSpacing.s) {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(Color.loggedAccent)
                    Text(fileName)
                        .font(.loggedCaption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        notesText = ""
                        importedFileName = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(LoggedSpacing.s)
                .background(Color.loggedAccent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))
            }

            // Text editor
            TextEditor(text: $notesText)
                .font(.body.monospaced())
                .scrollContentBackground(.hidden)
                .padding()
                .background(Color.loggedCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
                .overlay(
                    RoundedRectangle(cornerRadius: LoggedCornerRadius.m)
                        .stroke(Color.loggedBorder, lineWidth: 0.5)
                )
                .overlay(alignment: .topLeading) {
                    if notesText.isEmpty {
                        Text("bench 80kg 8/8/6\nsquat 100kg 5x5\npull-ups bw 10/8/6")
                            .font(.body.monospaced())
                            .foregroundStyle(.quaternary)
                            .padding()
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }

            Text("tip: use formats like 'Bench 80kg 5x5' or 'Squat 100 3x8'")
                .font(.loggedMicro)
                .foregroundStyle(.tertiary)
        }
    }

    private var previewView: some View {
        ScrollView {
            VStack(spacing: LoggedSpacing.xl) {
                // Summary Card
                GlassCard {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("summary")
                                .font(.loggedCaption)
                                .foregroundStyle(.secondary)
                            Text("\(parsedPreview.count)")
                                .font(.loggedTitle)
                                .foregroundStyle(Color.loggedAccent)
                            Text("exercises")
                                .font(.loggedMicro)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("sets")
                                .font(.loggedCaption)
                                .foregroundStyle(.secondary)
                            Text("\(parsedPreview.reduce(0) { $0 + $1.sets.count })")
                                .font(.loggedTitle)
                            Text("total")
                                .font(.loggedMicro)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Date Selection
                VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                    Text("DATE")
                        .font(.loggedMicro)
                        .foregroundStyle(.tertiary)
                        .tracking(1)

                    DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Exercises List
                if !parsedPreview.isEmpty {
                    VStack(alignment: .leading, spacing: LoggedSpacing.m) {
                        Text("EXERCISES FOUND")
                            .font(.loggedMicro)
                            .foregroundStyle(.tertiary)
                            .tracking(1)

                        ForEach(parsedPreview) { exercise in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name.lowercased())
                                        .font(.loggedBody)
                                        .fontWeight(.semibold)

                                    if let weight = exercise.weight {
                                        Text("\(Int(weight))kg")
                                            .font(.loggedCaption)
                                            .foregroundStyle(.secondary)
                                    } else if exercise.isBodyweight {
                                        Text("bodyweight")
                                            .font(.loggedCaption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(exercise.sets.count) sets")
                                        .font(.loggedCaption)
                                        .foregroundStyle(.secondary)
                                    Text(exercise.sets.map { String($0) }.joined(separator: "/"))
                                        .font(.loggedMicro)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .padding(LoggedSpacing.m)
                            .background(Color.loggedCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))
                        }
                    }
                } else {
                    VStack(spacing: LoggedSpacing.m) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundStyle(.tertiary)
                        Text("no exercises found")
                            .font(.loggedBody)
                            .foregroundStyle(.secondary)
                        Text("try adjusting your text format")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(LoggedSpacing.xl)
                }

                Button {
                    withAnimation {
                        showPreview = false
                    }
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("edit text")
                    }
                    .font(.loggedCaption)
                    .foregroundStyle(.secondary)
                }
                .padding(.top)
            }
        }
    }

    private func processText() {
        let exercises = WorkoutParser.parse(text: notesText)
        self.parsedPreview = exercises
        withAnimation {
            showPreview = true
        }
    }

    private func saveWorkout() {
        let workout = Workout(card: nil)
        workout.rawText = notesText
        workout.completedAt = selectedDate
        workout.startedAt = selectedDate.addingTimeInterval(-3600)
        workout.createdAt = Date()
        workout.updatedAt = Date()

        var newSets: [WorkoutSet] = []

        for parsedExercise in parsedPreview {
            for (setIndex, reps) in parsedExercise.sets.enumerated() {
                var weight = parsedExercise.weight

                if let details = parsedExercise.detailedSets, setIndex < details.count {
                    weight = details[setIndex].weight
                }

                let set = WorkoutSet(
                    workout: workout,
                    exerciseName: parsedExercise.name,
                    setNumber: setIndex + 1,
                    weight: weight,
                    weightUnit: "kg",
                    reps: reps,
                    isBodyweight: parsedExercise.isBodyweight,
                    notes: parsedExercise.notes
                )
                newSets.append(set)
            }
        }

        workout.sets = newSets
        workout.calculateStats()

        modelContext.insert(workout)
        dismiss()
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var fileName: String?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.plainText, .text, .utf8PlainText]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                return
            }

            defer {
                url.stopAccessingSecurityScopedResource()
            }

            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                DispatchQueue.main.async {
                    self.parent.text = content
                    self.parent.fileName = url.lastPathComponent
                }
            } catch {
                // Try other encodings
                if let content = try? String(contentsOf: url, encoding: .ascii) {
                    DispatchQueue.main.async {
                        self.parent.text = content
                        self.parent.fileName = url.lastPathComponent
                    }
                }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // User cancelled
        }
    }
}

#Preview {
    ImportNotesSheet()
        .preferredColorScheme(.dark)
}
