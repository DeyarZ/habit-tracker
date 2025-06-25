import Foundation
import SwiftUI

// MARK: - Localization Helper
struct LocalizedStringKey {
    let key: String
    
    var localized: String {
        NSLocalizedString(key, comment: "")
    }
}

// MARK: - Localization Keys
struct L10n {
    // Navigation
    static let navOverview = LocalizedStringKey(key: "nav.overview")
    static let navDaily = LocalizedStringKey(key: "nav.daily")
    static let navAdd = LocalizedStringKey(key: "nav.add")
    static let navStats = LocalizedStringKey(key: "nav.stats")
    static let navProfile = LocalizedStringKey(key: "nav.profile")
    
    // Onboarding
    static let onboardingWelcomeTitle = LocalizedStringKey(key: "onboarding.welcome.title")
    static let onboardingWelcomeSubtitle = LocalizedStringKey(key: "onboarding.welcome.subtitle")
    static let onboardingWelcomeGetStarted = LocalizedStringKey(key: "onboarding.welcome.getStarted")
    
    static let onboardingFeaturesTitle = LocalizedStringKey(key: "onboarding.features.title")
    static let onboardingFeaturesSubtitle = LocalizedStringKey(key: "onboarding.features.subtitle")
    static let onboardingFeaturesTrackingTitle = LocalizedStringKey(key: "onboarding.features.tracking.title")
    static let onboardingFeaturesTrackingDescription = LocalizedStringKey(key: "onboarding.features.tracking.description")
    static let onboardingFeaturesStreaksTitle = LocalizedStringKey(key: "onboarding.features.streaks.title")
    static let onboardingFeaturesStreaksDescription = LocalizedStringKey(key: "onboarding.features.streaks.description")
    static let onboardingFeaturesInsightsTitle = LocalizedStringKey(key: "onboarding.features.insights.title")
    static let onboardingFeaturesInsightsDescription = LocalizedStringKey(key: "onboarding.features.insights.description")
    static let onboardingFeaturesContinue = LocalizedStringKey(key: "onboarding.features.continue")
    
    static let onboardingRatingTitle = LocalizedStringKey(key: "onboarding.rating.title")
    static let onboardingRatingSubtitle = LocalizedStringKey(key: "onboarding.rating.subtitle")
    static let onboardingRatingDescription = LocalizedStringKey(key: "onboarding.rating.description")
    static let onboardingRatingRate = LocalizedStringKey(key: "onboarding.rating.rate")
    static let onboardingRatingLater = LocalizedStringKey(key: "onboarding.rating.later")
    
    static let onboardingHabitsTitle = LocalizedStringKey(key: "onboarding.habits.title")
    static let onboardingHabitsSubtitle = LocalizedStringKey(key: "onboarding.habits.subtitle")
    static let onboardingHabitsSuggestionWorkout = LocalizedStringKey(key: "onboarding.habits.suggestion.workout")
    static let onboardingHabitsSuggestionMeditation = LocalizedStringKey(key: "onboarding.habits.suggestion.meditation")
    static let onboardingHabitsSuggestionReading = LocalizedStringKey(key: "onboarding.habits.suggestion.reading")
    static let onboardingHabitsSuggestionWater = LocalizedStringKey(key: "onboarding.habits.suggestion.water")
    static let onboardingHabitsSuggestionJournal = LocalizedStringKey(key: "onboarding.habits.suggestion.journal")
    static let onboardingHabitsSuggestionWalk = LocalizedStringKey(key: "onboarding.habits.suggestion.walk")
    static let onboardingHabitsCustomHabit = LocalizedStringKey(key: "onboarding.habits.customHabit")
    static let onboardingHabitsFinish = LocalizedStringKey(key: "onboarding.habits.finish")
    static let onboardingHabitsSkip = LocalizedStringKey(key: "onboarding.habits.skip")
    
    static let onboardingCompleteTitle = LocalizedStringKey(key: "onboarding.complete.title")
    static let onboardingCompleteSubtitle = LocalizedStringKey(key: "onboarding.complete.subtitle")
    static let onboardingCompleteStart = LocalizedStringKey(key: "onboarding.complete.start")
    
    // Daily View
    static let dailyTitle = LocalizedStringKey(key: "daily.title")
    static let dailyProgress = LocalizedStringKey(key: "daily.progress")
    static let dailyStreak = LocalizedStringKey(key: "daily.streak")
    static let dailyCompletions = LocalizedStringKey(key: "daily.completions")
    
