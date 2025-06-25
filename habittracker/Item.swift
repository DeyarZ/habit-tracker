//
//  Models.swift
//  habittracker
//
//  Created by Deyar Zakir on 24.06.25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var frequency: HabitFrequency
    var targetCount: Int
    var createdAt: Date
    var isActive: Bool
    var category: String
    
    init(name: String, icon: String, color: String, frequency: HabitFrequency = .daily, targetCount: Int = 1, category: String = "General") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.frequency = frequency
        self.targetCount = targetCount
        self.createdAt = Date()
        self.isActive = true
        self.category = category
    }
}

@Model
final class HabitCompletion {
    var id: UUID
    var habitId: UUID
    var date: Date
    
    init(habitId: UUID, date: Date = Date()) {
        self.id = UUID()
        self.habitId = habitId
        self.date = date
    }
}

enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "Täglich"  // Keep original German values for backward compatibility
    case weekly = "Wöchentlich"
    case custom = "Benutzerdefiniert"
    
    var systemImage: String {
        switch self {
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .custom: return "gear"
        }
    }
    
    var localizedName: String {
        switch self {
        case .daily: return L10n.frequencyDaily.localized
        case .weekly: return L10n.frequencyWeekly.localized
        case .custom: return L10n.frequencyCustom.localized
        }
    }
}

// MARK: - Habit Helper Extension
extension Habit {
    func isCompletedToday(allCompletions: [HabitCompletion]) -> Bool {
        return completionsForToday(allCompletions: allCompletions) >= targetCount
    }
    
    func completionsForToday(allCompletions: [HabitCompletion]) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return allCompletions.filter { completion in
            completion.habitId == self.id && 
            Calendar.current.isDate(completion.date, inSameDayAs: today)
        }.count
    }
    
    func isCompletedOnDate(_ date: Date, allCompletions: [HabitCompletion]) -> Bool {
        return completionsForDate(date, allCompletions: allCompletions) >= targetCount
    }
    
    func completionsForDate(_ date: Date, allCompletions: [HabitCompletion]) -> Int {
        let targetDay = Calendar.current.startOfDay(for: date)
        return allCompletions.filter { completion in
            completion.habitId == self.id && 
            Calendar.current.isDate(completion.date, inSameDayAs: targetDay)
        }.count
    }
    
    func currentStreak(allCompletions: [HabitCompletion]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayCompletions = allCompletions.filter { completion in
                completion.habitId == self.id && 
                calendar.isDate(completion.date, inSameDayAs: dayStart)
            }
            
            if dayCompletions.count >= targetCount {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Color Extensions
extension String {
    var color: Color {
        switch self {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        case "mint": return .mint
        case "teal": return .teal
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
