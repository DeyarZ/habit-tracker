//
//  OnboardingView.swift
//  habittracker
//
//  Created by Assistant on 28.06.25.
//

import SwiftUI
import SwiftData
import StoreKit

// MARK: - Onboarding Binding Helper
class OnboardingBinding: ObservableObject {
    @Binding var showOnboarding: Bool
    
    init(showOnboarding: Binding<Bool>) {
        self._showOnboarding = showOnboarding
    }
}

// MARK: - Onboarding Manager
@Observable
class OnboardingManager {
    var currentStep: OnboardingStep = .welcome
    var selectedHabits: Set<HabitSuggestion> = []
    var isCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: "onboarding_completed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "onboarding_completed")
        }
    }
    
    func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .features
        case .features:
            currentStep = .rating
        case .rating:
            currentStep = .habits
        case .habits:
            currentStep = .complete
        case .complete:
            UserDefaults.standard.set(true, forKey: "onboarding_completed")
            isCompleted = true
        }
    }
    
    func skipToEnd() {
        currentStep = .complete
    }
}

enum OnboardingStep: CaseIterable {
    case welcome
    case features
    case rating
    case habits
    case complete
}

// MARK: - Habit Suggestions
struct HabitSuggestion: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let category: String
    let targetCount: Int
}

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var onboardingManager = OnboardingManager()
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            // Premium animated background
            OnboardingAnimatedBackground()
                .ignoresSafeArea()
            
            // Content with smooth transitions
            Group {
                switch onboardingManager.currentStep {
                case .welcome:
                    OnboardingWelcomeView()
                case .features:
                    OnboardingFeaturesView()
                case .rating:
                    OnboardingRatingView()
                case .habits:
                    OnboardingHabitsView()
                case .complete:
                    OnboardingCompleteView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.6), value: onboardingManager.currentStep)
        }
        .environment(onboardingManager)
        .environmentObject(OnboardingBinding(showOnboarding: $showOnboarding))
        .onChange(of: onboardingManager.isCompleted) { _, isCompleted in
            if isCompleted {
                DispatchQueue.main.async {
                    showOnboarding = false
                }
            }
        }
    }
}

// MARK: - Welcome Screen
struct OnboardingWelcomeView: View {
    @Environment(OnboardingManager.self) private var onboardingManager
    @State private var animateContent = false
    @State private var animateButton = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and Title Section
            VStack(spacing: 32) {
                // App Icon with glow effect
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .scaleEffect(animateContent ? 1.2 : 0.8)
                    
                    RoundedRectangle(cornerRadius: 28)
                        .fill(LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                        .rotationEffect(.degrees(animateContent ? 0 : -180))
                }
                .animation(.easeInOut(duration: 1.2).delay(0.3), value: animateContent)
                
                // Title and Subtitle
                VStack(spacing: 16) {
                    Text("Welcome to\nHabit Tracker")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveText)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.easeInOut(duration: 0.8).delay(0.6), value: animateContent)
                    
                    Text("Build better habits,\none day at a time.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeInOut(duration: 0.8).delay(0.9), value: animateContent)
                }
            }
            
            Spacer()
            
            // Get Started Button
            OnboardingPrimaryButton(
                title: "Get Started",
                isAnimated: animateButton
            ) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    onboardingManager.nextStep()
                }
            }
            .opacity(animateButton ? 1 : 0)
            .offset(y: animateButton ? 0 : 30)
            .animation(.easeInOut(duration: 0.8).delay(1.2), value: animateButton)
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation {
                animateContent = true
                animateButton = true
            }
        }
    }
}

// MARK: - Features Screen
struct OnboardingFeaturesView: View {
    @Environment(OnboardingManager.self) private var onboardingManager
    @State private var animateContent = false
    @State private var animateFeatures = [false, false, false]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Title Section
            VStack(spacing: 16) {
                Text("Everything you need\nto succeed")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                    .multilineTextAlignment(.center)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateContent)
                
                Text("Track your progress, build streaks,\nand achieve your goals.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: animateContent)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Features List
            VStack(spacing: 32) {
                OnboardingFeatureCard(
                    icon: "hand.tap.fill",
                    title: "Simple Tracking",
                    description: "One tap to mark habits complete. Clean interface, powerful features.",
                    color: .blue,
                    isAnimated: animateFeatures[0]
                )
                
                OnboardingFeatureCard(
                    icon: "flame.fill",
                    title: "Build Streaks",
                    description: "Stay motivated with visual streak counters and progress tracking.",
                    color: .orange,
                    isAnimated: animateFeatures[1]
                )
                
                OnboardingFeatureCard(
                    icon: "chart.bar.fill",
                    title: "Smart Insights",
                    description: "Detailed analytics help you understand your habits better.",
                    color: .purple,
                    isAnimated: animateFeatures[2]
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Continue Button
            OnboardingPrimaryButton(
                title: "Continue",
                isAnimated: animateContent
            ) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    onboardingManager.nextStep()
                }
            }
            .padding(.bottom, 60)
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation {
                animateContent = true
            }
            
            // Stagger feature animations
            for i in 0..<animateFeatures.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2 + 0.6) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        animateFeatures[i] = true
                    }
                }
            }
        }
    }
}

