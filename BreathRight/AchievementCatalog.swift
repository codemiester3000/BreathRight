import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: Category

    enum Category: String, CaseIterable {
        case sessions = "Sessions"
        case streaks = "Streaks"
        case time = "Time"
        case bolt = "BOLT"
        case variety = "Variety"
    }
}

struct AchievementCatalog {
    static let all: [AchievementDefinition] = [
        // Session milestones
        AchievementDefinition(id: "first_breath", name: "First Breath", description: "Finish any breathing session to unlock", icon: "wind", category: .sessions),
        AchievementDefinition(id: "sessions_10", name: "Getting Started", description: "Complete 10 total sessions — any exercise counts", icon: "flame", category: .sessions),
        AchievementDefinition(id: "sessions_50", name: "Dedicated", description: "Complete 50 total sessions", icon: "star", category: .sessions),
        AchievementDefinition(id: "sessions_100", name: "Centurion", description: "Complete 100 total sessions", icon: "crown", category: .sessions),

        // Streak milestones
        AchievementDefinition(id: "streak_3", name: "Hat Trick", description: "Practice 3 days in a row", icon: "flame.fill", category: .streaks),
        AchievementDefinition(id: "streak_7", name: "Weekly Warrior", description: "Practice every day for a full week", icon: "calendar", category: .streaks),
        AchievementDefinition(id: "streak_30", name: "Monthly Master", description: "Keep a 30-day daily streak going", icon: "calendar.badge.clock", category: .streaks),
        AchievementDefinition(id: "streak_100", name: "Unstoppable", description: "Maintain a 100-day daily streak", icon: "bolt.shield", category: .streaks),

        // Time milestones
        AchievementDefinition(id: "time_1hr", name: "One Hour", description: "Accumulate 60 minutes of total practice time", icon: "hourglass", category: .time),
        AchievementDefinition(id: "time_10hr", name: "Ten Hours", description: "Accumulate 10 hours of total practice time", icon: "hourglass.bottomhalf.filled", category: .time),

        // BOLT milestones
        AchievementDefinition(id: "bolt_first", name: "First Test", description: "Take a BOLT test from the home screen", icon: "lungs", category: .bolt),
        AchievementDefinition(id: "bolt_20", name: "Building CO\u{2082} Tolerance", description: "Reach a 20-second BOLT score through consistent practice", icon: "chart.line.uptrend.xyaxis", category: .bolt),
        AchievementDefinition(id: "bolt_30", name: "Strong Lungs", description: "Reach a 30-second BOLT score — a sign of real CO\u{2082} tolerance", icon: "figure.mind.and.body", category: .bolt),
        AchievementDefinition(id: "bolt_40", name: "Elite Breather", description: "Reach a 40-second BOLT score — top-tier breath control", icon: "trophy", category: .bolt),

        // Variety
        AchievementDefinition(id: "variety_all", name: "Explorer", description: "Try Box Breathing, 4-7-8, and a Custom exercise", icon: "squares.leading.rectangle", category: .variety),
        AchievementDefinition(id: "early_bird", name: "Early Bird", description: "Complete a session before 7:00 AM", icon: "sunrise", category: .variety),
    ]

    static func definition(for id: String) -> AchievementDefinition? {
        all.first { $0.id == id }
    }

    static func nextMilestones(
        unlockedIDs: Set<String>,
        totalSessions: Int,
        currentStreak: Int,
        totalMinutes: Double,
        bestBOLT: Double,
        uniqueTypes: Int
    ) -> [MilestoneProgress] {
        // (id, current, target, label with units)
        let mapping: [(id: String, current: Int, target: Int, label: String)] = [
            ("first_breath", min(totalSessions, 1), 1, "\(min(totalSessions, 1))/1 session"),
            ("sessions_10", min(totalSessions, 10), 10, "\(min(totalSessions, 10))/10 sessions"),
            ("sessions_50", min(totalSessions, 50), 50, "\(min(totalSessions, 50))/50 sessions"),
            ("sessions_100", min(totalSessions, 100), 100, "\(min(totalSessions, 100))/100 sessions"),
            ("streak_3", min(currentStreak, 3), 3, "\(min(currentStreak, 3))/3 day streak"),
            ("streak_7", min(currentStreak, 7), 7, "\(min(currentStreak, 7))/7 day streak"),
            ("streak_30", min(currentStreak, 30), 30, "\(min(currentStreak, 30))/30 day streak"),
            ("streak_100", min(currentStreak, 100), 100, "\(min(currentStreak, 100))/100 day streak"),
            ("time_1hr", min(Int(totalMinutes), 60), 60, "\(min(Int(totalMinutes), 60))/60 min"),
            ("time_10hr", min(Int(totalMinutes), 600), 600, "\(min(Int(totalMinutes), 600))/600 min"),
            ("bolt_first", bestBOLT > 0 ? 1 : 0, 1, bestBOLT > 0 ? "done" : "not tested"),
            ("bolt_20", min(Int(bestBOLT), 20), 20, "\(Int(bestBOLT))s / 20s BOLT"),
            ("bolt_30", min(Int(bestBOLT), 30), 30, "\(Int(bestBOLT))s / 30s BOLT"),
            ("bolt_40", min(Int(bestBOLT), 40), 40, "\(Int(bestBOLT))s / 40s BOLT"),
            ("variety_all", min(uniqueTypes, 3), 3, "\(min(uniqueTypes, 3))/3 types tried"),
        ]

        var milestones: [MilestoneProgress] = []
        for entry in mapping {
            guard !unlockedIDs.contains(entry.id) else { continue }
            guard let def = definition(for: entry.id) else { continue }
            milestones.append(MilestoneProgress(
                id: def.id,
                name: def.name,
                description: def.description,
                icon: def.icon,
                progressLabel: entry.label,
                current: entry.current,
                target: entry.target
            ))
        }

        milestones.sort { $0.fraction > $1.fraction }
        return Array(milestones.prefix(3))
    }
}

struct MilestoneProgress: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let progressLabel: String
    let current: Int
    let target: Int

    var fraction: Double {
        Double(current) / Double(max(target, 1))
    }
}
