import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Local Models for Widget (to avoid L10n dependencies)
enum WidgetHabitFrequency: String, CaseIterable, Codable {
    case daily = "Täglich"
    case weekly = "Wöchentlich"  
    case custom = "Benutzerdefiniert"
}

// MARK: - Habit Toggle Intent
struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Habit"
    static var description = IntentDescription("Toggle a habit completion status.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Habit ID")
    var habitID: String
    
    init() {
        self.habitID = ""
    }
    
    init(habitID: String) {
        self.habitID = habitID
    }
    
    func perform() async throws -> some IntentResult {
        // Get the shared model container with the correct configuration
        let configuration = ModelConfiguration(
            schema: Schema([Habit.self, HabitCompletion.self]),
            url: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.habittracker.shared")?.appendingPathComponent("HabitTracker.sqlite") ?? URL.documentsDirectory.appendingPathComponent("HabitTracker.sqlite"),
            cloudKitDatabase: .automatic
        )
        let modelContainer = try ModelContainer(for: Schema([Habit.self, HabitCompletion.self]), configurations: configuration)
        let context = ModelContext(modelContainer)
        
        // Find the habit by UUID
        guard let habitUUID = UUID(uuidString: habitID) else {
            print("Invalid habit ID: \(habitID)")
            return .result()
        }
        
        let habitDescriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { habit in
                habit.id == habitUUID
            }
        )
        
        guard let habit = try context.fetch(habitDescriptor).first else {
            print("Habit not found: \(habitID)")
            return .result()
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // Get completions for this habit today
        let completionDescriptor = FetchDescriptor<HabitCompletion>(
            predicate: #Predicate<HabitCompletion> { completion in
                completion.habitId == habitUUID
            }
        )
        
        let allCompletions = try context.fetch(completionDescriptor)
        let todayCompletions = allCompletions.filter { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: today)
        }
        
        if todayCompletions.count >= habit.targetCount {
            // Remove one completion
            if let lastCompletion = todayCompletions.last {
                context.delete(lastCompletion)
                print("Removed completion for habit: \(habit.name)")
            }
        } else {
            // Add completion
            let completion = HabitCompletion(habitId: habit.id, date: today)
            context.insert(completion)
            print("Added completion for habit: \(habit.name)")
        }
        
        try context.save()
        
        // Force widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitTrackerWidget")
        
        return .result()
    }
}

// MARK: - Widget Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habits: getSampleHabits())
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let entry = HabitEntry(date: Date(), habits: getSampleHabits())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let habits = loadHabits()
        let entry = HabitEntry(date: Date(), habits: habits)
        
        // Update more frequently for better responsiveness
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadHabits() -> [WidgetHabit] {
        do {
            let configuration = ModelConfiguration(
                schema: Schema([Habit.self, HabitCompletion.self]),
                url: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.habittracker.shared")?.appendingPathComponent("HabitTracker.sqlite") ?? URL.documentsDirectory.appendingPathComponent("HabitTracker.sqlite"),
                cloudKitDatabase: .automatic
            )
            let modelContainer = try ModelContainer(for: Schema([Habit.self, HabitCompletion.self]), configurations: configuration)
            let context = ModelContext(modelContainer)
            
            let descriptor = FetchDescriptor<Habit>(
                sortBy: [SortDescriptor(\.createdAt, order: .forward)]
            )
            
            let habits = try context.fetch(descriptor)
            
            // Get all completions once to avoid multiple fetches
            let allCompletionsDescriptor = FetchDescriptor<HabitCompletion>()
            let allCompletions = (try? context.fetch(allCompletionsDescriptor)) ?? []
            
            let today = Calendar.current.startOfDay(for: Date())
            
            return habits.prefix(6).map { habit in
                let habitCompletions = allCompletions.filter { $0.habitId == habit.id }
                let todayCompletions = habitCompletions.filter { completion in
                    Calendar.current.isDate(completion.date, inSameDayAs: today)
                }
                
                return WidgetHabit(
                    id: habit.id.uuidString,
                    name: habit.name,
                    icon: habit.icon,
                    color: habit.color,
                    targetCount: habit.targetCount,
                    completedCount: todayCompletions.count,
                    isCompleted: todayCompletions.count >= habit.targetCount,
                    allCompletions: habitCompletions
                )
            }
        } catch {
            print("Error loading habits: \(error)")
            return getSampleHabits()
        }
    }
    
    private func getSampleHabits() -> [WidgetHabit] {
        return [
            WidgetHabit(id: "1", name: "Workout", icon: "figure.run", color: "orange", targetCount: 1, completedCount: 1, isCompleted: true),
            WidgetHabit(id: "2", name: "Meditation", icon: "leaf", color: "green", targetCount: 1, completedCount: 0, isCompleted: false),
            WidgetHabit(id: "3", name: "Reading", icon: "book", color: "blue", targetCount: 1, completedCount: 0, isCompleted: false),
            WidgetHabit(id: "4", name: "Water", icon: "drop", color: "teal", targetCount: 8, completedCount: 3, isCompleted: false)
        ]
    }
}

