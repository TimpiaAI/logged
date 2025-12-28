import SwiftUI

// MARK: - Muscle Groups
enum MuscleGroup: String, CaseIterable, Identifiable {
    case chest
    case shoulders
    case biceps
    case triceps
    case forearms
    case abs
    case obliques
    case quads
    case hamstrings
    case glutes
    case calves
    case traps
    case lats
    case lowerBack
    case neck

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lowerBack: return "lower back"
        case .traps: return "traps"
        case .lats: return "lats"
        default: return rawValue
        }
    }

    var isFrontMuscle: Bool {
        switch self {
        case .chest, .shoulders, .biceps, .forearms, .abs, .obliques, .quads, .neck:
            return true
        default:
            return false
        }
    }
}

// MARK: - Exercise to Muscle Mapping
struct ExerciseMuscleMap {
    static func muscles(for exerciseName: String) -> [MuscleGroup] {
        let name = exerciseName.lowercased()

        if name.contains("bench") || name.contains("chest") || name.contains("push-up") || name.contains("pushup") || name.contains("fly") || name.contains("dip") {
            return [.chest, .shoulders, .triceps]
        }
        if name.contains("shoulder") || name.contains("lateral") || name.contains("delt") || name.contains("ohp") || name.contains("military") || name.contains("press") && !name.contains("bench") && !name.contains("leg") {
            return [.shoulders, .triceps]
        }
        if name.contains("row") || name.contains("pull") || name.contains("lat") || name.contains("back") && !name.contains("lower") {
            return [.lats, .traps, .biceps]
        }
        if name.contains("deadlift") {
            return [.lowerBack, .glutes, .hamstrings, .traps]
        }
        if name.contains("curl") || name.contains("bicep") {
            return [.biceps, .forearms]
        }
        if name.contains("tricep") || name.contains("pushdown") || name.contains("skull") {
            return [.triceps]
        }
        if name.contains("squat") || name.contains("leg press") || name.contains("lunge") {
            return [.quads, .glutes, .hamstrings]
        }
        if name.contains("leg curl") || name.contains("hamstring") {
            return [.hamstrings]
        }
        if name.contains("leg extension") || name.contains("quad") {
            return [.quads]
        }
        if name.contains("calf") || name.contains("calves") {
            return [.calves]
        }
        if name.contains("glute") || name.contains("hip thrust") {
            return [.glutes, .hamstrings]
        }
        if name.contains("crunch") || name.contains("plank") || name.contains("sit-up") || name.contains("situp") || name.contains("ab") {
            return [.abs, .obliques]
        }
        if name.contains("shrug") || name.contains("trap") {
            return [.traps]
        }
        return []
    }
}

// MARK: - SVG Path Data
struct BodySVGData {
    // Anterior (Front) View - coordinate space: 100 x 220
    static let anteriorChest: [[CGPoint]] = [
        parsePoints("51.8367347 41.6326531 51.0204082 55.1020408 57.9591837 57.9591837 67.755102 55.5102041 70.6122449 47.3469388 62.0408163 41.6326531"),
        parsePoints("29.7959184 46.5306122 31.4285714 55.5102041 40.8163265 57.9591837 48.1632653 55.1020408 47.755102 42.0408163 37.5510204 42.0408163")
    ]

    static let anteriorAbs: [[CGPoint]] = [
        parsePoints("56.3265306 59.1836735 57.9591837 64.0816327 58.3673469 77.9591837 58.3673469 92.6530612 56.3265306 98.3673469 55.1020408 104.081633 51.4285714 107.755102 51.0204082 84.4897959 50.6122449 67.3469388 51.0204082 57.1428571"),
        parsePoints("43.6734694 58.7755102 48.5714286 57.1428571 48.9795918 67.3469388 48.5714286 84.4897959 48.1632653 107.346939 44.4897959 103.673469 40.8163265 91.4285714 40.8163265 78.3673469 41.2244898 64.4897959")
    ]

