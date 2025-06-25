//
//  habittrackerApp.swift
//  habittracker
//
//  Created by Deyar Zakir on 24.06.25.
//

import SwiftUI
import SwiftData

@main
struct habittrackerApp: App {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboarding_completed")
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitCompletion.self
        ])
        
        // Use shared app group container for data sharing with widgets
        let sharedURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.habittracker.shared"
        )?.appendingPathComponent("HabitTracker.sqlite")
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: sharedURL ?? URL.documentsDirectory.appendingPathComponent("HabitTracker.sqlite"),
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
                } else {
                    MainTabView()
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showOnboarding)
        }
        .modelContainer(sharedModelContainer)
    }
}