    // Calendar View
    static let calendarTitle = LocalizedStringKey(key: "calendar.title")
    static let calendarToday = LocalizedStringKey(key: "calendar.today")
    static let calendarSelectedDay = LocalizedStringKey(key: "calendar.selectedDay")
    static let calendarNoHabits = LocalizedStringKey(key: "calendar.noHabits")
    static let calendarCompleted = LocalizedStringKey(key: "calendar.completed")
    static let calendarNotCompleted = LocalizedStringKey(key: "calendar.notCompleted")
    
    // Add Habit View
    static let addTitle = LocalizedStringKey(key: "add.title")
    static let addName = LocalizedStringKey(key: "add.name")
    static let addNamePlaceholder = LocalizedStringKey(key: "add.namePlaceholder")
    static let addIcon = LocalizedStringKey(key: "add.icon")
    static let addColor = LocalizedStringKey(key: "add.color")
    static let addCategory = LocalizedStringKey(key: "add.category")
    static let addTargetCount = LocalizedStringKey(key: "add.targetCount")
    static let addFrequency = LocalizedStringKey(key: "add.frequency")
    static let addPreview = LocalizedStringKey(key: "add.preview")
    static let addPreviewDefault = LocalizedStringKey(key: "add.previewDefault")
    static let addCreate = LocalizedStringKey(key: "add.create")
    static let addNameRequired = LocalizedStringKey(key: "add.nameRequired")
    static let addTargetDaily = LocalizedStringKey(key: "add.targetDaily")
    static let addGoalDaily = LocalizedStringKey(key: "add.goalDaily")
    static let addClose = LocalizedStringKey(key: "add.close")
    
    // Categories
    static let categoryFitness = LocalizedStringKey(key: "category.fitness")
    static let categoryHealth = LocalizedStringKey(key: "category.health")
    static let categoryWellness = LocalizedStringKey(key: "category.wellness")
    static let categoryEducation = LocalizedStringKey(key: "category.education")
    static let categoryCreativity = LocalizedStringKey(key: "category.creativity")
    static let categorySocial = LocalizedStringKey(key: "category.social")
    static let categoryProductivity = LocalizedStringKey(key: "category.productivity")
    static let categoryGeneral = LocalizedStringKey(key: "category.general")
    
    // Frequencies
    static let frequencyDaily = LocalizedStringKey(key: "frequency.daily")
    static let frequencyWeekly = LocalizedStringKey(key: "frequency.weekly")
    static let frequencyCustom = LocalizedStringKey(key: "frequency.custom")
    
    // Stats View
    static let statsTitle = LocalizedStringKey(key: "stats.title")
    static let statsTimeframeWeek = LocalizedStringKey(key: "stats.timeframe.week")
    static let statsTimeframeMonth = LocalizedStringKey(key: "stats.timeframe.month")
    static let statsTimeframeYear = LocalizedStringKey(key: "stats.timeframe.year")
    static let statsOverview = LocalizedStringKey(key: "stats.overview")
    static let statsTotalHabits = LocalizedStringKey(key: "stats.totalHabits")
    static let statsTodayCompleted = LocalizedStringKey(key: "stats.todayCompleted")
    static let statsAverageCompletion = LocalizedStringKey(key: "stats.averageCompletion")
    static let statsBestStreak = LocalizedStringKey(key: "stats.bestStreak")
    static let statsHabitPerformance = LocalizedStringKey(key: "stats.habitPerformance")
    static let statsTopStreaks = LocalizedStringKey(key: "stats.topStreaks")
    static let statsWeeklyPattern = LocalizedStringKey(key: "stats.weeklyPattern")
    static let statsNoData = LocalizedStringKey(key: "stats.noData")
    static let statsStreakAnalysis = LocalizedStringKey(key: "stats.streakAnalysis")
    static let statsDays = LocalizedStringKey(key: "stats.days")
    static let statsWeeklyPatternTitle = LocalizedStringKey(key: "stats.weeklyPatternTitle")
    static let statsDescription = LocalizedStringKey(key: "stats.description")
    static let statsSuccessRate = LocalizedStringKey(key: "stats.successRate")
    