    static let anteriorObliques: [[CGPoint]] = [
        parsePoints("68.5714286 63.2653061 67.3469388 57.1428571 58.7755102 59.5918367 60 64.0816327 60.4081633 83.2653061 65.7142857 78.7755102 66.5306122 69.7959184"),
        parsePoints("33.877551 78.3673469 33.0612245 71.8367347 31.0204082 63.2653061 32.244898 57.1428571 40.8163265 59.1836735 39.1836735 63.2653061 39.1836735 83.6734694")
    ]

    static let anteriorBiceps: [[CGPoint]] = [
        parsePoints("16.7346939 68.1632653 17.9591837 71.4285714 22.8571429 66.122449 28.9795918 53.877551 27.755102 49.3877551 20.4081633 55.9183673"),
        parsePoints("71.4285714 49.3877551 70.2040816 54.6938776 76.3265306 66.122449 81.6326531 71.8367347 82.8571429 68.9795918 78.7755102 55.5102041")
    ]

    static let anteriorTriceps: [[CGPoint]] = [
        parsePoints("69.3877551 55.5102041 69.3877551 61.6326531 75.9183673 72.6530612 77.5510204 70.2040816 75.5102041 67.3469388"),
        parsePoints("22.4489796 69.3877551 29.7959184 55.5102041 29.7959184 60.8163265 22.8571429 73.0612245")
    ]

    static let anteriorShoulders: [[CGPoint]] = [
        parsePoints("78.3673469 53.0612245 79.5918367 47.755102 79.1836735 41.2244898 75.9183673 37.9591837 71.0204082 36.3265306 72.244898 42.8571429 71.4285714 47.3469388"),
        parsePoints("28.1632653 47.3469388 21.2244898 53.0612245 20 47.755102 20.4081633 40.8163265 24.4897959 37.1428571 28.5714286 37.1428571 26.9387755 43.2653061")
    ]

    static let anteriorForearms: [[CGPoint]] = [
        parsePoints("6.12244898 88.5714286 10.2040816 75.1020408 14.6938776 70.2040816 16.3265306 74.2857143 19.1836735 73.4693878 4.48979592 97.5510204 0 100"),
        parsePoints("84.4897959 69.7959184 83.2653061 73.4693878 80 73.0612245 95.1020408 98.3673469 100 100.408163 93.4693878 89.3877551 89.7959184 76.3265306"),
        parsePoints("77.5510204 72.244898 77.5510204 77.5510204 80.4081633 84.0816327 85.3061224 89.7959184 92.244898 101.22449 94.6938776 99.5918367"),
        parsePoints("6.93877551 101.22449 13.4693878 90.6122449 18.7755102 84.0816327 21.6326531 77.1428571 21.2244898 71.8367347 4.89795918 98.7755102")
    ]

    static let anteriorQuads: [[CGPoint]] = [
        parsePoints("34.6938776 98.7755102 37.1428571 108.163265 37.1428571 127.755102 34.2857143 137.142857 31.0204082 132.653061 29.3877551 120 28.1632653 111.428571 29.3877551 100.816327 32.244898 94.6938776"),
        parsePoints("63.2653061 105.714286 64.4897959 100 66.9387755 94.6938776 70.2040816 101.22449 71.0204082 111.836735 68.1632653 133.061224 65.3061224 137.55102 62.4489796 128.571429 62.0408163 111.428571"),
        parsePoints("38.7755102 129.387755 38.3673469 112.244898 41.2244898 118.367347 44.4897959 129.387755 42.8571429 135.102041 40 146.122449 36.3265306 146.530612 35.5102041 140"),
        parsePoints("59.5918367 145.714286 55.5102041 128.979592 60.8163265 113.877551 61.2244898 130.204082 64.0816327 139.591837 62.8571429 146.530612"),
        parsePoints("32.6530612 138.367347 26.5306122 145.714286 25.7142857 136.734694 25.7142857 127.346939 26.9387755 114.285714 29.3877551 133.469388"),
        parsePoints("71.8367347 113.061224 73.877551 124.081633 73.877551 140.408163 72.6530612 145.714286 66.5306122 138.367347 70.2040816 133.469388")
    ]