// MARK: - Rating Screen
struct OnboardingRatingView: View {
    @Environment(OnboardingManager.self) private var onboardingManager
    @State private var animateContent = false
    @State private var animateButton = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Rocket Animation
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .blur(radius: 15)
                        .scaleEffect(animateContent ? 1.1 : 0.8)
                    
                    Text("🚀")
                        .font(.system(size: 60))
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                        .rotationEffect(.degrees(animateContent ? 0 : -45))
                        .offset(y: animateContent ? 0 : 10)
                }
                .animation(.easeInOut(duration: 1.0).delay(0.3), value: animateContent)
                
                VStack(spacing: 16) {
                    Text("Help us grow! 🚀")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveText)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.easeInOut(duration: 0.8).delay(0.6), value: animateContent)
                    
                    Text("If you're excited about building better habits with us, we'd love your support!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeInOut(duration: 0.8).delay(0.9), value: animateContent)
                    
                    Text("A quick rating helps other people discover our app and motivates us to keep improving.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.adaptiveSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 15)
                        .animation(.easeInOut(duration: 0.8).delay(1.1), value: animateContent)
                }
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                OnboardingPrimaryButton(
                    title: "Rate App",
                    isAnimated: animateButton
                ) {
                    requestReview()
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onboardingManager.nextStep()
                    }
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onboardingManager.nextStep()
                    }
                } label: {
                    Text("Maybe Later")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                        .padding(.vertical, 8)
                }
                .opacity(animateButton ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(1.5), value: animateButton)
            }
            .padding(.bottom, 60)
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation {
                animateContent = true
                animateButton = true
            }
        }
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

// MARK: - Habits Selection Screen
struct OnboardingHabitsView: View {
    @Environment(OnboardingManager.self) private var onboardingManager
    @Environment(\.modelContext) private var modelContext
    @State private var animateContent = false
    @State private var animateHabits = false
    @State private var showingAddHabit = false
    
    private var habitSuggestions: [HabitSuggestion] {
        [
            HabitSuggestion(name: "Daily Workout", icon: "figure.run", color: "orange", category: "Fitness", targetCount: 1),
            HabitSuggestion(name: "Meditation", icon: "leaf", color: "green", category: "Wellness", targetCount: 1),
            HabitSuggestion(name: "Read 30 minutes", icon: "book", color: "blue", category: "Education", targetCount: 1),
            HabitSuggestion(name: "Drink 8 glasses of water", icon: "drop", color: "teal", category: "Health", targetCount: 8),
            HabitSuggestion(name: "Write in journal", icon: "square.and.pencil", color: "purple", category: "Wellness", targetCount: 1),
            HabitSuggestion(name: "Take a walk", icon: "figure.walk", color: "indigo", category: "Fitness", targetCount: 1)
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Section
            VStack(spacing: 16) {
                Text("Let's create your\nfirst habits")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptiveText)
                    .multilineTextAlignment(.center)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: animateContent)
                
                Text("Pick a few habits to get started.\nYou can always add more later!")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: animateContent)
            }
            .padding(.horizontal, 32)
            .padding(.top, 60)
            
            Spacer()
            
            // Habits Grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(habitSuggestions) { suggestion in
                        OnboardingHabitCard(
                            suggestion: suggestion,
                            isSelected: onboardingManager.selectedHabits.contains(suggestion),
                            isAnimated: animateHabits
                        ) {
                            toggleHabitSelection(suggestion)
                        }
                    }
                    
                    // Custom Habit Card
                    OnboardingCustomHabitCard(isAnimated: animateHabits) {
                        showingAddHabit = true
                    }
                }
                .padding(.horizontal, 32)
                .opacity(animateHabits ? 1 : 0)
                .offset(y: animateHabits ? 0 : 30)
                .animation(.easeInOut(duration: 0.8).delay(0.6), value: animateHabits)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                OnboardingPrimaryButton(
                    title: "Start My Journey",
                    isAnimated: animateContent
                ) {
                    createSelectedHabits()
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onboardingManager.nextStep()
                    }
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onboardingManager.nextStep()
                    }
                } label: {
                    Text("Skip for now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                        .padding(.vertical, 8)
                }
                .opacity(animateContent ? 0.7 : 0)
                .animation(.easeInOut(duration: 0.8).delay(1.0), value: animateContent)
            }
            .padding(.bottom, 60)
            .padding(.horizontal, 32)
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
        .onAppear {
            withAnimation {
                animateContent = true
                animateHabits = true
            }
        }
    }
    
    private func toggleHabitSelection(_ suggestion: HabitSuggestion) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if onboardingManager.selectedHabits.contains(suggestion) {
                onboardingManager.selectedHabits.remove(suggestion)
            } else {
                onboardingManager.selectedHabits.insert(suggestion)
            }
        }
        
        // Haptic feedback
        FeedbackGenerator.impact(.light)
    }
    
    private func createSelectedHabits() {
        for suggestion in onboardingManager.selectedHabits {
            let habit = Habit(
                name: suggestion.name,
                icon: suggestion.icon,
                color: suggestion.color,
                frequency: .daily,
                targetCount: suggestion.targetCount,
                category: suggestion.category
            )
            modelContext.insert(habit)
        }
        
        try? modelContext.save()
    }
}

