import Foundation
import CoreData
import SwiftUI

class DataManager: ObservableObject {
    let container: NSPersistentContainer

    // Published stats for UI binding
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalSessions: Int = 0
    @Published var totalMinutes: Double = 0
    @Published var currentXP: Int = 0
    @Published var currentLevel: Int = 0
    @Published var lastSessionDate: Date? = nil
    @Published var unlockedAchievementIDs: Set<String> = []

    // Transient state for post-session display
    @Published var lastSessionXP: Int = 0
    @Published var newlyUnlockedAchievements: [AchievementDefinition] = []
    @Published var didLevelUp: Bool = false
    @Published var newLevelName: String = ""
    @Published var isPersonalBest: Bool = false
    @Published var todayProtocolCompleted: Bool = false

    init(container: NSPersistentContainer) {
        self.container = container
        loadStats()
        loadAchievements()
        refreshStreak()
    }

    private var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Load persisted data

    func loadStats() {
        let stats = fetchOrCreateUserStats()
        currentStreak = Int(stats.currentStreak)
        longestStreak = Int(stats.longestStreak)
        totalSessions = Int(stats.totalSessions)
        totalMinutes = stats.totalMinutes
        currentXP = Int(stats.currentXP)
        currentLevel = Int(stats.currentLevel)
        lastSessionDate = stats.lastSessionDate
    }

    func loadAchievements() {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        do {
            let achievements = try viewContext.fetch(request)
            unlockedAchievementIDs = Set(achievements.compactMap { $0.id })
        } catch {
            print("Error loading achievements: \(error)")
        }
    }

    // MARK: - UserStats CRUD

    private func fetchOrCreateUserStats() -> UserStats {
        let request: NSFetchRequest<UserStats> = UserStats.fetchRequest()
        request.fetchLimit = 1
        do {
            if let existing = try viewContext.fetch(request).first {
                return existing
            }
        } catch {
            print("Error fetching UserStats: \(error)")
        }
        let stats = UserStats(context: viewContext)
        stats.currentStreak = 0
        stats.longestStreak = 0
        stats.totalSessions = 0
        stats.totalMinutes = 0
        stats.currentXP = 0
        stats.currentLevel = 0
        stats.lastSessionDate = nil
        saveContext()
        return stats
    }

    // MARK: - Today's protocol completion

    func refreshTodayProtocolStatus(for tier: BOLTTier) {
        let exercise = TrainingPlanProvider.todaysExercise(for: tier)
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        let request: NSFetchRequest<BreathingSession> = BreathingSession.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@ AND exerciseType == %@",
            start as NSDate, end as NSDate, exercise.exerciseType.rawValue
        )
        request.fetchLimit = 1