    static let anteriorCalves: [[CGPoint]] = [
        parsePoints("71.4285714 160.408163 73.4693878 153.469388 76.7346939 161.22449 79.5918367 167.755102 78.3673469 187.755102 79.5918367 195.510204 74.6938776 195.510204"),
        parsePoints("24.8979592 194.693878 27.755102 164.897959 28.1632653 160.408163 26.122449 154.285714 24.8979592 157.55102 22.4489796 161.632653 20.8163265 167.755102 22.0408163 188.163265 20.8163265 195.510204"),
        parsePoints("72.6530612 195.102041 69.7959184 159.183673 65.3061224 158.367347 64.0816327 162.44898 64.0816327 165.306122 65.7142857 177.142857"),
        parsePoints("35.5102041 158.367347 35.9183673 162.44898 35.9183673 166.938776 35.1020408 172.244898 35.1020408 176.734694 32.244898 182.040816 30.6122449 187.346939 26.9387755 194.693878 27.3469388 187.755102 28.1632653 180.408163 28.5714286 175.510204 28.9795918 169.795918 29.7959184 164.081633 30.2040816 158.77551")
    ]

    static let anteriorNeck: [[CGPoint]] = [
        parsePoints("55.5102041 23.6734694 50.6122449 33.4693878 50.6122449 39.1836735 61.6326531 40 70.6122449 44.8979592 69.3877551 36.7346939 63.2653061 35.1020408 58.3673469 30.6122449"),
        parsePoints("28.9795918 44.8979592 30.2040816 37.1428571 36.3265306 35.1020408 41.2244898 30.2040816 44.4897959 24.4897959 48.9795918 33.877551 48.5714286 39.1836735 37.9591837 39.5918367")
    ]

    // Posterior (Back) View
    static let posteriorTraps: [[CGPoint]] = [
        parsePoints("44.6808511 21.7021277 47.6595745 21.7021277 47.2340426 38.2978723 47.6595745 64.6808511 38.2978723 53.1914894 35.3191489 40.8510638 31.0638298 36.5957447 39.1489362 33.1914894 43.8297872 27.2340426"),
        parsePoints("52.3404255 21.7021277 55.7446809 21.7021277 56.5957447 27.2340426 60.8510638 32.7659574 68.9361702 36.5957447 64.6808511 40.4255319 61.7021277 53.1914894 52.3404255 64.6808511 53.1914894 38.2978723")
    ]

    static let posteriorLats: [[CGPoint]] = [
        parsePoints("31.0638298 38.7234043 28.0851064 48.9361702 28.5106383 55.3191489 34.0425532 75.3191489 47.2340426 71.0638298 47.2340426 66.3829787 36.5957447 54.0425532 33.6170213 41.2765957"),
        parsePoints("68.9361702 38.7234043 71.9148936 49.3617021 71.4893617 56.1702128 65.9574468 75.3191489 52.7659574 71.0638298 52.7659574 66.3829787 63.4042553 54.4680851 66.3829787 41.7021277")
    ]

    static let posteriorShoulders: [[CGPoint]] = [
        parsePoints("29.3617021 37.0212766 22.9787234 39.1489362 17.4468085 44.2553191 18.2978723 53.6170213 24.2553191 49.3617021 27.2340426 46.3829787"),
        parsePoints("71.0638298 37.0212766 78.2978723 39.5744681 82.5531915 44.6808511 81.7021277 53.6170213 74.893617 48.9361702 72.3404255 45.106383")
    ]

    static let posteriorTriceps: [[CGPoint]] = [
        parsePoints("26.8085106 49.787234 17.8723404 55.7446809 14.4680851 72.3404255 16.5957447 81.7021277 21.7021277 63.8297872 26.8085106 55.7446809"),
        parsePoints("73.6170213 50.212766 82.1276596 55.7446809 85.9574468 73.1914894 83.4042553 82.1276596 77.8723404 62.9787234 73.1914894 55.7446809"),
        parsePoints("26.8085106 58.2978723 26.8085106 68.5106383 22.9787234 75.3191489 19.1489362 77.4468085 22.5531915 65.5319149"),
        parsePoints("72.7659574 58.2978723 77.0212766 64.6808511 80.4255319 77.4468085 76.5957447 75.3191489 72.7659574 68.9361702")
    ]

