//
//  ContentView.swift
//  habittracker
//
//  Created by Deyar Zakir on 24.06.25.
//

import SwiftUI
import SwiftData
import WidgetKit

#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

// MARK: - Adaptive Colors Extension
extension Color {
    static var adaptiveText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white
                : UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0) // Helles Grau für optimale Lesbarkeit
        })
    }
    
    static var adaptiveSecondaryText: Color {
        Color(UIColor.secondaryLabel)
    }
    
    static var adaptiveTertiaryText: Color {
        Color(UIColor.tertiaryLabel)
    }
    
    static var adaptiveBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    static var adaptiveSecondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    static var adaptiveCardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white.withAlphaComponent(0.15)
                : UIColor.black.withAlphaComponent(0.05)
        })
    }
    
    static var adaptiveGlassmorphism: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white.withAlphaComponent(0.1)
                : UIColor.black.withAlphaComponent(0.05)
        })
    }
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 1 // Start with Daily View
    @State private var showingAddHabit = false

    var body: some View {
        ZStack {
            // Premium background with animated gradients
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "calendar.circle.fill" : "calendar.circle")
                    Text(L10n.navOverview.localized)
                }
                .tag(0)
            
            DailyView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "checkmark.circle.fill" : "checkmark.circle")
                    Text(L10n.navDaily.localized)
                }
                .tag(1)
            
                // Hidden tab for add habit
                Color.clear
                .tabItem {
                        Image(systemName: "plus.circle.fill")
                    Text(L10n.navAdd.localized)
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "chart.bar.fill" : "chart.bar")
                    Text(L10n.navStats.localized)
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                    Text(L10n.navProfile.localized)
                }
                .tag(4)
        }
            .tint(.adaptiveText)
        .onAppear {
                setupTabBarAppearance()
                createSampleDataIfNeeded()
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == 2 {
                    showingAddHabit = true
                    selectedTab = 1 // Return to daily view
                }
            }
            
            // Floating Action Button for Add Habit
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton {
                        showingAddHabit = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
    }
    
    private func setupTabBarAppearance() {
            #if os(iOS)
            let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        
        // Create adaptive glassmorphism effect
        tabBarAppearance.backgroundColor = UIColor.clear
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        // Style the tab items with adaptive colors
        let normalColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white.withAlphaComponent(0.6)
                : UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.7)
        }
        
        let selectedColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white
                : UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        }
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = normalColor
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor
        ]
        
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor
        ]
        
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            #endif
    }
    
    private func createSampleDataIfNeeded() {
        let descriptor = FetchDescriptor<Habit>()
        let existingHabits = try? modelContext.fetch(descriptor)
        
        if existingHabits?.isEmpty == true {
            // Create some sample habits with localized names
            let workout = Habit(name: "sample.workout".localized(), icon: "figure.run", color: "orange", category: L10n.categoryFitness.localized)
            let meditation = Habit(name: "sample.meditation".localized(), icon: "leaf", color: "green", category: L10n.categoryWellness.localized)
            let reading = Habit(name: "sample.reading".localized(), icon: "book", color: "blue", category: L10n.categoryEducation.localized)
            let water = Habit(name: "sample.water".localized(), icon: "drop", color: "teal", targetCount: 8, category: L10n.categoryHealth.localized)
            
            modelContext.insert(workout)
            modelContext.insert(meditation)
            modelContext.insert(reading)
            modelContext.insert(water)
            
            try? modelContext.save()
            
            // Update widgets when sample data is created
            WidgetCenter.shared.reloadTimelines(ofKind: "HabitTrackerWidget")
        }
    }
}

// MARK: - Animated Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
                LinearGradient(
                    colors: [
                Color(red: 0.2, green: 0.4, blue: 1.0),
                Color(red: 0.6, green: 0.2, blue: 1.0),
                Color(red: 1.0, green: 0.3, blue: 0.7),
                Color(red: 0.2, green: 0.8, blue: 1.0)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Shadow layer
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 64, height: 64)
                    .blur(radius: 8)
                    .offset(y: 4)
                
                // Main button
                Circle()
                    .fill(
                                            LinearGradient(
                            colors: [Color.adaptiveGlassmorphism.opacity(0.8), Color.adaptiveGlassmorphism.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.adaptiveText)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Daily View
struct DailyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query(sort: \HabitCompletion.date) private var allCompletions: [HabitCompletion]
    @State private var showingCompleted = false
    @State private var scrollOffset: CGFloat = 0
    
    var activeHabits: [Habit] {
        habits.filter { $0.isActive }
    }
    
    var body: some View {
        ZStack {
            Color.clear
            mainContent
        }
        .navigationBarHidden(true)
    }
    
    private var mainContent: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                headerSection
                habitsSection
            }
        }
        .coordinateSpace(name: "scroll")
    }
    
    private var headerSection: some View {
        GeometryReader { geometry in
            PremiumDailyHeader(
                progress: todayProgress,
                completed: completedHabitsCount,
                                    total: activeHabits.count,
                streak: calculateBestStreak(),
                scrollOffset: geometry.frame(in: .global).minY
            )
        }
        .frame(height: 280)
    }
    
    private var habitsSection: some View {
        LazyVStack(spacing: 20) {
            ForEach(Array(activeHabits.enumerated()), id: \.element.id) { index, habit in
                PremiumHabitCard(
                                    habit: habit, 
                                    allCompletions: allCompletions,
                                    onToggle: { toggleHabitCompletion(habit) },
                                    onDelete: { deleteHabit(habit) }
                                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 30)),
                    removal: .opacity.combined(with: .scale(scale: 0.8))
                ))
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: activeHabits.count)
                            }
                            
                            if activeHabits.isEmpty {
                PremiumEmptyStateView()
                                    .padding(.top, 40)
                            }
                        }
        .padding(.horizontal, 20)
        .padding(.bottom, 120)
    }
    
    private var completedHabitsCount: Int {
        activeHabits.filter { $0.isCompletedToday(allCompletions: allCompletions) }.count
    }
    
    private var todayProgress: Double {
        guard !activeHabits.isEmpty else { return 0 }
        return Double(completedHabitsCount) / Double(activeHabits.count)
    }
    
    private func calculateBestStreak() -> Int {
        return activeHabits.map { $0.currentStreak(allCompletions: allCompletions) }.max() ?? 0
    }
    
    private func deleteHabit(_ habit: Habit) {
        // Delete all associated completions first
        let habitCompletions = allCompletions.filter { $0.habitId == habit.id }
        for completion in habitCompletions {
            modelContext.delete(completion)
        }
        
        // Delete the habit
        modelContext.delete(habit)
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Error deleting habit: \(error)")
        }
        
        // Update widgets after deletion
        #if os(iOS)
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitTrackerWidget")
        #endif
    }
    
    private func toggleHabitCompletion(_ habit: Habit) {
        let today = Calendar.current.startOfDay(for: Date())
        let currentCompletions = habit.completionsForToday(allCompletions: allCompletions)
        
        if currentCompletions >= habit.targetCount {
            // If fully completed, remove all completions for today
            let completionsToDelete = allCompletions.filter { completion in
                completion.habitId == habit.id && 
                Calendar.current.isDate(completion.date, inSameDayAs: today)
            }
            
            for completion in completionsToDelete {
                modelContext.delete(completion)
            }
            
            // Haptic feedback for unchecking
            FeedbackGenerator.impact(.light)
        } else {
            // Add one more completion
            let completion = HabitCompletion(habitId: habit.id, date: Date())
            modelContext.insert(completion)
            
            // Different feedback based on whether target is reached
            if currentCompletions + 1 >= habit.targetCount {
                // Target reached - stronger feedback
                FeedbackGenerator.impact(.heavy)
            } else {
                // Progress - medium feedback
                FeedbackGenerator.impact(.medium)
            }
        }
        
        do {
            try modelContext.save()
            
            // Update widgets when data changes
            WidgetCenter.shared.reloadTimelines(ofKind: "HabitTrackerWidget")
        } catch {
            print("Error saving habit completion: \(error)")
        }
    }
}