        do {
            let count = try viewContext.count(for: request)
            todayProtocolCompleted = count > 0
        } catch {
            print("Error checking today's protocol: \(error)")
            todayProtocolCompleted = false
        }
    }

    // MARK: - Save a breathing session

    func saveSession(exerciseType: String, durationSeconds: Int, cyclesCompleted: Int) {
        // Reset transient state
        newlyUnlockedAchievements = []
        didLevelUp = false
        isPersonalBest = false

        let previousLevel = currentLevel

        // Calculate XP
        let minutes = Double(durationSeconds) / 60.0
        var xp = max(Int(minutes * Double(GamificationConstants.xpPerMinute)), GamificationConstants.minimumSessionXP)

        // Create session record
        let session = BreathingSession(context: viewContext)
        session.id = UUID()
        session.date = Date()
        session.exerciseType = exerciseType
        session.durationSeconds = Int32(durationSeconds)
        session.cyclesCompleted = Int32(cyclesCompleted)

        // Update stats
        let stats = fetchOrCreateUserStats()
        stats.totalSessions += 1
        stats.totalMinutes += minutes

        // Update streak
        updateStreak(stats: stats)

        // Streak bonus XP
        for bonus in GamificationConstants.streakBonuses {
            if Int(stats.currentStreak) == bonus.days {
                xp += bonus.xp
            }
        }

        // Apply XP
        stats.currentXP += Int32(xp)
        session.xpEarned = Int32(xp)
        lastSessionXP = xp

        // Check level up
        let newLevel = GamificationConstants.levelFor(xp: Int(stats.currentXP))
        if newLevel.number > previousLevel {
            stats.currentLevel = Int32(newLevel.number)
            didLevelUp = true
            newLevelName = newLevel.name
        }

        stats.lastSessionDate = Date()
        saveContext()

        // Update published properties
        currentStreak = Int(stats.currentStreak)
        longestStreak = Int(stats.longestStreak)
        totalSessions = Int(stats.totalSessions)
        totalMinutes = stats.totalMinutes
        currentXP = Int(stats.currentXP)
        currentLevel = Int(stats.currentLevel)
        lastSessionDate = stats.lastSessionDate

        // Check personal best (longest session)
        checkPersonalBest(durationSeconds: durationSeconds)

        // Check achievements
        checkAchievements(exerciseType: exerciseType, stats: stats)

        // Refresh today's protocol completion status
        if let tier = currentBOLTTier() {
            refreshTodayProtocolStatus(for: tier)
        }
    }

    // MARK: - Streak logic

    private func updateStreak(stats: UserStats) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = stats.lastSessionDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff == 0 {
                // Same day, streak stays
            } else if daysDiff == 1 {
                // Consecutive day
                stats.currentStreak += 1
            } else {
                // Streak broken, start fresh
                stats.currentStreak = 1
            }
        } else {
            // First ever session
            stats.currentStreak = 1
        }

        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }
    }

    func refreshStreak() {
        let stats = fetchOrCreateUserStats()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = stats.lastSessionDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff > 1 {
                // Streak is broken
                stats.currentStreak = 0
                saveContext()
                currentStreak = 0
            }
        }
    }

    // MARK: - Personal best check

    private func checkPersonalBest(durationSeconds: Int) {
        let request: NSFetchRequest<BreathingSession> = BreathingSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BreathingSession.durationSeconds, ascending: false)]
        request.fetchLimit = 1
        do {
            if let best = try viewContext.fetch(request).first {
                if Int(best.durationSeconds) == durationSeconds {
                    isPersonalBest = true
                }
            }
        } catch {
            print("Error checking personal best: \(error)")
        }
    }

    // MARK: - BOLT Score

    func saveBOLTScore(seconds: Double) {
        newlyUnlockedAchievements = []

        let score = BOLTScore(context: viewContext)
        score.id = UUID()
        score.date = Date()
        score.scoreSeconds = seconds

        // Check BOLT improvement bonus
        let previousBest = fetchBestBOLTScore()
        if seconds > previousBest {
            let improvement = seconds - previousBest
            let bonusXP = Int(improvement) * GamificationConstants.boltImprovementXPPerSecond
            if bonusXP > 0 {
                let stats = fetchOrCreateUserStats()
                let previousLevel = Int(stats.currentLevel)
                stats.currentXP += Int32(bonusXP)
                let newLevel = GamificationConstants.levelFor(xp: Int(stats.currentXP))
                if newLevel.number > previousLevel {
                    stats.currentLevel = Int32(newLevel.number)
                    didLevelUp = true
                    newLevelName = newLevel.name
                }
                currentXP = Int(stats.currentXP)
                currentLevel = Int(stats.currentLevel)
            }
        }

        saveContext()

        // Check BOLT achievements
        checkBOLTAchievements(seconds: seconds)
    }

    func fetchBOLTScores() -> [BOLTScore] {
        let request: NSFetchRequest<BOLTScore> = BOLTScore.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BOLTScore.date, ascending: true)]
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching BOLT scores: \(error)")
            return []
        }
    }

    func fetchBestBOLTScore() -> Double {
        let request: NSFetchRequest<BOLTScore> = BOLTScore.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BOLTScore.scoreSeconds, ascending: false)]
        request.fetchLimit = 1
        do {
            return try viewContext.fetch(request).first?.scoreSeconds ?? 0
        } catch {
            return 0
        }
    }

    func fetchLatestBOLTScore() -> Double {
        let request: NSFetchRequest<BOLTScore> = BOLTScore.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BOLTScore.date, ascending: false)]
        request.fetchLimit = 1
        do {
            return try viewContext.fetch(request).first?.scoreSeconds ?? 0
        } catch {
            return 0
        }
    }

    func fetchLatestBOLTDate() -> Date? {
        let request: NSFetchRequest<BOLTScore> = BOLTScore.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BOLTScore.date, ascending: false)]
        request.fetchLimit = 1
        do {
            return try viewContext.fetch(request).first?.date
        } catch {
            return nil
        }
    }

    func daysSinceLastBOLTTest() -> Int? {
        guard let lastDate = fetchLatestBOLTDate() else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate),
                                       to: calendar.startOfDay(for: Date())).day
    }

    func shouldSuggestBOLTRetest() -> Bool {
        guard let days = daysSinceLastBOLTTest() else { return false }
        return days >= 7
    }

    func currentBOLTTier() -> BOLTTier? {
        let score = fetchLatestBOLTScore()
        guard score > 0 else { return nil }
        return BOLTTier.tier(for: score)
    }

    // MARK: - Session history

    func fetchRecentSessions(limit: Int = 7) -> [BreathingSession] {
        let request: NSFetchRequest<BreathingSession> = BreathingSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BreathingSession.date, ascending: false)]
        request.fetchLimit = limit
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }

    func fetchLongestSession() -> Int {
        let request: NSFetchRequest<BreathingSession> = BreathingSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BreathingSession.durationSeconds, ascending: false)]
        request.fetchLimit = 1
        do {
            return Int(try viewContext.fetch(request).first?.durationSeconds ?? 0)
        } catch {
            return 0
        }
    }

    func sessionsOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        let request: NSFetchRequest<BreathingSession> = BreathingSession.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        request.fetchLimit = 1
        do {
            return try viewContext.fetch(request).count > 0
        } catch {
            return false
        }
    }

    func uniqueExerciseTypes() -> Set<String> {
        let request: NSFetchRequest<BreathingSession> = BreathingSession.fetchRequest()
        do {
            let sessions = try viewContext.fetch(request)
            return Set(sessions.compactMap { $0.exerciseType })
        } catch {
            return []
        }
    }

    // MARK: - Achievement checking

    private func checkAchievements(exerciseType: String, stats: UserStats) {
        var newlyUnlocked: [AchievementDefinition] = []

        let checks: [(String, Bool)] = [
            ("first_breath", stats.totalSessions >= 1),
            ("sessions_10", stats.totalSessions >= 10),
            ("sessions_50", stats.totalSessions >= 50),
            ("sessions_100", stats.totalSessions >= 100),
            ("streak_3", stats.currentStreak >= 3),
            ("streak_7", stats.currentStreak >= 7),
            ("streak_30", stats.currentStreak >= 30),
            ("streak_100", stats.currentStreak >= 100),
            ("time_1hr", stats.totalMinutes >= 60),
            ("time_10hr", stats.totalMinutes >= 600),
            ("early_bird", Calendar.current.component(.hour, from: Date()) < 7),
        ]

        for (id, condition) in checks {
            if condition && !unlockedAchievementIDs.contains(id) {
                if let def = AchievementCatalog.definition(for: id) {
                    unlockAchievement(id: id)
                    newlyUnlocked.append(def)
                }
            }
        }

        // Variety check
        let types = uniqueExerciseTypes()
        if types.count >= 3 && !unlockedAchievementIDs.contains("variety_all") {
            if let def = AchievementCatalog.definition(for: "variety_all") {
                unlockAchievement(id: "variety_all")
                newlyUnlocked.append(def)
            }
        }

        newlyUnlockedAchievements = newlyUnlocked
    }

    private func checkBOLTAchievements(seconds: Double) {
        var newlyUnlocked: [AchievementDefinition] = []

        let checks: [(String, Bool)] = [
            ("bolt_first", true),
            ("bolt_20", seconds >= 20),
            ("bolt_30", seconds >= 30),
            ("bolt_40", seconds >= 40),
        ]

        for (id, condition) in checks {
            if condition && !unlockedAchievementIDs.contains(id) {
                if let def = AchievementCatalog.definition(for: id) {
                    unlockAchievement(id: id)
                    newlyUnlocked.append(def)
                }
            }
        }

        newlyUnlockedAchievements.append(contentsOf: newlyUnlocked)
    }

    private func unlockAchievement(id: String) {
        let achievement = Achievement(context: viewContext)
        achievement.id = id
        achievement.unlockedDate = Date()
        unlockedAchievementIDs.insert(id)
        saveContext()
    }

    // MARK: - Save

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