// MARK: - Widget Data Models
struct HabitEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabit]
}

struct WidgetHabit {
    let id: String
    let name: String
    let icon: String
    let color: String
    let targetCount: Int
    let completedCount: Int
    let isCompleted: Bool
    let allCompletions: [HabitCompletion]
    
    init(id: String, name: String, icon: String, color: String, targetCount: Int, completedCount: Int, isCompleted: Bool, allCompletions: [HabitCompletion] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.targetCount = targetCount
        self.completedCount = completedCount
        self.isCompleted = isCompleted
        self.allCompletions = allCompletions
    }
    
    var progress: Double {
        return min(Double(completedCount) / Double(targetCount), 1.0)
    }
    
    func isCompletedOnDate(_ date: Date) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        let completionsForDay = allCompletions.filter { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: dayStart)
        }
        return completionsForDay.count >= targetCount
    }
    
    func completionsForDate(_ date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        return allCompletions.filter { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: dayStart)
        }.count
    }
}

// MARK: - Widget Views
struct HabitTrackerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(habits: Array(entry.habits.prefix(2)).map { habit in
                let today = Date()
                let todayCompletions = habit.completionsForDate(today)
                return WidgetHabit(
                    id: habit.id,
                    name: habit.name,
                    icon: habit.icon,
                    color: habit.color,
                    targetCount: habit.targetCount,
                    completedCount: todayCompletions,
                    isCompleted: todayCompletions >= habit.targetCount,
                    allCompletions: habit.allCompletions
                )
            })
        case .systemMedium:
            WeeklyMatrixWidgetView(habits: Array(entry.habits.prefix(4)))
        case .systemLarge:
            LargeWidgetView(habits: Array(entry.habits.prefix(6)).map { habit in
                let today = Date()
                let todayCompletions = habit.completionsForDate(today)
                return WidgetHabit(
                    id: habit.id,
                    name: habit.name,
                    icon: habit.icon,
                    color: habit.color,
                    targetCount: habit.targetCount,
                    completedCount: todayCompletions,
                    isCompleted: todayCompletions >= habit.targetCount,
                    allCompletions: habit.allCompletions
                )
            })
        default:
            SmallWidgetView(habits: Array(entry.habits.prefix(2)))
        }
    }
}

// MARK: - Small Widget (2 Habits)
struct SmallWidgetView: View {
    let habits: [WidgetHabit]
    
