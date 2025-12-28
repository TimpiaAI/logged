import SwiftUI
import SwiftData
import Charts

struct StatsTabView: View {
    @Query private var workouts: [Workout]
    @Query private var users: [User]

    @State private var selectedExercise: String?

    private var currentUser: User? { users.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                    Text("stats")
                        .font(.loggedTitle)

                    // Quick stats row
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

                    // Progressive Overload Section
                    ProgressiveOverloadSection(workouts: completedWorkouts)

                    // Muscle Heat Map
                    MuscleHeatMapView(workouts: completedWorkouts)

                    // Activity Heatmap
                    HeatmapView(workouts: completedWorkouts)

                    // Personal Records
                    PRSection(workouts: completedWorkouts)

                    // Total stats
                    TotalStatsSection(workouts: completedWorkouts)
                }
                .padding(LoggedSpacing.xl)
            }
            .background(Color.loggedBackground)
            .navigationDestination(for: String.self) { exerciseName in
                ExerciseDetailView(exerciseName: exerciseName)
            }
        }
    }

    private var completedWorkouts: [Workout] {
        workouts.filter { $0.completedAt != nil }
    }

    private var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return completedWorkouts.filter { workout in
            guard let completedAt = workout.completedAt else { return false }
            return completedAt >= startOfWeek
        }.count
    }

    private var currentStreak: Int {
        // Simplified: count consecutive days with workouts
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())

        while true {
            let hasWorkout = completedWorkouts.contains { workout in
                guard let completedAt = workout.completedAt else { return false }
                return Calendar.current.isDate(completedAt, inSameDayAs: checkDate)
            }

            if hasWorkout {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        return streak
    }
}

// MARK: - Heatmap View
struct HeatmapView: View {
    let workouts: [Workout]

    private let columns = 13 // ~3 months
    private let rows = 7     // days of week

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            Text(currentMonth.lowercased())
                .font(.loggedCaption)
                .foregroundStyle(.tertiary)
                .tracking(0.5)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: columns), spacing: 3) {
                ForEach(0..<(columns * rows), id: \.self) { index in
                    let date = dateFor(index: index)
                    let hasWorkout = hasWorkoutOn(date: date)

                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(hasWorkout ? Color.loggedAccent : Color.loggedBorder)
                        .frame(height: 12)
                }
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }

    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }

    private func dateFor(index: Int) -> Date {
        let totalCells = columns * rows
        let daysAgo = totalCells - 1 - index
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    private func hasWorkoutOn(date: Date) -> Bool {
        workouts.contains { workout in
            guard let completedAt = workout.completedAt else { return false }
            return Calendar.current.isDate(completedAt, inSameDayAs: date)
        }
    }
}

// MARK: - PR Section
struct PRSection: View {
    let workouts: [Workout]