    static let posteriorLowerBack: [[CGPoint]] = [
        parsePoints("47.6595745 72.7659574 34.4680851 77.0212766 35.3191489 83.4042553 49.3617021 102.12766 46.8085106 82.9787234"),
        parsePoints("52.3404255 72.7659574 65.5319149 77.0212766 64.6808511 83.4042553 50.6382979 102.12766 53.1914894 83.8297872")
    ]

    static let posteriorGlutes: [[CGPoint]] = [
        parsePoints("44.6808511 99.5744681 30.212766 108.510638 29.787234 118.723404 31.4893617 125.957447 47.2340426 121.276596 49.3617021 114.893617"),
        parsePoints("55.3191489 99.1489362 51.0638298 114.468085 52.3404255 120.851064 68.0851064 125.957447 69.787234 119.148936 69.3617021 108.510638")
    ]

    static let posteriorHamstrings: [[CGPoint]] = [
        parsePoints("28.9361702 122.12766 31.0638298 129.361702 36.5957447 125.957447 35.3191489 135.319149 34.4680851 150.212766 29.3617021 158.297872 28.9361702 146.808511 27.6595745 141.276596 27.2340426 131.489362"),
        parsePoints("71.4893617 121.702128 69.3617021 128.93617 63.8297872 125.957447 65.5319149 136.595745 66.3829787 150.212766 71.0638298 158.297872 71.4893617 147.659574 72.7659574 142.12766 73.6170213 131.914894"),
        parsePoints("38.7234043 125.531915 44.2553191 145.957447 40.4255319 166.808511 36.1702128 152.765957 37.0212766 135.319149"),
        parsePoints("61.7021277 125.531915 63.4042553 136.170213 64.2553191 153.191489 60 166.808511 56.1702128 146.382979")
    ]

    static let posteriorCalves: [[CGPoint]] = [
        parsePoints("29.3617021 160.425532 28.5106383 167.234043 24.6808511 179.574468 23.8297872 192.765957 25.5319149 197.021277 28.5106383 193.191489 29.787234 180 31.9148936 171.06383 31.9148936 166.808511"),
        parsePoints("37.4468085 165.106383 35.3191489 167.659574 33.1914894 171.914894 31.0638298 180.425532 30.212766 191.914894 34.0425532 200 38.7234043 190.638298 39.1489362 168.93617"),
        parsePoints("62.9787234 165.106383 61.2765957 168.510638 61.7021277 190.638298 66.3829787 199.574468 70.6382979 191.914894 68.9361702 179.574468 66.8085106 170.212766"),
        parsePoints("70.6382979 160.425532 72.3404255 168.510638 75.7446809 179.148936 76.5957447 192.765957 74.4680851 196.595745 72.3404255 193.617021 70.6382979 179.574468 68.0851064 168.085106")
    ]

    static let posteriorForearms: [[CGPoint]] = [
        parsePoints("86.3829787 75.7446809 91.0638298 83.4042553 93.1914894 94.0425532 100 106.382979 96.1702128 104.255319 88.0851064 89.3617021 84.2553191 83.8297872"),
        parsePoints("13.6170213 75.7446809 8.93617021 83.8297872 6.80851064 93.6170213 0 106.382979 3.82978723 104.255319 12.3404255 88.5106383 15.7446809 82.9787234"),
        parsePoints("81.2765957 79.5744681 77.4468085 77.8723404 79.1489362 84.6808511 91.0638298 103.829787 93.1914894 108.93617 94.4680851 104.680851"),
        parsePoints("18.7234043 79.5744681 22.1276596 77.8723404 20.8510638 84.2553191 9.36170213 102.978723 6.80851064 108.510638 5.10638298 104.680851")
    ]