// MARK: - Premium Daily Header
struct PremiumDailyHeader: View {
    let progress: Double
    let completed: Int
    let total: Int
    let streak: Int
    let scrollOffset: CGFloat
    
    private func calculateHeaderOpacity(_ offset: CGFloat) -> Double {
        return max(0.3, 1.0 + Double(offset) / 300.0)
    }
    
    var body: some View {
        ZStack {
            // Glassmorphism background with parallax
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [Color.adaptiveText.opacity(0.3), Color.clear, Color.adaptiveText.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                .scaleEffect(1 + max(0, scrollOffset) / 1000)
            
            VStack(spacing: 24) {
                // Title with animated text effect
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(L10n.dailyTitle.localized)
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.adaptiveText, .adaptiveText.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Animated sparkle effect
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .scaleEffect(1.2)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: progress)
                        }
                        
                        Text(Date(), format: .dateTime.weekday(.wide).day().month(.wide))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.adaptiveText.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Enhanced 3D Progress Ring
                    PremiumProgressRing(progress: progress)
                }
                
                // Enhanced Stats Grid
                if total > 0 {
                    PremiumStatsGrid(
                        completed: completed,
                        total: total,
                        streak: streak,
                        progress: progress
                    )
                }
            }
            .padding(24)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Premium Progress Ring
struct PremiumProgressRing: View {
    let progress: Double
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(Color.adaptiveText.opacity(0.1), lineWidth: 12)
                .frame(width: 90, height: 90)
                .blur(radius: 4)
            
            // Background ring
            Circle()
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            // Progress ring with enhanced gradient
            Circle()
                .trim(from: 0.0, to: CGFloat(animateProgress ? progress : 0))
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.yellow,
                            Color.orange,
                            Color.pink,
                            Color.purple,
                            Color.blue,
                            Color.yellow
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
                .shadow(color: .adaptiveText.opacity(0.3), radius: 8, x: 0, y: 0)
                .animation(.spring(response: 1.5, dampingFraction: 0.8), value: animateProgress)
            
            // Center content with glow effect
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.adaptiveText)
                    .shadow(color: .adaptiveText.opacity(0.5), radius: 4, x: 0, y: 0)
                
                Text("%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.adaptiveText.opacity(0.8))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.3)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Premium Stats Grid
struct PremiumStatsGrid: View {
    let completed: Int
    let total: Int
    let streak: Int
    let progress: Double
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            PremiumStatCard(
                title: "Completed",
                value: "\(completed)/\(total)",
                icon: "checkmark.circle.fill",
                color: .green,
                delay: 0.1
            )
            
            PremiumStatCard(
                title: "Streak",
                value: "\(streak)",
                icon: "flame.fill",
                color: .orange,
                delay: 0.2
            )
            
            PremiumStatCard(
                title: "Success",
                value: total > 0 ? "\(Int(progress * 100))%" : "0%",
                icon: "target",
                color: .blue,
                delay: 0.3
            )
        }
    }
}

// MARK: - Premium Stat Card
struct PremiumStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let delay: Double
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
                
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.adaptiveText.opacity(0.7))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(appear ? 1.0 : 0.8)
        .opacity(appear ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: appear)
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Premium Empty State
struct PremiumEmptyStateView: View {
    @State private var animateElements = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Animated background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateElements ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateElements)
                
                // Icon with glow
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.adaptiveText, .adaptiveText.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .adaptiveText.opacity(0.3), radius: 10, x: 0, y: 0)
            }
            
            VStack(spacing: 12) {
                Text("Ready to Start?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.adaptiveText, .adaptiveText.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Create your first habit and begin your journey to a better you")
                    .font(.body)
                    .foregroundColor(.adaptiveText.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .padding(.horizontal, 40)
        .onAppear {
            animateElements = true
        }
    }
}

// MARK: - Premium Habit Card
struct PremiumHabitCard: View {
    let habit: Habit
    let allCompletions: [HabitCompletion]
    let onToggle: () -> Void
    let onDelete: (() -> Void)?
    @State private var isPressed = false
    @State private var showCompletionEffect = false
    @State private var showingDeleteConfirmation = false
    
    var isCompleted: Bool {
        habit.isCompletedToday(allCompletions: allCompletions)
    }
    
    var completionProgress: Double {
        let current = habit.completionsForToday(allCompletions: allCompletions)
        return Double(current) / Double(habit.targetCount)
    }
    
