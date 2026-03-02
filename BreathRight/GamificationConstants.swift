import Foundation

struct GamificationConstants {
    // XP per minute of breathing
    static let xpPerMinute: Int = 10
    // Minimum XP per session
    static let minimumSessionXP: Int = 5

    // Streak milestone bonuses
    static let streakBonuses: [(days: Int, xp: Int)] = [
        (3, 25),
        (7, 75),
        (14, 150),
        (30, 500),
        (60, 1000),
        (100, 2000)
    ]

    // BOLT improvement bonus: XP per second improved over previous best
    static let boltImprovementXPPerSecond: Int = 20

    // Level definitions
    struct Level {
        let number: Int
        let name: String
        let xpRequired: Int
    }

    static let levels: [Level] = [
        Level(number: 0, name: "New", xpRequired: 0),
        Level(number: 1, name: "Beginner", xpRequired: 50),
        Level(number: 2, name: "Regular", xpRequired: 150),
        Level(number: 3, name: "Consistent", xpRequired: 400),
        Level(number: 4, name: "Practiced", xpRequired: 800),
        Level(number: 5, name: "Experienced", xpRequired: 1500),
        Level(number: 6, name: "Seasoned", xpRequired: 3000),
        Level(number: 7, name: "Veteran", xpRequired: 5000),
        Level(number: 8, name: "Advanced", xpRequired: 8000),
        Level(number: 9, name: "Elite", xpRequired: 12000)
    ]

    static func levelFor(xp: Int) -> Level {
        var result = levels[0]
        for level in levels {
            if xp >= level.xpRequired {
                result = level
            } else {
                break
            }
        }
        return result
    }

    static func nextLevel(after currentLevel: Int) -> Level? {
        let nextIndex = currentLevel + 1
        guard nextIndex < levels.count else { return nil }
        return levels[nextIndex]
    }

    static func xpProgressInLevel(xp: Int) -> (current: Int, needed: Int, fraction: Double) {
        let level = levelFor(xp: xp)
        guard let next = nextLevel(after: level.number) else {
            return (0, 1, 1.0) // Max level
        }
        let currentInLevel = xp - level.xpRequired
        let neededForNext = next.xpRequired - level.xpRequired
        let fraction = Double(currentInLevel) / Double(neededForNext)
        return (currentInLevel, neededForNext, fraction)
    }
}