    var body: some View {
        // Remove ZStack and use ContainerRelativeShape
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.4, blue: 1.0),
                Color(red: 0.6, green: 0.2, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            VStack(spacing: 8) {
                // Title with progress
                HStack {
                    Text("Habits")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    let completed = habits.filter(\.isCompleted).count
                    Text("\(completed)/\(habits.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2), in: Capsule())
                }
                
                // Habits
                VStack(spacing: 6) {
                    ForEach(habits, id: \.id) { habit in
                        SmallHabitRow(habit: habit)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(12)
        )
        .clipShape(ContainerRelativeShape())
    }
}

struct SmallHabitRow: View {
    let habit: WidgetHabit
    
    var body: some View {
        Button(intent: ToggleHabitIntent(habitID: habit.id)) {
            HStack(spacing: 10) {
                // Icon with better visibility
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Name with better spacing
                Text(habit.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                // Progress and checkmark
                HStack(spacing: 6) {
                    if habit.targetCount > 1 {
                        Text("\(habit.completedCount)/\(habit.targetCount)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(habit.isCompleted ? .green : .white.opacity(0.6))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.white.opacity(habit.isCompleted ? 0.2 : 0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Weekly Matrix Widget (Medium Size)
struct WeeklyMatrixWidgetView: View {
    let habits: [WidgetHabit]
    
    private let weekDays = ["M", "T", "W", "T", "F", "S", "S"]
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2 // Monday = 0
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset - daysFromMonday, to: today)
        }
    }
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.4, blue: 1.0),
                Color(red: 0.6, green: 0.2, blue: 1.0),
                Color(red: 1.0, green: 0.3, blue: 0.7)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            VStack(spacing: 8) {
                // Header
                HStack {
                    Text("Weekly Matrix")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("This Week")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Days header
                HStack(spacing: 0) {
                    // Empty space for habit names
                    Text("")
                        .frame(width: 60)
                    
                    ForEach(0..<7, id: \.self) { dayIndex in
                        VStack(spacing: 2) {
                            Text(weekDays[dayIndex])
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(Calendar.current.component(.day, from: weekDates[dayIndex]))")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Matrix
                VStack(spacing: 4) {
                    ForEach(habits, id: \.id) { habit in
                        HabitWeekRow(habit: habit, weekDates: weekDates)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(10)
        )
        .clipShape(ContainerRelativeShape())
    }
}

struct HabitWeekRow: View {
    let habit: WidgetHabit
    let weekDates: [Date]
    
    var body: some View {
        HStack(spacing: 0) {
            // Habit name and icon
            HStack(spacing: 4) {
                Image(systemName: habit.icon)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(habit.color.widgetColor)
                    .frame(width: 12, height: 12)
                
                Text(habit.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(width: 60, alignment: .leading)
            
            // Week dots
            ForEach(0..<7, id: \.self) { dayIndex in
                let date = weekDates[dayIndex]
                let isCompleted = habit.isCompletedOnDate(date)
                let isToday = Calendar.current.isDateInToday(date)
                
                if isToday {
                    // Interactive only for today
                    Button(intent: ToggleHabitIntent(habitID: habit.id)) {
                        Circle()
                            .fill(isCompleted ? .green : .white.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 1.5)
                            )
                            .scaleEffect(isCompleted ? 1.1 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                } else {
                    // Non-interactive for past days
                    Circle()
                        .fill(isCompleted ? .green : .white.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .scaleEffect(isCompleted ? 1.1 : 1.0)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct MediumHabitCard: View {
    let habit: WidgetHabit
    
    var body: some View {
        Button(intent: ToggleHabitIntent(habitID: habit.id)) {
            VStack(spacing: 8) {
                // Icon with progress ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: habit.progress)
                        .stroke(habit.color.widgetColor, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(habit.isCompleted ? .green : habit.color.widgetColor)
                }
                
                // Name
                Text(habit.name)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Progress text
                Text("\(habit.completedCount)/\(habit.targetCount)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(habit.isCompleted ? 0.15 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Large Widget (6 Habits)
struct LargeWidgetView: View {
    let habits: [WidgetHabit]
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.2, green: 0.4, blue: 1.0),
                Color(red: 0.6, green: 0.2, blue: 1.0),
                Color(red: 1.0, green: 0.3, blue: 0.7),
                Color(red: 0.2, green: 0.8, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            VStack(spacing: 8) {
                // Header with stats
                VStack(spacing: 6) {
                    HStack {
                        Text("Today's Habits")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(DateFormatter.englishDayFormatter.string(from: Date()))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Progress bar
                    let completedCount = habits.filter(\.isCompleted).count
                    HStack {
                        Text("Progress:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        ProgressView(value: Double(completedCount) / Double(max(habits.count, 1)))
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .scaleEffect(y: 1.2)
                        
                        Text("\(completedCount)/\(habits.count)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Habits list with ScrollView for overflow protection
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(habits, id: \.id) { habit in
                            LargeHabitRow(habit: habit)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        )
        .clipShape(ContainerRelativeShape())
    }
}

struct LargeHabitRow: View {
    let habit: WidgetHabit
    
    var body: some View {
        Button(intent: ToggleHabitIntent(habitID: habit.id)) {
            HStack(spacing: 12) {
                // Icon with progress
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 36, height: 36)
                    
                    Circle()
                        .trim(from: 0, to: habit.progress)
                        .stroke(habit.color.widgetColor, lineWidth: 2)
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(habit.isCompleted ? .green : habit.color.widgetColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text("\(habit.completedCount)/\(habit.targetCount)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        if habit.targetCount > 1 {
                            ProgressView(value: habit.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: habit.color.widgetColor))
                                .scaleEffect(y: 0.6)
                        }
                    }
                }
                
                Spacer()
                
                // Status indicator
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(habit.isCompleted ? .green : .white.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(habit.isCompleted ? 0.15 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Color Extension for Widgets
extension String {
    var widgetColor: Color {
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

// MARK: - Date Formatters
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    
    static let englishDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, MMM dd"
        return formatter
    }()
}

// MARK: - Widget Configuration
struct HabitTrackerWidget: Widget {
    let kind: String = "HabitTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habits directly from the home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled() // This removes the white border!
    }
}

// MARK: - Widget Bundle
@main
struct HabitTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitTrackerWidget()
    }
}

#Preview(as: .systemSmall) {
    HabitTrackerWidget()
} timeline: {
    HabitEntry(date: .now, habits: [
        WidgetHabit(id: "1", name: "Sport", icon: "figure.run", color: "orange", targetCount: 1, completedCount: 1, isCompleted: true),
        WidgetHabit(id: "2", name: "Meditation", icon: "leaf", color: "green", targetCount: 1, completedCount: 0, isCompleted: false)
    ])
}

#Preview(as: .systemMedium) {
    HabitTrackerWidget()
} timeline: {
    HabitEntry(date: .now, habits: [
        WidgetHabit(id: "1", name: "Sport", icon: "figure.run", color: "orange", targetCount: 1, completedCount: 1, isCompleted: true),
        WidgetHabit(id: "2", name: "Meditation", icon: "leaf", color: "green", targetCount: 1, completedCount: 0, isCompleted: false),
        WidgetHabit(id: "3", name: "Lesen", icon: "book", color: "blue", targetCount: 1, completedCount: 0, isCompleted: false),
        WidgetHabit(id: "4", name: "Wasser", icon: "drop", color: "teal", targetCount: 8, completedCount: 3, isCompleted: false)
    ])
}

#Preview(as: .systemLarge) {
    HabitTrackerWidget()
} timeline: {
    HabitEntry(date: .now, habits: [
        WidgetHabit(id: "1", name: "Sport", icon: "figure.run", color: "orange", targetCount: 1, completedCount: 1, isCompleted: true),
        WidgetHabit(id: "2", name: "Meditation", icon: "leaf", color: "green", targetCount: 1, completedCount: 0, isCompleted: false),
        WidgetHabit(id: "3", name: "Lesen", icon: "book", color: "blue", targetCount: 1, completedCount: 0, isCompleted: false),
        WidgetHabit(id: "4", name: "Wasser", icon: "drop", color: "teal", targetCount: 8, completedCount: 3, isCompleted: false),
        WidgetHabit(id: "5", name: "Vitamine", icon: "pills", color: "red", targetCount: 1, completedCount: 1, isCompleted: true),
        WidgetHabit(id: "6", name: "Spazieren", icon: "figure.walk", color: "mint", targetCount: 1, completedCount: 0, isCompleted: false)
    ])
}
 