    var body: some View {
        Button(action: {
            onToggle()
            if !isCompleted {
                triggerCompletionEffect()
            }
        }) {
        HStack(spacing: 20) {
                // Enhanced Icon with 3D effect
            ZStack {
                    // Glow effect
                    Circle()
                        .fill(habit.color.color.opacity(0.4))
                        .frame(width: 70, height: 70)
                        .blur(radius: 12)
                    
                    // Background with gradient
                Circle()
                    .fill(
                            RadialGradient(
                                colors: [
                                    habit.color.color.opacity(0.3),
                                    habit.color.color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 35
                            )
                        )
                        .frame(width: 65, height: 65)
                    
                    // Icon container
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(
                        LinearGradient(
                                        colors: [Color.adaptiveText.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                        )
                    )
                
                    // Icon
                Image(systemName: habit.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(habit.color.color)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                    
                    // Completion effect
                    if showCompletionEffect {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.adaptiveText)
                        }
                        .scaleEffect(showCompletionEffect ? 1.0 : 0.0)
                        .opacity(showCompletionEffect ? 1.0 : 0.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCompletionEffect)
                    }
                }
                
                // Enhanced Content
                VStack(alignment: .leading, spacing: 10) {
                Text(habit.name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.adaptiveText)
                        .lineLimit(1)
                    
                    HStack(spacing: 16) {
                        // Progress indicator with animation
                        HStack(spacing: 6) {
                        Image(systemName: "target")
                                .font(.caption)
                            .foregroundColor(habit.color.color)
                        
                        Text("daily.completions".localized(habit.completionsForToday(allCompletions: allCompletions), habit.targetCount))
                            .font(.caption)
                            .fontWeight(.medium)
                                .foregroundColor(.adaptiveText.opacity(0.8))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(habit.color.color.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    // Streak indicator
                    if habit.currentStreak(allCompletions: allCompletions) > 0 {
                            HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                    .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("\(habit.currentStreak(allCompletions: allCompletions))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
        .background(
                                Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                                        Capsule()
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.adaptiveText.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [habit.color.color, habit.color.color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * completionProgress, height: 8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completionProgress)
                        }
                    }
                    .frame(height: 8)
                }
                
                Spacer()
                
                // Completion status
            ZStack {
                Circle()
                        .fill(isCompleted ? Color.green.opacity(0.3) : Color.adaptiveText.opacity(0.1))
                        .frame(width: 32, height: 32)
                        .overlay(
                    Circle()
                        .stroke(
                                    isCompleted ? Color.green : Color.adaptiveText.opacity(0.3),
                                    lineWidth: 2
                        )
                        )
                
                    if isCompleted {
                    Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            }
            .padding(20)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.adaptiveText.opacity(0.3), Color.clear, Color.adaptiveText.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .contextMenu {
            if onDelete != nil {
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("habit.delete".localized(), systemImage: "trash")
                }
                .foregroundColor(.red)
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .confirmationDialog(
            "habit.deleteConfirmation".localized(),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("common.delete".localized(), role: .destructive) {
                onDelete?()
            }
            Button("common.cancel".localized(), role: .cancel) {}
        } message: {
            Text("habit.deleteWarning".localized())
        }
    }
    
    private func triggerCompletionEffect() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showCompletionEffect = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showCompletionEffect = false
            }
        }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query(sort: \HabitCompletion.date) private var allCompletions: [HabitCompletion]
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingMonthPicker = false
    @State private var headerOffset: CGFloat = 0
    
    var activeHabits: [Habit] {
        habits.filter { $0.isActive }
    }
    
    var body: some View {
            ZStack {
            // Background is now handled by MainTabView
            Color.clear
                
                ScrollView {
                LazyVStack(spacing: 32) {
                    // Premium Header with Parallax Effect
                    GeometryReader { geometry in
                        PremiumCalendarHeader(
                            currentMonth: currentMonth,
                            onPreviousMonth: {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                }
                            },
                            onNextMonth: {
                                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                }
                            },
                            onMonthTap: {
                                showingMonthPicker = true
                            },
                            scrollOffset: geometry.frame(in: .global).minY
                        )
                    }
                    .frame(height: 120)
                    
                    // Premium Calendar Grid
                    PremiumCalendarGrid(
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        habits: activeHabits,
                        allCompletions: allCompletions
                    )
                    .padding(.horizontal, 20)
                    
                    // Premium Selected Date Details
                    if !activeHabits.isEmpty {
                        PremiumDateDetails(
                            selectedDate: selectedDate,
                            habits: activeHabits,
                            allCompletions: allCompletions
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Monthly Statistics Card
                    PremiumMonthlyStats(
                        currentMonth: currentMonth,
                        habits: activeHabits,
                        allCompletions: allCompletions
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Space for tab bar
                }
                .padding(.top, 20)
            }
            .coordinateSpace(name: "scroll")
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerView(selectedMonth: $currentMonth)
        }
    }
}

// MARK: - Premium Calendar Header
struct PremiumCalendarHeader: View {
    let currentMonth: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let onMonthTap: () -> Void
    let scrollOffset: CGFloat
    @State private var headerScale = 1.0
    
    var body: some View {
                            HStack {
            VStack(alignment: .leading, spacing: 8) {
                                    Text(L10n.calendarTitle.localized)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                            colors: [.adaptiveText, .adaptiveText.opacity(0.9)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                Button(action: onMonthTap) {
                    HStack(spacing: 8) {
                        Text(currentMonth, format: .dateTime.month(.wide).year())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.adaptiveText.opacity(0.9))
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.adaptiveText.opacity(0.7))
                    }
                }
                                }
                                
                                Spacer()
                                
            // Premium Navigation Buttons
            HStack(spacing: 16) {
                PremiumNavigationButton(icon: "chevron.left", action: onPreviousMonth)
                PremiumNavigationButton(icon: "chevron.right", action: onNextMonth)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.adaptiveText.opacity(0.3), Color.clear, Color.adaptiveText.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .scaleEffect(1 + max(0, scrollOffset) / 1000)
                        .opacity(max(0.3, 1.0 + Double(scrollOffset) / 300.0))
    }
}

// MARK: - Premium Navigation Button
struct PremiumNavigationButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.adaptiveText)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Premium Calendar Grid
struct PremiumCalendarGrid: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 20) {
            // Weekday headers with style
            HStack {
                ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveText.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            
            // Calendar days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        PremiumCalendarDayCell(
                        date: date,
                            currentMonth: currentMonth,
                            selectedDate: selectedDate,
                        habits: habits,
                            allCompletions: allCompletions
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedDate = date
                        }
                    }
                    } else {
                        Color.clear
                            .frame(height: 48)
                    }
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
}

// MARK: - Premium Calendar Day Cell
struct PremiumCalendarDayCell: View {
    let date: Date
    let currentMonth: Date
    let selectedDate: Date
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    let onTap: () -> Void
    
    @State private var cellScale = 0.8
    @State private var isPressed = false
    
    private let calendar = Calendar.current
    
    var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    var completionRate: Double {
        guard !habits.isEmpty else { return 0 }
        let completedCount = habits.filter { habit in
            habit.isCompletedOnDate(date, allCompletions: allCompletions)
        }.count
        return Double(completedCount) / Double(habits.count)
    }
    
    var completedHabits: [Habit] {
        habits.filter { habit in
            habit.isCompletedOnDate(date, allCompletions: allCompletions)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Day number
            Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                    .foregroundColor(textColor)
            
                // Progress dots
                HStack(spacing: 2) {
                ForEach(Array(completedHabits.prefix(3)), id: \.id) { habit in
                    Circle()
                        .fill(habit.color.color)
                            .frame(width: 4, height: 4)
                            .shadow(color: habit.color.color.opacity(0.5), radius: 2, x: 0, y: 0)
                }
                
                if completedHabits.count > 3 {
                        Text("+")
                        .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.adaptiveText.opacity(0.7))
                }
            }
            .frame(height: 8)
        }
            .frame(width: 48, height: 48)
            .background(backgroundGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.95 : cellScale)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            let delay = Double.random(in: 0...0.5)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                cellScale = 1.0
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
                if isSelected {
            return LinearGradient(
                colors: [Color.adaptiveText.opacity(0.4), Color.adaptiveText.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
        } else if isToday {
            return LinearGradient(
                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if completionRate > 0 && isCurrentMonth {
            return LinearGradient(
                colors: [
                    Color.green.opacity(completionRate * 0.4),
                    Color.blue.opacity(completionRate * 0.2)
                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.adaptiveText.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .adaptiveText.opacity(0.8)
        } else if isToday {
            return .yellow.opacity(0.8)
        } else {
            return .adaptiveText.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .adaptiveText.opacity(0.4)
        } else if isSelected {
            return .white
        } else {
            return .adaptiveText.opacity(0.9)
        }
    }
}

// MARK: - Premium Date Details
struct PremiumDateDetails: View {
    let selectedDate: Date
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    @Environment(\.modelContext) private var modelContext
    
    private let calendar = Calendar.current
    
    var dayHabits: [(Habit, Bool)] {
        habits.map { habit in
            (habit, habit.isCompletedOnDate(selectedDate, allCompletions: allCompletions))
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(calendar.isDateInToday(selectedDate) ? L10n.calendarToday.localized : L10n.calendarSelectedDay.localized)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveText)
                    
                    Text(selectedDate, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(.subheadline)
                        .foregroundColor(.adaptiveText.opacity(0.8))
                }
                
                Spacer()
                
                // Completion summary
                let completedCount = dayHabits.filter(\.1).count
                VStack(spacing: 4) {
                    Text("\(completedCount)/\(habits.count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveText)
                    
                    Text("completed")
                    .font(.caption)
                        .foregroundColor(.adaptiveText.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Habits list
            LazyVStack(spacing: 12) {
                ForEach(Array(dayHabits.enumerated()), id: \.element.0.id) { index, habitData in
                    let (habit, isCompleted) = habitData
                    PremiumDateHabitRow(
                        habit: habit,
                        isCompleted: isCompleted,
                        selectedDate: selectedDate,
                        allCompletions: allCompletions,
                        animationDelay: Double(index) * 0.1
                    ) {
                        toggleHabitCompletion(habit, for: selectedDate)
                    }
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private func toggleHabitCompletion(_ habit: Habit, for date: Date) {
        let targetDate = calendar.startOfDay(for: date)
        let currentCompletions = habit.completionsForDate(date, allCompletions: allCompletions)
        
        if currentCompletions >= habit.targetCount {
            // If fully completed, remove all completions for this date
            let completionsToDelete = allCompletions.filter { completion in
                completion.habitId == habit.id && 
                calendar.isDate(completion.date, inSameDayAs: targetDate)
            }
            
            for completion in completionsToDelete {
                modelContext.delete(completion)
            }
            
            // Haptic feedback for unchecking
            FeedbackGenerator.impact(.light)
        } else {
            // Add one more completion
            let completion = HabitCompletion(habitId: habit.id, date: targetDate)
            modelContext.insert(completion)
            
            // Different feedback based on whether target is reached
            if currentCompletions + 1 >= habit.targetCount {
                // Target reached - stronger feedback
                FeedbackGenerator.impact(.heavy)
            } else {
                // Progress - medium feedback
                FeedbackGenerator.impact(.medium)
            }
        }
        
        do {
            try modelContext.save()
            
            // Update widgets when data changes
            WidgetCenter.shared.reloadTimelines(ofKind: "HabitTrackerWidget")
        } catch {
            print("Error saving habit completion: \(error)")
        }
    }
}

// MARK: - Premium Date Habit Row
struct PremiumDateHabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let selectedDate: Date
    let allCompletions: [HabitCompletion]
    let animationDelay: Double
    let onToggle: () -> Void
    @State private var appear = false
    
    var body: some View {
        Button(action: onToggle) {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(habit.color.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(habit.color.color)
            }
            
            // Habit info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                
                Text(habit.category)
                    .font(.caption)
                    .foregroundColor(.adaptiveText.opacity(0.7))
            }
            
            Spacer()
            
            // Status
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green.opacity(0.3) : Color.adaptiveText.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isCompleted ? Color.green : Color.adaptiveText.opacity(0.3), lineWidth: 2)
                    )
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .scaleEffect(appear ? 1.0 : 0.8)
        .opacity(appear ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(animationDelay), value: appear)
        .onAppear {
            appear = true
        }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Monthly Stats
struct PremiumMonthlyStats: View {
    let currentMonth: Date
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    
    private let calendar = Calendar.current
    
    var monthlyCompletionRate: Double {
        guard !habits.isEmpty else { return 0 }
        
        let monthStart = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let monthEnd = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 1
        let totalPossibleCompletions = habits.count * daysInMonth
        
        let actualCompletions = allCompletions.filter { completion in
            completion.date >= monthStart && completion.date < monthEnd
        }.count
        
        return Double(actualCompletions) / Double(totalPossibleCompletions)
    }
    
    var streakCount: Int {
        return habits.map { $0.currentStreak(allCompletions: allCompletions) }.max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                                  Text(L10n.calendarTitle.localized)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                
                Spacer()
                
                Text(currentMonth, format: .dateTime.month(.abbreviated))
                    .font(.subheadline)
                    .foregroundColor(.adaptiveText.opacity(0.8))
            }
            
            // Stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                PremiumStatCard(
                    title: "Completion",
                    value: "\(Int(monthlyCompletionRate * 100))%",
                    icon: "chart.pie.fill",
                    color: .green,
                    delay: 0.1
                )
                
                PremiumStatCard(
                    title: "Best Streak",
                    value: "\(streakCount)",
                    icon: "flame.fill",
                    color: .orange,
                    delay: 0.2
                )
                
                PremiumStatCard(
                    title: "Active",
                    value: "\(habits.count)",
                    icon: "list.bullet",
                    color: .blue,
                    delay: 0.3
                )
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Month Picker View
struct MonthPickerView: View {
    @Binding var selectedMonth: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium background
                                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.4, blue: 1.0),
                        Color(red: 0.6, green: 0.2, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    DatePicker(
                        "Select Month",
                        selection: $selectedMonth,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.adaptiveText)
                }
            }
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
            
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 12) {
                Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 4)
    }
}

struct ExportView: View {
    let habits: [Habit]
    @Environment(\.dismiss) private var dismiss
    @State private var exportText = ""
    @Query(sort: \HabitCompletion.date) private var allCompletions: [HabitCompletion]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(L10n.profileExportDescription.localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView {
                    Text(exportText)
                        .font(.caption)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                
                Button(L10n.profileCopyToClipboard.localized) {
                    ClipboardManager.copy(exportText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundColor(.adaptiveText)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.commonDone.localized) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            generateExportText()
        }
    }
    
    private func generateExportText() {
        var text = "HABIT TRACKER EXPORT\n"
        text += "===================\n\n"
        
        for habit in habits {
            text += "Habit: \(habit.name)\n"
            text += "Icon: \(habit.icon)\n"
            text += "Farbe: \(habit.color)\n"
            text += "Kategorie: \(habit.category)\n"
            text += "Ziel: \(habit.targetCount)x täglich\n"
            text += "Erstellt: \(habit.createdAt.formatted(date: .abbreviated, time: .omitted))\n"
            text += "Streak: \(habit.currentStreak(allCompletions: allCompletions)) Tage\n"
            let habitCompletions = allCompletions.filter { $0.habitId == habit.id }
            text += "Abschlüsse: \(habitCompletions.count)\n"
            text += "\n"
        }
        
        exportText = text
    }
}

// MARK: - Premium Stats View
struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query(sort: \HabitCompletion.date) private var allCompletions: [HabitCompletion]
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingTimeFramePicker = false
    
    var activeHabits: [Habit] {
        habits.filter { $0.isActive }
    }
    
    var body: some View {
            ZStack {
            // Background is now handled by MainTabView
            Color.clear
                
                ScrollView {
                LazyVStack(spacing: 32) {
                    // Premium Header
                    PremiumStatsHeader(
                        selectedTimeFrame: $selectedTimeFrame,
                        onTimeFrameTap: {
                            showingTimeFramePicker = true
                        }
                    )
                    
                    // Overview Cards
                    PremiumOverviewStats(
                        habits: activeHabits,
                        allCompletions: allCompletions,
                        timeFrame: selectedTimeFrame
                    )
                    .padding(.horizontal, 20)
                        
                        // Habit Performance
                    PremiumHabitPerformance(
                        habits: activeHabits,
                        allCompletions: allCompletions,
                        timeFrame: selectedTimeFrame
                    )
                    .padding(.horizontal, 20)
                        
                        // Weekly Pattern
                    PremiumWeeklyPattern(
                        habits: activeHabits,
                        allCompletions: allCompletions
                    )
                    .padding(.horizontal, 20)
                    
                    // Streak Analysis
                    PremiumStreakAnalysis(
                        habits: activeHabits,
                        allCompletions: allCompletions
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Space for tab bar
                }
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingTimeFramePicker) {
            TimeFramePickerView(selectedTimeFrame: $selectedTimeFrame)
        }
    }
}

// MARK: - Premium Stats Header
struct PremiumStatsHeader: View {
    @Binding var selectedTimeFrame: TimeFrame
    let onTimeFrameTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.statsTitle.localized)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.adaptiveText, .adaptiveText.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Button(action: onTimeFrameTap) {
                    HStack(spacing: 8) {
                        Text(selectedTimeFrame.localizedName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.adaptiveText.opacity(0.9))
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.adaptiveText.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Stats Icon with glow
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .blur(radius: 8)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.adaptiveText.opacity(0.3), Color.clear, Color.adaptiveText.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
}

// MARK: - Premium Overview Stats
struct PremiumOverviewStats: View {
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    let timeFrame: TimeFrame
    
    var todayCompletionCount: Int {
        habits.filter { $0.isCompletedToday(allCompletions: allCompletions) }.count
    }
    
    var averageCompletion: Double {
        guard !habits.isEmpty else { return 0 }
        let totalCompletions = habits.reduce(0) { sum, habit in
            return sum + completionsInTimeFrame(for: habit)
        }
        let totalPossible = habits.count * timeFrame.days
        return totalPossible > 0 ? Double(totalCompletions) / Double(totalPossible) : 0
    }
    
    var bestStreak: Int {
        habits.map { $0.currentStreak(allCompletions: allCompletions) }.max() ?? 0
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            PremiumStatCard(
                    title: L10n.statsTotalHabits.localized,
                    value: "\(habits.count)",
                    icon: "list.bullet",
                color: .blue,
                delay: 0.1
                )
                
            PremiumStatCard(
                    title: L10n.statsTodayCompleted.localized,
                    value: "\(todayCompletionCount)",
                icon: "checkmark.circle.fill",
                color: .green,
                delay: 0.2
                )
                
            PremiumStatCard(
                    title: L10n.statsAverageCompletion.localized,
                    value: "\(Int(averageCompletion * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                color: .orange,
                delay: 0.3
                )
                
            PremiumStatCard(
                    title: L10n.statsBestStreak.localized,
                    value: "\(bestStreak)",
                icon: "flame.fill",
                color: .red,
                delay: 0.4
            )
        }
    }
    
    private func completionsInTimeFrame(for habit: Habit) -> Int {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -timeFrame.days, to: endDate) ?? endDate
        
        return allCompletions.filter { completion in
            completion.habitId == habit.id &&
            completion.date >= startDate && completion.date <= endDate
        }.count
    }
}

// MARK: - Premium Habit Performance
struct PremiumHabitPerformance: View {
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    let timeFrame: TimeFrame
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text(L10n.statsHabitPerformance.localized)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                
                Spacer()
            }
            
            // Performance cards
            LazyVStack(spacing: 12) {
                ForEach(Array(habits.prefix(6).enumerated()), id: \.element.id) { index, habit in
                    PremiumHabitPerformanceCard(
                        habit: habit,
                        allCompletions: allCompletions,
                        timeFrame: timeFrame,
                        animationDelay: Double(index) * 0.1
                    )
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Premium Habit Performance Card
struct PremiumHabitPerformanceCard: View {
    let habit: Habit
    let allCompletions: [HabitCompletion]
    let timeFrame: TimeFrame
    let animationDelay: Double
    @State private var appear = false
    @State private var progressAnimation = 0.0
    
    var completionsCount: Int {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -timeFrame.days, to: endDate) ?? endDate
        
        return allCompletions.filter { completion in
            completion.habitId == habit.id &&
            completion.date >= startDate && completion.date <= endDate
        }.count
    }
    
    var completionRate: Double {
        let possible = timeFrame.days * habit.targetCount
        return possible > 0 ? Double(completionsCount) / Double(possible) : 0
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(habit.color.color.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .blur(radius: 8)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(habit.color.color.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: habit.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(habit.color.color)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                    .lineLimit(1)
                
                Text("\(completionsCount) completions")
                    .font(.caption)
                    .foregroundColor(.adaptiveText.opacity(0.7))
            }
            
            Spacer()
            
            // Progress
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(Int(completionRate * 100))%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(habit.color.color)
            
            // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.adaptiveText.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [habit.color.color, habit.color.color.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressAnimation, height: 8)
                    }
                }
                .frame(width: 80, height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .scaleEffect(appear ? 1.0 : 0.8)
        .opacity(appear ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(animationDelay), value: appear)
        .onAppear {
            appear = true
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(animationDelay + 0.3)) {
                progressAnimation = completionRate
            }
        }
    }
}

// MARK: - Premium Weekly Pattern
struct PremiumWeeklyPattern: View {
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    
    private let calendar = Calendar.current
    private var weekdays: [String] {
        [
            L10n.dayMondayShort.localized,
            L10n.dayTuesdayShort.localized,
            L10n.dayWednesdayShort.localized,
            L10n.dayThursdayShort.localized,
            L10n.dayFridayShort.localized,
            L10n.daySaturdayShort.localized,
            L10n.daySundayShort.localized
        ]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            patternGrid
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private var headerView: some View {
        HStack {
            Text(L10n.statsWeeklyPatternTitle.localized)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.adaptiveText)
            
            Spacer()
        }
    }
    
    private var patternGrid: some View {
        VStack(spacing: 16) {
            weekdayHeaders
            habitVisualization
        }
    }
    
    private var weekdayHeaders: some View {
        HStack {
            ForEach(weekdays.indices, id: \.self) { index in
                Text(weekdays[index])
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var habitVisualization: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(0..<7) { weekday in
                VStack(spacing: 6) {
                    ForEach(Array(habits.prefix(5).enumerated()), id: \.element.id) { index, habit in
                        patternCircle(habit: habit, weekday: weekday, index: index)
                    }
                }
            }
        }
    }
    
    private func patternCircle(habit: Habit, weekday: Int, index: Int) -> some View {
        let rate = completionRateForWeekday(habit: habit, weekday: weekday)
        return Circle()
            .fill(rate > 0.5 ? habit.color.color : Color.adaptiveText.opacity(0.2))
            .frame(width: 12, height: 12)
            .scaleEffect(rate)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(weekday) * 0.1 + Double(index) * 0.05), value: rate)
    }
    
    private func completionRateForWeekday(habit: Habit, weekday: Int) -> Double {
        let filteredCompletions = allCompletions.filter { completion in
            completion.habitId == habit.id
        }
        
        let weekdayCompletions = filteredCompletions.filter { completion in
            let weekdayComponent = calendar.component(.weekday, from: completion.date)
            let adjustedWeekday = weekdayComponent == 1 ? 6 : weekdayComponent - 2
            return adjustedWeekday == weekday
        }
        
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        var weekdayCount = 0
        var currentDate = startDate
        
        while currentDate <= endDate {
            let weekdayComponent = calendar.component(.weekday, from: currentDate)
            let adjustedWeekday = weekdayComponent == 1 ? 6 : weekdayComponent - 2
            if adjustedWeekday == weekday {
                weekdayCount += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return weekdayCount > 0 ? min(1.0, Double(weekdayCompletions.count) / Double(weekdayCount)) : 0
    }
}

// MARK: - Premium Streak Analysis
struct PremiumStreakAnalysis: View {
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    
    var topStreakHabits: [Habit] {
        habits.sorted { $0.currentStreak(allCompletions: allCompletions) > $1.currentStreak(allCompletions: allCompletions) }.prefix(4).map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text(L10n.statsStreakAnalysis.localized)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                
                Spacer()
            }
            
            // Streak cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(Array(topStreakHabits.enumerated()), id: \.element.id) { index, habit in
                    PremiumStreakCard(
                        habit: habit,
                        allCompletions: allCompletions,
                        animationDelay: Double(index) * 0.15
                    )
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Premium Streak Card
struct PremiumStreakCard: View {
    let habit: Habit
    let allCompletions: [HabitCompletion]
    let animationDelay: Double
    @State private var appear = false
    @State private var streakScale = 0.0
    
    var streak: Int {
        habit.currentStreak(allCompletions: allCompletions)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(habit.color.color.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .blur(radius: 8)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(habit.color.color.opacity(0.4), lineWidth: 1)
                    )
                
                Image(systemName: habit.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(habit.color.color)
            }
            
            // Streak number
            Text("\(streak)")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(habit.color.color)
                .scaleEffect(streakScale)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(animationDelay + 0.3), value: streakScale)
            
            // Habit name
            Text(habit.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.adaptiveText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Days label
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text(L10n.statsDays.localized)
                    .font(.caption)
                    .foregroundColor(.adaptiveText.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(habit.color.color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(appear ? 1.0 : 0.8)
        .opacity(appear ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(animationDelay), value: appear)
        .onAppear {
            appear = true
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(animationDelay + 0.2)) {
                streakScale = 1.0
            }
        }
    }
}

// MARK: - TimeFrame
enum TimeFrame: String, CaseIterable {
    case week = "week"
    case month = "month"
    case year = "year"
    
    var localizedName: String {
        switch self {
        case .week: return L10n.statsTimeframeWeek.localized
        case .month: return L10n.statsTimeframeMonth.localized
        case .year: return L10n.statsTimeframeYear.localized
        }
    }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

// MARK: - TimeFrame Picker View
struct TimeFramePickerView: View {
    @Binding var selectedTimeFrame: TimeFrame
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.3, blue: 0.7),
                        Color(red: 0.6, green: 0.2, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Button(action: {
                            selectedTimeFrame = timeFrame
                            dismiss()
                        }) {
            HStack {
                                Text(timeFrame.localizedName)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.adaptiveText)
                
                Spacer()
                                
                                if selectedTimeFrame == timeFrame {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.adaptiveText)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(24)
                .padding(.top, 40)
            }
            .navigationTitle("Time Frame")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.adaptiveText)
                }
            }
        }
    }
}

// MARK: - Premium Profile View
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query(sort: \HabitCompletion.date) private var allCompletions: [HabitCompletion]
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderTime") private var reminderTime = "09:00"
    @State private var showingDeleteAlert = false
    @State private var showingExportSheet = false
    
    var body: some View {
            ZStack {
            // Background is now handled by MainTabView
            Color.clear
                
                ScrollView {
                LazyVStack(spacing: 32) {
                    // Premium Profile Header
                    PremiumProfileHeader(
                        habitCount: habits.count,
                        todayCompleted: todayCompletedCount,
                        bestStreak: bestStreak
                    )
                        
                        // Quick Stats
                    PremiumProfileStats(
                        habits: habits,
                        allCompletions: allCompletions
                    )
                    .padding(.horizontal, 20)
                        
                        // Settings Sections
                    VStack(spacing: 20) {
                        PremiumSettingsSection(
                            title: L10n.profileAppearance.localized,
                            icon: "paintpalette.fill",
                            color: .purple
                        ) {
                            PremiumSettingsRow(
                                    title: L10n.profileDarkModeTitle.localized,
                                icon: "moon.fill"
                            ) {
                                        Toggle("", isOn: $isDarkMode)
                                    .toggleStyle(PremiumToggleStyle())
                            }
                        }
                        
                        PremiumSettingsSection(
                            title: L10n.profileNotifications.localized,
                                        icon: "bell.fill",
                            color: .blue
                        ) {
                            VStack(spacing: 16) {
                                PremiumSettingsRow(
                                    title: L10n.profileReminders.localized,
                                    icon: "bell.badge.fill"
                                ) {
                                            Toggle("", isOn: $notificationsEnabled)
                                        .toggleStyle(PremiumToggleStyle())
                                        }
                                    
                                    if notificationsEnabled {
                                    PremiumSettingsRow(
                                            title: L10n.profileReminderTime.localized,
                                        icon: "clock.fill"
                                    ) {
                                                Text(reminderTime)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.adaptiveText.opacity(0.8))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                        
                        PremiumSettingsSection(
                            title: L10n.profileDataManagementTitle.localized,
                            icon: "externaldrive.fill",
                            color: .orange
                        ) {
                            VStack(spacing: 16) {
                                PremiumActionRow(
                                        title: L10n.profileExportDataTitle.localized,
                                    icon: "square.and.arrow.up.fill",
                                    color: .green
                                ) {
                                                showingExportSheet = true
                                            }
                                    
                                PremiumActionRow(
                                        title: L10n.profileDeleteDataTitle.localized,
                                    icon: "trash.fill",
                                    color: .red
                                ) {
                                                showingDeleteAlert = true
                                            }
                            }
                        }
                        
                        PremiumSettingsSection(
                            title: L10n.profileAppInfo.localized,
                            icon: "info.circle.fill",
                            color: .teal
                        ) {
                            VStack(spacing: 16) {
                                PremiumSettingsRow(
                                        title: L10n.profileVersionTitle.localized,
                                    icon: "tag.fill"
                                ) {
                                            Text("1.0.0")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.adaptiveText.opacity(0.8))
                                        }
                                    
                                PremiumSettingsRow(
                                        title: L10n.profileMadeWithLove.localized,
                                    icon: "heart.fill"
                                ) {
                                            Text("SwiftUI")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.adaptiveText.opacity(0.8))
                                }
                            }
                        }
                        
                        // Developer Section (Hidden by default)
                        PremiumSettingsSection(
                            title: L10n.profileDeveloper.localized,
                            icon: "hammer.fill",
                            color: .pink
                        ) {
                            VStack(spacing: 16) {
                                PremiumActionRow(
                                    title: L10n.profileResetOnboarding.localized,
                                    icon: "arrow.clockwise.circle.fill",
                                    color: .pink
                                ) {
                                    resetOnboarding()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // Space for tab bar
                }
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        .alert(L10n.profileDeleteConfirmation.localized, isPresented: $showingDeleteAlert) {
            Button(L10n.profileCancel.localized, role: .cancel) { }
            Button(L10n.profileDelete.localized, role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text(L10n.profileDeleteWarning.localized)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(habits: habits)
        }
    }
    
    private var todayCompletedCount: Int {
        habits.filter { $0.isCompletedToday(allCompletions: allCompletions) }.count
    }
    
    private var bestStreak: Int {
        habits.map { $0.currentStreak(allCompletions: allCompletions) }.max() ?? 0
    }
    
    private func deleteAllData() {
        for habit in habits {
            modelContext.delete(habit)
        }
        try? modelContext.save()
    }
    
    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "onboarding_completed")
        // Force app restart to show onboarding
        exit(0)
    }
}

// MARK: - Premium Profile Header
struct PremiumProfileHeader: View {
    let habitCount: Int
    let todayCompleted: Int
    let bestStreak: Int
    @State private var headerScale = 0.8
    
    var body: some View {
        VStack(spacing: 24) {
            // Avatar with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.6),
                                Color.purple.opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.adaptiveText.opacity(0.3), lineWidth: 2)
                    )
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.adaptiveText)
            }
            
            // User info
            VStack(spacing: 8) {
                Text(L10n.profileAppName.localized)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.adaptiveText, .adaptiveText.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(String(format: L10n.profileActiveHabits.localized, habitCount))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.adaptiveText.opacity(0.8))
            }
            
            // Quick stats row
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(todayCompleted)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("Today")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.adaptiveText.opacity(0.7))
                }
                
                Rectangle()
                    .fill(Color.adaptiveText.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("\(bestStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("Best Streak")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.adaptiveText.opacity(0.7))
                }
                
                Rectangle()
                    .fill(Color.adaptiveText.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("\(habitCount)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Habits")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.adaptiveText.opacity(0.7))
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [Color.adaptiveText.opacity(0.3), Color.clear, Color.adaptiveText.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 30, x: 0, y: 15)
        .padding(.horizontal, 20)
        .scaleEffect(headerScale)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                headerScale = 1.0
            }
        }
    }
}

// MARK: - Premium Profile Stats
struct PremiumProfileStats: View {
    let habits: [Habit]
    let allCompletions: [HabitCompletion]
    
    var weekCompletedCount: Int {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        
        return habits.reduce(0) { sum, habit in
            sum + allCompletions.filter { completion in
                completion.habitId == habit.id &&
                completion.date >= startDate && completion.date <= endDate
            }.count
        }
    }
    
    var monthCompletedCount: Int {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        
        return habits.reduce(0) { sum, habit in
            sum + allCompletions.filter { completion in
                completion.habitId == habit.id &&
                completion.date >= startDate && completion.date <= endDate
            }.count
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text(L10n.profileQuickOverview.localized)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                
                Spacer()
            }
            
            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                PremiumStatCard(
                    title: L10n.profileThisWeek.localized,
                    value: "\(weekCompletedCount)",
                    icon: "calendar.circle.fill",
                    color: .blue,
                    delay: 0.1
                )
                
                PremiumStatCard(
                    title: "This Month",
                    value: "\(monthCompletedCount)",
                    icon: "calendar.badge.clock",
                    color: .purple,
                    delay: 0.2
                )
                
                PremiumStatCard(
                    title: "All Time",
                    value: "\(allCompletions.count)",
                    icon: "infinity.circle.fill",
                    color: .green,
                    delay: 0.3
                )
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Premium Settings Section
struct PremiumSettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                }
            
            Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                
                Spacer()
            }
            
            // Content
            content()
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.adaptiveText.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Premium Settings Row
struct PremiumSettingsRow<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
                Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.adaptiveText.opacity(0.7))
                .frame(width: 24)
                
                Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.adaptiveText)
                
                Spacer()
            
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Premium Action Row
struct PremiumActionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
            Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24)
            
            Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.adaptiveText)
            
            Spacer()
            
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.adaptiveText.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Premium Toggle Style
struct PremiumToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color.green : Color.adaptiveText.opacity(0.3))
                    .frame(width: 50, height: 30)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isOn)
                
                Circle()
                    .fill(.white)
                    .frame(width: 26, height: 26)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var habitName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "blue"
    @State private var selectedCategory = ""
    @State private var targetCount = 1
    @State private var selectedFrequency = HabitFrequency.daily
    @State private var showingError = false
    
    private let availableIcons = [
        "star.fill", "heart.fill", "leaf.fill", "flame.fill", "drop.fill",
        "figure.run", "dumbbell.fill", "book.fill", "pencil", "lightbulb.fill",
        "moon.fill", "sun.max.fill", "cup.and.saucer.fill", "pills.fill", "brain.head.profile"
    ]
    
    private let availableColors = [
        "blue", "green", "orange", "red", "purple", "pink", "yellow", "mint", "teal", "indigo"
    ]
    
    private let categories = [
        L10n.categoryFitness.localized,
        L10n.categoryHealth.localized,
        L10n.categoryWellness.localized,
        L10n.categoryEducation.localized,
        L10n.categoryCreativity.localized,
        L10n.categorySocial.localized,
        L10n.categoryProductivity.localized,
        L10n.categoryGeneral.localized
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.4),
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.3, green: 0.2, blue: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Premium Header
                        VStack(spacing: 16) {
                            HStack {
                                Button(L10n.addClose.localized) {
                                    dismiss()
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text(L10n.addTitle.localized)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(L10n.addCreate.localized) {
                                    createHabit()
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                                .disabled(habitName.isEmpty)
                                .opacity(habitName.isEmpty ? 0.5 : 1.0)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                        }
                        
                        // Preview Card
                        VStack(spacing: 20) {
                            Text(L10n.addPreview.localized)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                            
                            PremiumHabitPreview(
                                name: habitName.isEmpty ? L10n.addPreviewDefault.localized : habitName,
                                icon: selectedIcon,
                                color: selectedColor,
                                targetCount: targetCount
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Form Sections
                        VStack(spacing: 24) {
                            // Name Section
                            PremiumFormSection(title: L10n.addName.localized) {
                                TextField(L10n.addNamePlaceholder.localized, text: $habitName)
                                    .textFieldStyle(PremiumTextFieldStyle())
                            }
                            
                            // Icon Section
                            PremiumFormSection(title: L10n.addIcon.localized) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                    ForEach(availableIcons, id: \.self) { icon in
                                        PremiumIconSelector(
                                            icon: icon,
                                            isSelected: selectedIcon == icon,
                                            onTap: { selectedIcon = icon }
                                        )
                                    }
                                }
                            }
                            
                            // Color Section
                            PremiumFormSection(title: L10n.addColor.localized) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                    ForEach(availableColors, id: \.self) { color in
                                        PremiumColorSelector(
                                            color: color,
                                            isSelected: selectedColor == color,
                                            onTap: { selectedColor = color }
                                        )
                                    }
                                }
                            }
                            
                            // Category Section
                            PremiumFormSection(title: L10n.addCategory.localized) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        PremiumCategorySelector(
                                            category: category,
                                            isSelected: selectedCategory == category,
                                            onTap: { selectedCategory = category }
                                        )
                                    }
                                }
                            }
                            
                            // Target Count Section
                            PremiumFormSection(title: L10n.addTargetCount.localized) {
                                HStack {
                                    Text(L10n.addTargetDaily.localized)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                
                Spacer()
                                    
                                    HStack(spacing: 16) {
                                        Button {
                                            if targetCount > 1 {
                                                targetCount -= 1
                                            }
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .disabled(targetCount <= 1)
                                        
                                        Text("\(targetCount)")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(minWidth: 30)
                                        
                                        Button {
                                            if targetCount < 20 {
                                                targetCount += 1
                                            }
                                        } label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .disabled(targetCount >= 20)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            if selectedCategory.isEmpty {
                selectedCategory = categories.first ?? L10n.categoryGeneral.localized
            }
        }
        .alert(L10n.addNameRequired.localized, isPresented: $showingError) {
            Button("OK") { }
        }
    }
    
    private func createHabit() {
        guard !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showingError = true
            return
        }
        
        let habit = Habit(
            name: habitName.trimmingCharacters(in: .whitespacesAndNewlines),
            icon: selectedIcon,
            color: selectedColor,
            frequency: selectedFrequency,
            targetCount: targetCount,
            category: selectedCategory
        )
        
        modelContext.insert(habit)
        
        do {
            try modelContext.save()
            
            // Update widgets when new habit is created
            WidgetCenter.shared.reloadTimelines(ofKind: "HabitTrackerWidget")
            
            FeedbackGenerator.impact(.medium)
            dismiss()
        } catch {
            print("Error creating habit: \(error)")
        }
    }
}

// MARK: - Premium Components for Add Habit View
struct PremiumHabitPreview: View {
    let name: String
    let icon: String
    let color: String
    let targetCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.color.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .blur(radius: 12)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(color.color.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(L10n.addGoalDaily.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PremiumFormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            content
        }
    }
}

struct PremiumTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium, design: .rounded))
    }
}

struct PremiumIconSelector: View {
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .white.opacity(0.8))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PremiumColorSelector: View {
    let color: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PremiumCategorySelector: View {
    let category: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .blue : .white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.blue : Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