// MARK: - Complete Screen
struct OnboardingCompleteView: View {
    @Environment(OnboardingManager.self) private var onboardingManager
    @EnvironmentObject private var onboardingBinding: OnboardingBinding
    @State private var animateContent = false
    @State private var animateConfetti = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Success Animation
            VStack(spacing: 32) {
                ZStack {
                    // Confetti background effect
                    ForEach(0..<20, id: \.self) { i in
                        Circle()
                            .fill(Color.random)
                            .frame(width: 8, height: 8)
                            .offset(
                                x: animateConfetti ? CGFloat.random(in: -100...100) : 0,
                                y: animateConfetti ? CGFloat.random(in: -100...100) : 0
                            )
                            .opacity(animateConfetti ? 0 : 1)
                            .animation(
                                .easeOut(duration: 2.0).delay(Double(i) * 0.1),
                                value: animateConfetti
                            )
                    }
                    
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(animateContent ? 1.0 : 0.3)
                        .animation(.easeInOut(duration: 1.0).delay(0.3), value: animateContent)
                }
                
                VStack(spacing: 16) {
                    Text("You're all set! 🎉")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveText)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.easeInOut(duration: 0.8).delay(0.6), value: animateContent)
                    
                    Text("Your habit journey starts now.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeInOut(duration: 0.8).delay(0.9), value: animateContent)
                }
            }
            
            Spacer()
            
            // Start Button
            OnboardingPrimaryButton(
                title: "Start Tracking",
                isAnimated: animateContent
            ) {
                // Direct approach to close onboarding
                UserDefaults.standard.set(true, forKey: "onboarding_completed")
                withAnimation(.easeInOut(duration: 0.5)) {
                    onboardingBinding.showOnboarding = false
                }
            }
            .padding(.bottom, 60)
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation {
                animateContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    animateConfetti = true
                }
            }
        }
    }
}

// MARK: - Supporting Views and Components

struct OnboardingAnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.1),
                Color.blue.opacity(0.1),
                Color.cyan.opacity(0.1),
                Color.mint.opacity(0.1)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct OnboardingPrimaryButton: View {
    let title: String
    let isAnimated: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(isAnimated ? 1.0 : 0.9)
        .animation(.easeInOut(duration: 0.8).delay(1.4), value: isAnimated)
    }
}

struct OnboardingFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isAnimated: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.adaptiveText)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.adaptiveSecondaryText)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .opacity(isAnimated ? 1 : 0)
        .offset(x: isAnimated ? 0 : -50)
        .scaleEffect(isAnimated ? 1.0 : 0.9)
    }
}

struct OnboardingHabitCard: View {
    let suggestion: HabitSuggestion
    let isSelected: Bool
    let isAnimated: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colorFromString(suggestion.color).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: suggestion.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(colorFromString(suggestion.color))
                }
                
                Text(suggestion.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.adaptiveText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.adaptiveCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? colorFromString(suggestion.color) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? colorFromString(suggestion.color).opacity(0.3) : Color.clear,
                radius: isSelected ? 10 : 0,
                x: 0,
                y: 5
            )
        }
        .opacity(isAnimated ? 1 : 0)
        .offset(y: isAnimated ? 0 : 30)
        .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "orange": return .orange
        case "green": return .green
        case "blue": return .blue
        case "teal": return .teal
        case "purple": return .purple
        case "indigo": return .indigo
        default: return .primary
        }
    }
}

struct OnboardingCustomHabitCard: View {
    let isAnimated: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Text("Add Custom Habit")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.adaptiveCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    )
            )
        }
        .opacity(isAnimated ? 1 : 0)
        .offset(y: isAnimated ? 0 : 30)
    }
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
        .modelContainer(for: [Habit.self, HabitCompletion.self])
} 