    // Profile View
    static let profileTitle = LocalizedStringKey(key: "profile.title")
    static let profileSettings = LocalizedStringKey(key: "profile.settings")
    static let profileDarkMode = LocalizedStringKey(key: "profile.darkMode")
    static let profileDataManagement = LocalizedStringKey(key: "profile.dataManagement")
    static let profileExportData = LocalizedStringKey(key: "profile.exportData")
    static let profileDeleteAllData = LocalizedStringKey(key: "profile.deleteAllData")
    static let profileAbout = LocalizedStringKey(key: "profile.about")
    static let profileVersion = LocalizedStringKey(key: "profile.version")
    static let profileHabitCount = LocalizedStringKey(key: "profile.habitCount")
    static let profileExportTitle = LocalizedStringKey(key: "profile.exportTitle")
    static let profileExportDescription = LocalizedStringKey(key: "profile.exportDescription")
    static let profileCopyToClipboard = LocalizedStringKey(key: "profile.copyToClipboard")
    static let profileCopied = LocalizedStringKey(key: "profile.copied")
    static let profileDeleteConfirmation = LocalizedStringKey(key: "profile.deleteConfirmation")
    static let profileDeleteWarning = LocalizedStringKey(key: "profile.deleteWarning")
    static let profileDelete = LocalizedStringKey(key: "profile.delete")
    static let profileCancel = LocalizedStringKey(key: "profile.cancel")
    static let profileAppName = LocalizedStringKey(key: "profile.appName")
    static let profileAppearance = LocalizedStringKey(key: "profile.appearance")
    static let profileDarkModeTitle = LocalizedStringKey(key: "profile.darkModeTitle")
    static let profileNotifications = LocalizedStringKey(key: "profile.notifications")
    static let profileReminders = LocalizedStringKey(key: "profile.reminders")
    static let profileReminderTime = LocalizedStringKey(key: "profile.reminderTime")
    static let profileDataManagementTitle = LocalizedStringKey(key: "profile.dataManagementTitle")
    static let profileExportDataTitle = LocalizedStringKey(key: "profile.exportDataTitle")
    static let profileExportButton = LocalizedStringKey(key: "profile.exportButton")
    static let profileDeleteDataTitle = LocalizedStringKey(key: "profile.deleteDataTitle")
    static let profileDeleteButton = LocalizedStringKey(key: "profile.deleteButton")
    static let profileAppInfo = LocalizedStringKey(key: "profile.appInfo")
    static let profileVersionTitle = LocalizedStringKey(key: "profile.versionTitle")
    static let profileMadeWithLove = LocalizedStringKey(key: "profile.madeWithLove")
    static let profileQuickOverview = LocalizedStringKey(key: "profile.quickOverview")
    static let profileThisWeek = LocalizedStringKey(key: "profile.thisWeek")
    static let profileStreak = LocalizedStringKey(key: "profile.streak")
    static let profileActiveHabits = LocalizedStringKey(key: "profile.activeHabits")
    static let profileResetOnboarding = LocalizedStringKey(key: "profile.resetOnboarding")
    static let profileDeveloper = LocalizedStringKey(key: "profile.developer")
    
    // Days of Week
    static let dayMonday = LocalizedStringKey(key: "day.monday")
    static let dayTuesday = LocalizedStringKey(key: "day.tuesday")
    static let dayWednesday = LocalizedStringKey(key: "day.wednesday")
    static let dayThursday = LocalizedStringKey(key: "day.thursday")
    static let dayFriday = LocalizedStringKey(key: "day.friday")
    static let daySaturday = LocalizedStringKey(key: "day.saturday")
    static let daySunday = LocalizedStringKey(key: "day.sunday")
    
    // Days of Week Short
    static let dayMondayShort = LocalizedStringKey(key: "day.monday.short")
    static let dayTuesdayShort = LocalizedStringKey(key: "day.tuesday.short")
    static let dayWednesdayShort = LocalizedStringKey(key: "day.wednesday.short")
    static let dayThursdayShort = LocalizedStringKey(key: "day.thursday.short")
    static let dayFridayShort = LocalizedStringKey(key: "day.friday.short")
    static let daySaturdayShort = LocalizedStringKey(key: "day.saturday.short")
    static let daySundayShort = LocalizedStringKey(key: "day.sunday.short")
    
    // Common
    static let commonDone = LocalizedStringKey(key: "common.done")
    static let commonSave = LocalizedStringKey(key: "common.save")
    static let commonCancel = LocalizedStringKey(key: "common.cancel")
    static let commonDelete = LocalizedStringKey(key: "common.delete")
    static let commonEdit = LocalizedStringKey(key: "common.edit")
    static let commonAdd = LocalizedStringKey(key: "common.add")
    static let commonClose = LocalizedStringKey(key: "common.close")
}

// MARK: - String Extensions for Localization
extension String {
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Platform-specific Feedback
struct FeedbackGenerator {
    static func impact(_ style: ImpactStyle = .medium) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style.uiStyle)
        generator.impactOccurred()
        #endif
    }
    
    enum ImpactStyle {
        case light, medium, heavy
        
        #if os(iOS)
        var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            }
        }
        #endif
    }
}

// MARK: - Platform-specific Clipboard
struct ClipboardManager {
    static func copy(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
} 