    // Helper to parse SVG point strings
    static func parsePoints(_ str: String) -> [CGPoint] {
        let numbers = str.split(separator: " ").compactMap { Double($0) }
        var points: [CGPoint] = []
        for i in stride(from: 0, to: numbers.count - 1, by: 2) {
            points.append(CGPoint(x: numbers[i], y: numbers[i + 1]))
        }
        return points
    }
}

// MARK: - Muscle Heat Map View
struct MuscleHeatMapView: View {
    let workouts: [Workout]
    @State private var showingFront = true

    private var muscleIntensity: [MuscleGroup: Double] {
        var intensity: [MuscleGroup: Double] = [:]
        for muscle in MuscleGroup.allCases { intensity[muscle] = 0 }

        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()

        let weekWorkouts = workouts.filter { workout in
            guard let completedAt = workout.completedAt else { return false }
            return completedAt >= startOfWeek
        }

        for workout in weekWorkouts {
            let exercises = WorkoutParser.parse(text: workout.rawText)
            for exercise in exercises {
                let muscles = ExerciseMuscleMap.muscles(for: exercise.name)
                let volume = Double(exercise.sets.reduce(0, +)) * (exercise.weight ?? 1)
                for muscle in muscles {
                    intensity[muscle, default: 0] += volume
                }
            }
        }

        let maxIntensity = intensity.values.max() ?? 1
        if maxIntensity > 0 {
            for muscle in MuscleGroup.allCases {
                intensity[muscle] = (intensity[muscle] ?? 0) / maxIntensity
            }
        }
        return intensity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LoggedSpacing.m) {
            HStack {
                Text("muscle activation")
                    .font(.loggedCaption)
                    .foregroundStyle(.tertiary)
                    .tracking(0.5)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { showingFront.toggle() }
                } label: {
                    Text(showingFront ? "front" : "back")
                        .font(.loggedMicro)
                        .foregroundStyle(Color.loggedAccent)
                }
            }

            HStack(alignment: .center, spacing: LoggedSpacing.l) {
                ZStack {
                    if showingFront {
                        AnteriorBodyView(intensity: muscleIntensity)
                    } else {
                        PosteriorBodyView(intensity: muscleIntensity)
                    }
                }
                .frame(width: 120, height: 240)

                VStack(alignment: .leading, spacing: LoggedSpacing.xs) {
                    let muscles = showingFront
                        ? MuscleGroup.allCases.filter { $0.isFrontMuscle }
                        : MuscleGroup.allCases.filter { !$0.isFrontMuscle }

                    ForEach(muscles) { muscle in
                        HStack(spacing: LoggedSpacing.s) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(colorForIntensity(muscleIntensity[muscle] ?? 0))
                                .frame(width: 10, height: 10)
                            Text(muscle.displayName)
                                .font(.loggedMicro)
                                .foregroundStyle(muscleIntensity[muscle, default: 0] > 0 ? .primary : .tertiary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: LoggedSpacing.xs) {
                Text("none").font(.loggedMicro).foregroundStyle(.tertiary)
                GeometryReader { _ in
                    HStack(spacing: 1) {
                        ForEach(0..<16, id: \.self) { i in
                            Rectangle().fill(Color.loggedAccent.opacity(Double(i) / 16.0 * 0.7 + 0.2))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                .frame(height: 6)
                Text("high").font(.loggedMicro).foregroundStyle(.tertiary)
            }
        }
        .padding(LoggedSpacing.l)
        .background(Color.loggedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.loggedBorder, lineWidth: 0.5))
    }

    private func colorForIntensity(_ intensity: Double) -> Color {
        intensity <= 0 ? Color(white: 0.5) : Color.loggedAccent.opacity(0.3 + intensity * 0.7)
    }
}

// MARK: - Anterior Body View
struct AnteriorBodyView: View {
    let intensity: [MuscleGroup: Double]

    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / 100
            let scaleY = size.height / 220

            func drawPolygons(_ polygons: [[CGPoint]], muscle: MuscleGroup) {
                for points in polygons {
                    var path = Path()
                    for (i, pt) in points.enumerated() {
                        let scaled = CGPoint(x: pt.x * scaleX, y: pt.y * scaleY)
                        if i == 0 { path.move(to: scaled) } else { path.addLine(to: scaled) }
                    }
                    path.closeSubpath()
                    context.fill(path, with: .color(colorFor(muscle)))
                    context.stroke(path, with: .color(Color.loggedBorder.opacity(0.2)), lineWidth: 0.5)
                }
            }

            // Draw in order: back to front
            drawPolygons(BodySVGData.anteriorNeck, muscle: .neck)
            drawPolygons(BodySVGData.anteriorShoulders, muscle: .shoulders)
            drawPolygons(BodySVGData.anteriorChest, muscle: .chest)
            drawPolygons(BodySVGData.anteriorBiceps, muscle: .biceps)
            drawPolygons(BodySVGData.anteriorTriceps, muscle: .triceps)
            drawPolygons(BodySVGData.anteriorForearms, muscle: .forearms)
            drawPolygons(BodySVGData.anteriorObliques, muscle: .obliques)
            drawPolygons(BodySVGData.anteriorAbs, muscle: .abs)
            drawPolygons(BodySVGData.anteriorQuads, muscle: .quads)
            drawPolygons(BodySVGData.anteriorCalves, muscle: .calves)

            // Head outline
            let headPath = Path(ellipseIn: CGRect(x: 42 * scaleX, y: 2 * scaleY, width: 16 * scaleX, height: 20 * scaleY))
            context.stroke(headPath, with: .color(Color.loggedBorder.opacity(0.5)), lineWidth: 1)
        }
    }

    private func colorFor(_ muscle: MuscleGroup) -> Color {
        let value = intensity[muscle] ?? 0
        return value <= 0 ? Color(white: 0.5) : Color.loggedAccent.opacity(0.3 + value * 0.7)
    }
}

// MARK: - Posterior Body View
struct PosteriorBodyView: View {
    let intensity: [MuscleGroup: Double]

    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / 100
            let scaleY = size.height / 220

