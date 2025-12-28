# Logged - Minimalist Workout Tracker

A SwiftUI iOS 26 app with Liquid Glass design for tracking workouts using natural text input.

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode 26
2. File → New → Project
3. Select "App" under iOS
4. Configure:
   - Product Name: `Logged`
   - Organization Identifier: `com.yourname`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData
5. **Important**: Set Deployment Target to iOS 26.0
6. Save to: `/Users/ovipi/logged/` (replace the empty Logged folder)

### 2. Add Source Files

After creating the project:

1. Delete the auto-generated `ContentView.swift` and `Item.swift`
2. In Xcode, right-click on the Logged folder → Add Files to "Logged"
3. Navigate to `/Users/ovipi/logged/Logged/`
4. Select all folders:
   - `Core/`
   - `Features/`
   - `Models/`
5. Check "Copy items if needed"
6. Check "Create groups"
7. Click Add
8. Replace the generated `LoggedApp.swift` with ours

### 3. Build & Run

1. Select an iOS 26 Simulator
2. Press Cmd+R to build and run

## Project Structure

```
Logged/
├── LoggedApp.swift              # App entry point
├── Core/
│   ├── Design/                  # Styling constants, glass components
│   ├── Components/              # Reusable UI components
│   ├── Parser/                  # Workout text parser
│   └── Timer/                   # Rest timer logic
├── Models/                      # SwiftData models
│   ├── User.swift
│   ├── WorkoutCard.swift
│   ├── Workout.swift
│   ├── WorkoutSet.swift
│   └── Exercise.swift
└── Features/
    ├── Onboarding/              # 10-step onboarding flow
    ├── Log/                     # Main workout logging
    ├── Stats/                   # Analytics & PRs
    └── Settings/                # App settings
```

## Features

- **Notes-style input**: Type naturally like "Bench 80kg 8/8/6"
- **Liquid Glass UI**: iOS 26 design with glass effects
- **Text ↔ Preview toggle**: Switch between writing and visual mode
- **Workout cards**: Organize by day (Push, Pull, Legs)
- **Progress tracking**: Heatmap, PRs, exercise history
- **Rest timer**: With haptics and notifications
- **SwiftData persistence**: Local-first, no account required

## Text Parsing Formats

| Input | Parsed |
|-------|--------|
| `Bench 80kg 8/8/6` | Bench Press, 80kg, sets: [8, 8, 6] |
| `Deadlift 3x5 140` | Deadlift, 140kg, sets: [5, 5, 5] |
| `Pull-ups BW 10/8/7` | Pull-ups, bodyweight, [10, 8, 7] |
| `.... (note)` | Comment/note |

## Requirements

- Xcode 26
- iOS 26 SDK
- iOS 26+ device or simulator

## Future Enhancements

- Supabase backend for cloud sync
- Leaderboard with friends
- Apple Watch companion
- Benchmarking against strength standards