    private var personalRecords: [(name: String, weight: Double, reps: Int)] {
        // Group all sets by exercise and find max weight for each
        var prMap: [String: (weight: Double, reps: Int)] = [:]

        for workout in workouts {
            for set in workout.sets {
                let key = set.exerciseName.lowercased()
                let current = prMap[key]

                if let weight = set.weight {
                    if current == nil || weight > current!.weight {
                        prMap[key] = (weight: weight, reps: set.reps)
                    }
                }
            }
        }

        return prMap.map { (name: $0.key.capitalized, weight: $0.value.weight, reps: $0.value.reps) }
            .sorted { $0.weight > $1.weight }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            Text("personal records")
                .font(.loggedCaption)
                .foregroundStyle(.tertiary)
                .tracking(0.5)

            if personalRecords.isEmpty {
                VStack(spacing: LoggedSpacing.m) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                        .padding(.top, LoggedSpacing.m)

                    VStack(spacing: LoggedSpacing.xs) {
                        Text("no personal records yet")
                            .font(.loggedBody)
                            .foregroundStyle(.secondary)

                        Text("complete workouts to track your prs")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LoggedSpacing.l)
            } else {
                ForEach(personalRecords, id: \.name) { pr in
                    NavigationLink(value: pr.name) {
                        HStack {
                            Text(pr.name.lowercased())
                                .font(.loggedBody)
                                .foregroundStyle(.primary)

                            Spacer()

                            HStack(spacing: LoggedSpacing.xs) {
                                Text("\(Int(pr.weight))kg")
                                    .font(.loggedBody)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.loggedPR)

                                Text("× \(pr.reps)")
                                    .font(.loggedCaption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, LoggedSpacing.s)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Total Stats Section
struct TotalStatsSection: View {
    let workouts: [Workout]

    private var totalWorkouts: Int { workouts.count }

    private var totalVolume: Double {
        workouts.flatMap { $0.sets }
            .compactMap { set -> Double? in
                guard let weight = set.weight else { return nil }
                return weight * Double(set.reps)
            }
            .reduce(0, +)
    }

    private var totalSets: Int {
        workouts.flatMap { $0.sets }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            Text("all time")
                .font(.loggedCaption)
                .foregroundStyle(.tertiary)
                .tracking(0.5)

            HStack(spacing: LoggedSpacing.m) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalWorkouts)")
                        .font(.system(size: 28, weight: .medium, design: .monospaced))
                    Text("workouts")
                        .font(.loggedMicro)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalSets)")
                        .font(.system(size: 28, weight: .medium, design: .monospaced))
                    Text("sets")
                        .font(.loggedMicro)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(totalVolume / 1000))k")
                        .font(.system(size: 28, weight: .medium, design: .monospaced))
                    Text("volume (kg)")
                        .font(.loggedMicro)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Exercise Detail View
struct ExerciseDetailView: View {
    let exerciseName: String

    @Query private var workouts: [Workout]

    private var exerciseSets: [WorkoutSet] {
        workouts.flatMap { $0.sets }
            .filter { $0.exerciseName.lowercased() == exerciseName.lowercased() }
            .sorted { ($0.workout?.startedAt ?? Date()) < ($1.workout?.startedAt ?? Date()) }
    }

    private var progressData: [(date: Date, weight: Double)] {
        var data: [(Date, Double)] = []
        var seen: Set<String> = []

        for set in exerciseSets {
            guard let weight = set.weight,
                  let date = set.workout?.startedAt else { continue }

            let key = Calendar.current.startOfDay(for: date).description
            if !seen.contains(key) {
                data.append((date, weight))
                seen.insert(key)
            }
        }

        return data.suffix(10).map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LoggedSpacing.xl) {
                Text(exerciseName.lowercased())
                    .font(.loggedTitle)

                // Progress chart
                ProgressChartView(dataPoints: progressData)

                // Recent history
                RecentHistoryView(sets: Array(exerciseSets.suffix(20)))
            }
            .padding(LoggedSpacing.xl)
        }
    }
}

// MARK: - Progress Chart
struct ProgressChartView: View {
    let dataPoints: [(date: Date, weight: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            Text("progress")
                .font(.loggedCaption)
                .foregroundStyle(.secondary)

            if dataPoints.isEmpty {
                VStack(spacing: LoggedSpacing.m) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 28))
                        .foregroundStyle(.tertiary)

                    VStack(spacing: LoggedSpacing.xs) {
                        Text("no progress data available")
                            .font(.loggedBody)
                            .foregroundStyle(.secondary)

                        Text("log this exercise multiple times")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            } else {
                GeometryReader { geometry in
                    let maxWeight = dataPoints.map { $0.weight }.max() ?? 1
                    let minWeight = dataPoints.map { $0.weight }.min() ?? 0
                    let range = max(maxWeight - minWeight, 1)

                    Path { path in
                        for (index, point) in dataPoints.enumerated() {
                            let x = geometry.size.width * CGFloat(index) / CGFloat(max(dataPoints.count - 1, 1))
                            let y = geometry.size.height * (1 - CGFloat((point.weight - minWeight) / range))

                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.loggedAccent, lineWidth: 2)

                    ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, point in
                        let x = geometry.size.width * CGFloat(index) / CGFloat(max(dataPoints.count - 1, 1))
                        let y = geometry.size.height * (1 - CGFloat((point.weight - minWeight) / range))

                        Circle()
                            .fill(Color.loggedAccent)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: 120)
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Recent History
struct RecentHistoryView: View {
    let sets: [WorkoutSet]

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            Text("recent")
                .font(.loggedCaption)
                .foregroundStyle(.secondary)

            ForEach(sets) { set in
                HStack {
                    if let date = set.workout?.startedAt {
                        Text(date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.loggedCaption)
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)
                    }

                    Spacer()

                    if let weight = set.weight {
                        Text("\(Int(weight))kg")
                            .font(.loggedBody)
                    } else {
                        Text("bw")
                            .font(.loggedBody)
                    }

                    Text("× \(set.reps)")
                        .font(.loggedCaption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, LoggedSpacing.xs)
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Progressive Overload Section
struct ProgressiveOverloadSection: View {
    let workouts: [Workout]

    private var topExercises: [String] {
        var exerciseCounts: [String: Int] = [:]
        for workout in workouts {
            for set in workout.sets {
                let name = set.exerciseName.lowercased()
                exerciseCounts[name, default: 0] += 1
            }
        }
        return exerciseCounts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.l) {
            Text("progressive overload")
                .font(.loggedCaption)
                .foregroundStyle(.tertiary)
                .tracking(0.5)

            if topExercises.isEmpty {
                VStack(spacing: LoggedSpacing.m) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                        .padding(.top, LoggedSpacing.m)

                    VStack(spacing: LoggedSpacing.xs) {
                        Text("no workout trends yet")
                            .font(.loggedBody)
                            .foregroundStyle(.secondary)

                        Text("log more sessions to track progress")
                            .font(.loggedCaption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, LoggedSpacing.l)
            } else {
                VStack(spacing: LoggedSpacing.m) {
                    // Volume Over Time Chart
                    VolumeProgressChart(workouts: workouts)

                    // Top Exercises Progress
                    ForEach(topExercises, id: \.self) { exercise in
                        ExerciseProgressChart(exerciseName: exercise, workouts: workouts)
                    }
                }
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LoggedCornerRadius.l, style: .continuous)
                .stroke(Color.loggedBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Volume Progress Chart
struct VolumeProgressChart: View {
    let workouts: [Workout]

    private var volumeData: [(date: Date, volume: Double)] {
        let sortedWorkouts = workouts
            .filter { $0.completedAt != nil }
            .sorted { ($0.completedAt ?? Date()) < ($1.completedAt ?? Date()) }

        return sortedWorkouts.compactMap { workout -> (Date, Double)? in
            guard let date = workout.completedAt else { return nil }
            let volume = workout.sets.reduce(0.0) { total, set in
                guard let weight = set.weight else { return total }
                return total + (weight * Double(set.reps))
            }
            return (date, volume)
        }.suffix(10).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            HStack {
                Text("total volume")
                    .font(.loggedCaption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let trend = volumeTrend {
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10))
                        Text("\(abs(Int(trend)))%")
                            .font(.loggedMicro)
                    }
                    .foregroundStyle(trend >= 0 ? Color.loggedAccent : Color.loggedError)
                }
            }

            if volumeData.count >= 2 {
                Chart(volumeData, id: \.date) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Volume", item.volume)
                    )
                    .foregroundStyle(Color.loggedAccent)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Volume", item.volume)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.loggedAccent.opacity(0.3), Color.loggedAccent.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Volume", item.volume)
                    )
                    .foregroundStyle(Color.loggedAccent)
                    .symbolSize(20)
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 80)
            } else {
                VStack(spacing: LoggedSpacing.s) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.tertiary)

                    VStack(spacing: 2) {
                        Text("not enough data")
                            .font(.loggedMicro)
                            .foregroundStyle(.secondary)

                        Text("complete 2+ workouts")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.quaternary)
                    }
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(LoggedSpacing.m)
        .background(Color.loggedBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))
    }

    private var volumeTrend: Double? {
        guard volumeData.count >= 2 else { return nil }
        let recent = volumeData.suffix(3).map { $0.volume }
        let older = volumeData.prefix(3).map { $0.volume }
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)
        guard olderAvg > 0 else { return nil }
        return ((recentAvg - olderAvg) / olderAvg) * 100
    }
}

// MARK: - Exercise Progress Chart
struct ExerciseProgressChart: View {
    let exerciseName: String
    let workouts: [Workout]

    private var progressData: [(date: Date, weight: Double, estimated1RM: Double)] {
        var data: [(Date, Double, Double)] = []
        var seenDates: Set<String> = []

        let allSets = workouts
            .flatMap { $0.sets }
            .filter { $0.exerciseName.lowercased() == exerciseName.lowercased() }
            .sorted { ($0.workout?.startedAt ?? Date()) < ($1.workout?.startedAt ?? Date()) }

        for set in allSets {
            guard let weight = set.weight,
                  let date = set.workout?.startedAt else { continue }

            let dateKey = Calendar.current.startOfDay(for: date).description
            if !seenDates.contains(dateKey) {
                // Brzycki formula for estimated 1RM
                let e1rm = weight * (36.0 / (37.0 - Double(set.reps)))
                data.append((date, weight, e1rm))
                seenDates.insert(dateKey)
            }
        }

        return data.suffix(8).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.s) {
            HStack {
                Text(exerciseName)
                    .font(.loggedCaption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let trend = weightTrend {
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10))
                        Text("\(abs(Int(trend)))%")
                            .font(.loggedMicro)
                    }
                    .foregroundStyle(trend >= 0 ? Color.loggedAccent : Color.loggedError)
                }
            }

            if progressData.count >= 2 {
                Chart {
                    ForEach(progressData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.weight)
                        )
                        .foregroundStyle(Color.loggedAccent)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.weight)
                        )
                        .foregroundStyle(Color.loggedAccent)
                        .symbolSize(16)
                    }

                    // Estimated 1RM line
                    ForEach(progressData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("E1RM", item.estimated1RM)
                        )
                        .foregroundStyle(Color.loggedPR.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text("\(Int(weight))")
                                    .font(.loggedMicro)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .frame(height: 60)
            } else {
                VStack(spacing: LoggedSpacing.s) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 18))
                        .foregroundStyle(.tertiary)

                    VStack(spacing: 2) {
                        Text("insufficient data")
                            .font(.loggedMicro)
                            .foregroundStyle(.secondary)

                        Text("perform exercise 2+ times")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.quaternary)
                    }
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(LoggedSpacing.m)
        .background(Color.loggedBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: LoggedCornerRadius.s))
    }

    private var weightTrend: Double? {
        guard progressData.count >= 2 else { return nil }
        let recent = progressData.suffix(2).map { $0.weight }
        let older = progressData.prefix(2).map { $0.weight }
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)
        guard olderAvg > 0 else { return nil }
        return ((recentAvg - olderAvg) / olderAvg) * 100
    }
}

#Preview {
    StatsTabView()
        .modelContainer(for: [User.self, WorkoutCard.self, Workout.self, WorkoutSet.self, Exercise.self], inMemory: true)
}