            func drawPolygons(_ polygons: [[CGPoint]], muscle: MuscleGroup) {
                for points in polygons {
                    var path = Path()
                    for (i, pt) in points.enumerated() {
                        let scaled = CGPoint(x: pt.x * scaleX, y: pt.y * scaleY)
                        if i == 0 { path.move(to: scaled) } else { path.addLine(to: scaled) }
                    }
                    path.closeSubpath()
                    context.fill(path, with: .color(colorFor(muscle)))
                    context.stroke(path, with: .color(Color.loggedBorder.opacity(0.2)), lineWidth: 0.5)
                }
            }

            drawPolygons(BodySVGData.posteriorTraps, muscle: .traps)
            drawPolygons(BodySVGData.posteriorShoulders, muscle: .shoulders)
            drawPolygons(BodySVGData.posteriorLats, muscle: .lats)
            drawPolygons(BodySVGData.posteriorTriceps, muscle: .triceps)
            drawPolygons(BodySVGData.posteriorForearms, muscle: .forearms)
            drawPolygons(BodySVGData.posteriorLowerBack, muscle: .lowerBack)
            drawPolygons(BodySVGData.posteriorGlutes, muscle: .glutes)
            drawPolygons(BodySVGData.posteriorHamstrings, muscle: .hamstrings)
            drawPolygons(BodySVGData.posteriorCalves, muscle: .calves)

            // Head outline
            let headPath = Path(ellipseIn: CGRect(x: 40 * scaleX, y: 0, width: 20 * scaleX, height: 20 * scaleY))
            context.stroke(headPath, with: .color(Color.loggedBorder.opacity(0.5)), lineWidth: 1)
        }
    }

    private func colorFor(_ muscle: MuscleGroup) -> Color {
        let value = intensity[muscle] ?? 0
        return value <= 0 ? Color(white: 0.5) : Color.loggedAccent.opacity(0.3 + value * 0.7)
    }
}

#Preview {
    MuscleHeatMapView(workouts: [])
        .padding()
        .background(Color.loggedBackground)
}
