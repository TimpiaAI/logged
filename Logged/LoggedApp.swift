import SwiftUI
import SwiftData

@main
struct LoggedApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            WorkoutCard.self,
            Workout.self,
            WorkoutSet.self,
            Exercise.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @State private var timerManager = RestTimerManager()

    var body: some View {
        TabView {
            Tab("log", systemImage: "square.and.pencil") {
                LogTabView()
                    .environment(timerManager)
            }

            Tab("stats", systemImage: "chart.bar") {
                StatsTabView()
            }

            Tab("board", systemImage: "person.2") {
                BoardTabView()
            }

            Tab("settings", systemImage: "gearshape") {
                SettingsView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .task {
            // Request notification permission for rest timer
            await RestTimerManager.requestNotificationPermission()
        }
    }
}

#Preview {
    MainTabView()
}
