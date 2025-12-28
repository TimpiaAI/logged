import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var workouts: [Workout]

    @AppStorage("defaultRestTime") private var defaultRestTime: Double = 90
    @AppStorage("autoStartTimer") private var autoStartTimer: Bool = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @State private var showResetConfirmation = false
    @State private var showEditProfile = false

    private var currentUser: User? { users.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
                        Text("settings")
                            .font(.loggedTitle)

                        Text("customize your experience")
                            .font(.loggedCaption)
                            .foregroundStyle(.secondary)
                    }

                    // Profile Card
                    if let user = currentUser {
                        SettingsProfileCard(user: user) {
                            showEditProfile = true
                        }
                    }

                    // Preferences Card
                    if let user = currentUser {
                        SettingsCard(title: "preferences") {
                            // Units
                            SettingsRow(label: "units") {
                                Picker("", selection: Binding(
                                    get: { user.units },
                                    set: { user.units = $0 }
                                )) {
                                    Text("kg").tag("kg")
                                    Text("lbs").tag("lbs")
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 100)
                            }

                            Divider()
                                .background(Color.loggedBorder)

                            // Rest Timer
                            SettingsRow(label: "rest timer") {
                                HStack(spacing: LoggedSpacing.s) {
                                    Button {
                                        if defaultRestTime > 30 {
                                            defaultRestTime -= 15
                                        }
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.loggedCaption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 28, height: 28)
                                            .background(Color.loggedBackground)
                                            .clipShape(Circle())
                                    }

                                    Text("\(Int(defaultRestTime))s")
                                        .font(.loggedBody)
                                        .frame(width: 50)

                                    Button {
                                        if defaultRestTime < 300 {
                                            defaultRestTime += 15
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.loggedCaption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 28, height: 28)
                                            .background(Color.loggedBackground)
                                            .clipShape(Circle())
                                    }
                                }
                            }

                            Divider()
                                .background(Color.loggedBorder)

                            // Auto-start Timer
                            SettingsRow(label: "auto-start timer") {
                                Toggle("", isOn: $autoStartTimer)
                                    .labelsHidden()
                                    .tint(Color.loggedAccent)
                            }

                            Divider()
                                .background(Color.loggedBorder)

                            // Weekly Goal
                            SettingsRow(label: "weekly goal") {
                                HStack(spacing: LoggedSpacing.s) {
                                    Button {
                                        if user.frequency > 1 {
                                            user.frequency -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.loggedCaption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 28, height: 28)
                                            .background(Color.loggedBackground)
                                            .clipShape(Circle())
                                    }

                                    Text("\(user.frequency)x")
                                        .font(.loggedBody)
                                        .frame(width: 40)

                                    Button {
                                        if user.frequency < 7 {
                                            user.frequency += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.loggedCaption)
                                            .foregroundStyle(.secondary)
                                            .frame(width: 28, height: 28)
                                            .background(Color.loggedBackground)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }

                    // Body Metrics Card
                    if let user = currentUser {
                        SettingsCard(title: "body metrics") {
                            SettingsRow(label: "bodyweight") {
                                HStack(spacing: LoggedSpacing.xs) {
                                    TextField("0", value: Binding(
                                        get: { user.bodyweight ?? 0 },
                                        set: { user.bodyweight = $0 }
                                    ), format: .number)
                                    .font(.loggedBody)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                    .padding(.horizontal, LoggedSpacing.s)
                                    .padding(.vertical, LoggedSpacing.xs)
                                    .background(Color.loggedBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))

                                    Text(user.units)
                                        .font(.loggedCaption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Divider()
                                .background(Color.loggedBorder)

                            SettingsRow(label: "height") {
                                HStack(spacing: LoggedSpacing.xs) {
                                    TextField("0", value: Binding(
                                        get: { user.height ?? 0 },
                                        set: { user.height = $0 }
                                    ), format: .number)
                                    .font(.loggedBody)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                    .padding(.horizontal, LoggedSpacing.s)
                                    .padding(.vertical, LoggedSpacing.xs)
                                    .background(Color.loggedBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))

                                    Text("cm")
                                        .font(.loggedCaption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    // Data Card
                    SettingsCard(title: "data") {
                        Button {
                            showImportSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.loggedBody)
                                    .foregroundStyle(.secondary)
                                Text("import from notes")
                                    .font(.loggedBody)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.loggedCaption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(Color.loggedBorder)

                        Button {
                            showExportSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.loggedBody)
                                    .foregroundStyle(.secondary)
                                Text("export workouts")
                                    .font(.loggedBody)
                                Spacer()
                                Text("\(workouts.filter { $0.completedAt != nil }.count)")
                                    .font(.loggedCaption)
                                    .foregroundStyle(.tertiary)
                                Image(systemName: "chevron.right")
                                    .font(.loggedCaption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Danger Zone Card
                    SettingsCard(title: "danger zone", titleColor: .loggedError) {
                        Button {
                            hasCompletedOnboarding = false
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.loggedBody)
                                    .foregroundStyle(.secondary)
                                Text("replay onboarding")
                                    .font(.loggedBody)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.loggedCaption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(Color.loggedBorder)

                        Button {
                            showResetConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.loggedBody)
                                    .foregroundStyle(Color.loggedError)
                                Text("reset all data")
                                    .font(.loggedBody)
                                    .foregroundStyle(Color.loggedError)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // About Card
                    SettingsCard(title: "about") {
                        SettingsRow(label: "version") {
                            Text("1.0.0")
                                .font(.loggedCaption)
                                .foregroundStyle(.tertiary)
                        }

                        Divider()
                            .background(Color.loggedBorder)

                        Link(destination: URL(string: "https://logged.app/privacy")!) {
                            HStack {
                                Text("privacy policy")
                                    .font(.loggedBody)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.loggedCaption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(Color.loggedBorder)

                        Link(destination: URL(string: "https://logged.app/terms")!) {
                            HStack {
                                Text("terms of service")
                                    .font(.loggedBody)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.loggedCaption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Footer
                    HStack {
                        Spacer()
                        Text("made with")
                            .font(.loggedMicro)
                            .foregroundStyle(.quaternary)
                        + Text(" 💪 ")
                            .font(.loggedMicro)
                        + Text("for lifters")
                            .font(.loggedMicro)
                            .foregroundStyle(.quaternary)
                        Spacer()
                    }
                    .padding(.top, LoggedSpacing.l)
                }
                .padding(LoggedSpacing.xl)
            }
            .background(Color.loggedBackground)
            .confirmationDialog("reset all data?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("reset everything", role: .destructive) {
                    resetAllData()
                }
                Button("cancel", role: .cancel) { }
            } message: {
                Text("this will delete all your workouts, cards, and settings. this cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                ExportSheet()
            }
            .sheet(isPresented: $showImportSheet) {
                ImportNotesSheet()
            }
            .sheet(isPresented: $showEditProfile) {
                if let user = currentUser {
                    EditProfileView(user: user)
                }
            }
        }
    }

    private func resetAllData() {
        do {
            try modelContext.delete(model: Workout.self)
            try modelContext.delete(model: WorkoutCard.self)
            try modelContext.delete(model: WorkoutSet.self)
            try modelContext.delete(model: User.self)
            try modelContext.delete(model: Exercise.self)
            hasCompletedOnboarding = false
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}

// MARK: - Settings Card
struct SettingsCard<Content: View>: View {
    let title: String
    var titleColor: Color = Color.secondary.opacity(0.7)
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            Text(title.uppercased())
                .font(.loggedMicro)
                .foregroundStyle(titleColor)
                .tracking(1)

            VStack(spacing: LoggedSpacing.m) {
                content()
            }
        }
        .padding(LoggedSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack {
            Text(label)
                .font(.loggedBody)
            Spacer()
            content()
        }
    }
}

// MARK: - Settings Profile Card
struct SettingsProfileCard: View {
    let user: User
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: LoggedSpacing.l) {
                ZStack {
                    Circle()
                        .fill(Color(hex: user.avatarColor ?? "#4ADE80").opacity(0.2))
                        .frame(width: 56, height: 56)

                    Text(user.avatarEmoji ?? String(user.name.prefix(1)).uppercased())
                        .font(.system(size: 26))
                }

                VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
                    Text(user.name)
                        .font(.loggedHeadline)
                        .foregroundStyle(.primary)

                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.loggedCaption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("tap to edit profile")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.loggedCaption)
                    .foregroundStyle(.tertiary)
            }
            .padding(LoggedSpacing.l)
            .background(Color.loggedCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                    .stroke(Color.loggedBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Export Sheet
struct ExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var workouts: [Workout]

    @State private var exportFormat: ExportFormat = .json
    @State private var exportURL: URL?

    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
    }

    private var completedWorkouts: [Workout] {
        workouts.filter { $0.completedAt != nil }
    }

    private var totalSets: Int {
        completedWorkouts.flatMap { $0.sets }.count
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                Text("export workouts")
                    .font(.loggedTitle)

                // Format selection
                VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                    Text("FORMAT")
                        .font(.loggedMicro)
                        .foregroundStyle(.tertiary)
                        .tracking(1)

                    Picker("", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Summary
                VStack(alignment: .leading, spacing: LoggedSpacing.m) {
                    Text("SUMMARY")
                        .font(.loggedMicro)
                        .foregroundStyle(.tertiary)
                        .tracking(1)

                    HStack {
                        VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
                            Text("\(completedWorkouts.count)")
                                .font(.system(size: 28, weight: .medium, design: .monospaced))
                            Text("workouts")
                                .font(.loggedMicro)
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
                            Text("\(totalSets)")
                                .font(.system(size: 28, weight: .medium, design: .monospaced))
                            Text("sets")
                                .font(.loggedMicro)
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()
                    }
                }
                .padding(LoggedSpacing.l)
                .background(Color.loggedCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                        .stroke(Color.loggedBorder, lineWidth: 0.5)
                )

                Spacer()

                if let url = exportURL {
                    ShareLink(item: url) {
                        Text("share export")
                            .font(.loggedBody)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.loggedAccent)
                            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
                    }
                } else {
                    LoggedButton(title: "generate export", action: generateExport, isEnabled: !completedWorkouts.isEmpty)
                }
            }
            .padding(LoggedSpacing.xl)
            .background(Color.loggedBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                    .font(.loggedBody)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func generateExport() {
        let fileName = "logged_export_\(Date().formatted(.dateTime.year().month().day()))"
        let fileExtension = exportFormat == .json ? "json" : "csv"

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension(fileExtension)

        do {
            let data: Data
            if exportFormat == .json {
                data = try generateJSON()
            } else {
                data = try generateCSV()
            }
            try data.write(to: tempURL)
            exportURL = tempURL
        } catch {
            print("Export failed: \(error)")
        }
    }

    private func generateJSON() throws -> Data {
        let exportData = completedWorkouts.map { workout -> [String: Any] in
            [
                "startedAt": workout.startedAt.ISO8601Format(),
                "completedAt": workout.completedAt?.ISO8601Format() ?? "",
                "cardTitle": workout.card?.title ?? "Unknown",
                "sets": workout.sets.map { set -> [String: Any] in
                    [
                        "exerciseName": set.exerciseName,
                        "reps": set.reps,
                        "weight": set.weight as Any
                    ]
                }
            ]
        }
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }

    private func generateCSV() throws -> Data {
        var csv = "date,card,exercise,reps,weight\n"
        for workout in completedWorkouts {
            let date = workout.completedAt?.formatted(.dateTime.year().month().day()) ?? ""
            let cardTitle = workout.card?.title ?? "Unknown"
            for set in workout.sets {
                let weight = set.weight.map { String($0) } ?? ""
                csv += "\(date),\(cardTitle),\(set.exerciseName),\(set.reps),\(weight)\n"
            }
        }
        return csv.data(using: .utf8) ?? Data()
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Bindable var user: User
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var selectedEmoji: String = ""
    @State private var selectedColor: String = "#4ADE80"

    private let emojiOptions = ["🏋️", "💪", "🦁", "🔥", "⚡️", "🎯", "🏃", "🧘", "🚴", "🏊"]
    private let colorOptions = ["#4ADE80", "#FBBF24", "#EF4444", "#3B82F6", "#8B5CF6", "#EC4899"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                    Text("edit profile")
                        .font(.loggedTitle)

                    // Avatar preview
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(hex: selectedColor).opacity(0.2))
                                .frame(width: 80, height: 80)

                            Text(selectedEmoji.isEmpty ? String(name.prefix(1)).uppercased() : selectedEmoji)
                                .font(.system(size: 36))
                        }
                        Spacer()
                    }

                    // Name
                    VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                        Text("NAME")
                            .font(.loggedMicro)
                            .foregroundStyle(.tertiary)
                            .tracking(1)

                        TextField("your name", text: $name)
                            .font(.loggedBody)
                            .textFieldStyle(.plain)
                            .padding(LoggedSpacing.m)
                            .background(Color.loggedCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
                            .overlay(
                                RoundedRectangle(cornerRadius: LoggedCornerRadius.m)
                                    .stroke(Color.loggedBorder, lineWidth: 0.5)
                            )
                    }

                    // Bio
                    VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                        Text("BIO")
                            .font(.loggedMicro)
                            .foregroundStyle(.tertiary)
                            .tracking(1)

                        TextField("short bio", text: $bio)
                            .font(.loggedBody)
                            .textFieldStyle(.plain)
                            .padding(LoggedSpacing.m)
                            .background(Color.loggedCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
                            .overlay(
                                RoundedRectangle(cornerRadius: LoggedCornerRadius.m)
                                    .stroke(Color.loggedBorder, lineWidth: 0.5)
                            )
                    }

                    // Emoji picker
                    VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                        Text("AVATAR EMOJI")
                            .font(.loggedMicro)
                            .foregroundStyle(.tertiary)
                            .tracking(1)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: LoggedSpacing.m) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button {
                                    selectedEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 48, height: 48)
                                        .background(selectedEmoji == emoji ? Color.loggedAccent.opacity(0.2) : Color.loggedCardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.m))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: LoggedCornerRadius.m)
                                                .stroke(selectedEmoji == emoji ? Color.loggedAccent : Color.loggedBorder, lineWidth: selectedEmoji == emoji ? 1.5 : 0.5)
                                        )
                                }
                            }
                        }
                    }

                    // Color picker
                    VStack(alignment: .leading, spacing: LoggedSpacing.s) {
                        Text("AVATAR COLOR")
                            .font(.loggedMicro)
                            .foregroundStyle(.tertiary)
                            .tracking(1)

                        HStack(spacing: LoggedSpacing.m) {
                            ForEach(colorOptions, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                        )
                                        .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3), value: selectedColor)
                                }
                            }
                        }
                    }
                }
                .padding(LoggedSpacing.xl)
            }
            .background(Color.loggedBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                    .font(.loggedBody)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        saveProfile()
                        dismiss()
                    }
                    .font(.loggedBody)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            name = user.name
            bio = user.bio ?? ""
            selectedEmoji = user.avatarEmoji ?? ""
            selectedColor = user.avatarColor ?? "#4ADE80"
        }
    }

    private func saveProfile() {
        user.name = name
        user.bio = bio.isEmpty ? nil : bio
        user.avatarEmoji = selectedEmoji.isEmpty ? nil : selectedEmoji
        user.avatarColor = selectedColor
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [User.self, WorkoutCard.self, Workout.self, WorkoutSet.self, Exercise.self], inMemory: true)
}
