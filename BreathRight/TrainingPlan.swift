import Foundation

// MARK: - BOLT Tier

enum BOLTTier: String, CaseIterable {
    case roomToGrow = "Room to Grow"
    case developing = "Developing"
    case good = "Good"
    case veryGood = "Very Good"
    case elite = "Elite"

    var boltRange: String {
        switch self {
        case .roomToGrow: return "<10s"
        case .developing: return "10-19s"
        case .good: return "20-29s"
        case .veryGood: return "30-39s"
        case .elite: return "40s+"
        }
    }

    static func tier(for score: Double) -> BOLTTier {
        switch score {
        case ..<10: return .roomToGrow
        case 10..<20: return .developing
        case 20..<30: return .good
        case 30..<40: return .veryGood
        default: return .elite
        }
    }

    var nextTier: BOLTTier? {
        switch self {
        case .roomToGrow: return .developing
        case .developing: return .good
        case .good: return .veryGood
        case .veryGood: return .elite
        case .elite: return nil
        }
    }

    var benefitsDescription: String {
        switch self {
        case .roomToGrow:
            return "You're retraining nasal breathing and slowing your resting breath rate. Most people here over-breathe without realizing it."
        case .developing:
            return "Your CO\u{2082} tolerance is increasing. Nasal breathing at rest becomes easier and breath holds feel less urgent."
        case .good:
            return "You can hold your breath comfortably for 20+ seconds. Nasal breathing during light exercise is sustainable. Your resting breath rate is lower."
        case .veryGood:
            return "High CO\u{2082} tolerance. You can nasal-breathe during moderate exercise. Your body extracts oxygen more efficiently (Bohr effect)."
        case .elite:
            return "Top-tier CO\u{2082} tolerance. Low resting breath rate, comfortable long holds, efficient oxygen delivery. This is where serious practitioners sit."
        }
    }
}

// MARK: - Prescribed Exercise

struct PrescribedExercise {
    let exerciseType: BreathingExercise
    let inhale: Int
    let hold: Int
    let exhale: Int
    let cycles: Int
    let coachingNote: String
    let recovery: Int

    init(exerciseType: BreathingExercise, inhale: Int, hold: Int, exhale: Int, cycles: Int, coachingNote: String, recovery: Int = 0) {
        self.exerciseType = exerciseType
        self.inhale = inhale
        self.hold = hold
        self.exhale = exhale
        self.cycles = cycles
        self.coachingNote = coachingNote
        self.recovery = recovery
    }

    var timingLabel: String {
        switch exerciseType {
        case .boxBreathing:
            return "\(inhale)-\(hold)-\(exhale)-\(hold)"
        case .fourSevenEight:
            return "4-7-8"
        case .exhaleHold:
            return "\(inhale)-\(exhale)-\(hold)-\(recovery)"
        case .custom:
            return "\(inhale)-\(hold)-\(exhale)"
        }
    }

    var estimatedDurationSeconds: Int {
        switch exerciseType {
        case .boxBreathing:
            return (inhale + hold + exhale + hold) * cycles
        case .fourSevenEight:
            return (4 + 7 + 8) * cycles
        case .exhaleHold:
            return (inhale + exhale + hold + recovery) * cycles
        case .custom:
            return (inhale + hold + exhale) * cycles
        }
    }

    /// A descriptive technique name derived from the breathing pattern.
    var displayName: String {
        switch exerciseType {
        case .boxBreathing:
            return "Box Breathing"
        case .fourSevenEight:
            return "4-7-8 Breathing"
        case .exhaleHold:
            if hold >= 20 { return "Advanced Exhale Hold" }
            else if hold >= 10 { return "Exhale Hold" }
            else { return "Beginner Exhale Hold" }
        case .custom:
            if hold == 0 {
                return "Extended Exhale"
            } else if hold >= 15 {
                return "Advanced Retention"
            } else if hold >= 10 {
                return "Deep Retention"
            } else if exhale >= hold * 2 {
                return "Calming Breath"
            } else {
                return "CO\u{2082} Tolerance"
            }
        }
    }

    var estimatedDurationLabel: String {
        let seconds = estimatedDurationSeconds
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        let remainder = seconds % 60
        if remainder == 0 {
            return "\(minutes)m"
        }
        return "\(minutes)m \(remainder)s"
    }

    /// Writes the prescribed settings to UserDefaults so the exercise view picks them up.
    func applyToUserDefaults() {
        UserDefaults.standard.set(cycles, forKey: "numCycles")
        UserDefaults.standard.set(false, forKey: "unlimtedCycles")

        if exerciseType == .custom || exerciseType == .exhaleHold {
            UserDefaults.standard.set(inhale, forKey: "customInhale")
            UserDefaults.standard.set(hold, forKey: "customHold")
            UserDefaults.standard.set(exhale, forKey: "customExhale")
            UserDefaults.standard.set(recovery, forKey: "customRecovery")
        }
    }
}

// MARK: - Training Plan Provider

struct TrainingPlanProvider {

    /// Returns today's prescribed exercise for the given BOLT tier.
    static func todaysExercise(for tier: BOLTTier) -> PrescribedExercise {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Map Calendar weekday to Mon=0 ... Sun=6
        let dayIndex = (weekday + 5) % 7
        return exercises(for: tier)[dayIndex]
    }

    /// Returns all 7 daily exercises for a tier.
    static func exercises(for tier: BOLTTier) -> [PrescribedExercise] {
        switch tier {
        case .roomToGrow: return tier1
        case .developing: return tier2
        case .good: return tier3
        case .veryGood: return tier4
        case .elite: return tier5
        }
    }

    /// Returns tomorrow's prescribed exercise for the given BOLT tier.
    static func tomorrowsExercise(for tier: BOLTTier) -> PrescribedExercise {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let dayIndex = (weekday + 5) % 7
        let tomorrowIndex = (dayIndex + 1) % 7
        return exercises(for: tier)[tomorrowIndex]
    }

    /// Returns a training theme label for today's day of the week.
    static func todaysDayLabel(for tier: BOLTTier) -> String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let dayIndex = (weekday + 5) % 7  // Mon=0 ... Sun=6
        let exercise = exercises(for: tier)[dayIndex]
        switch dayIndex {
        case 0: return "Foundation"     // Monday
        case 1: return "Build"          // Tuesday
        case 2: return "Challenge"      // Wednesday (exhale hold day)
        case 3: return "Build"          // Thursday
        case 4: return "Endurance"      // Friday
        case 5:                         // Saturday
            return exercise.exerciseType == .exhaleHold ? "Challenge" : "Build"
        case 6: return "Recovery"       // Sunday
        default: return "Practice"
        }
    }

    /// Current day-of-week label (e.g. "Monday").
    static var todayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    // MARK: - Tier 1: Room to Grow (BOLT <10s)

    private static let tier1: [PrescribedExercise] = [
        // Monday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 6,
                           coachingNote: "Start simple. Even rhythm builds your foundation."),
        // Tuesday
        PrescribedExercise(exerciseType: .custom, inhale: 3, hold: 0, exhale: 6, cycles: 8,
                           coachingNote: "A longer exhale activates your rest-and-digest system."),
        // Wednesday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 5, exhale: 4, cycles: 4,
                           coachingNote: "Your first exhale hold. Short hold, easy recovery. Just notice the urge to breathe.", recovery: 30),
        // Thursday
        PrescribedExercise(exerciseType: .custom, inhale: 4, hold: 2, exhale: 6, cycles: 6,
                           coachingNote: "Gentle hold today. Training CO\u{2082} comfort."),
        // Friday
        PrescribedExercise(exerciseType: .fourSevenEight, inhale: 4, hold: 7, exhale: 8, cycles: 4,
                           coachingNote: "The gold standard for calming. Let the long exhale work."),
        // Saturday
        PrescribedExercise(exerciseType: .custom, inhale: 3, hold: 3, exhale: 6, cycles: 6,
                           coachingNote: "Balanced holds build tolerance without strain."),
        // Sunday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 6,
                           coachingNote: "Rest day rhythm. Easy and steady."),
    ]

    // MARK: - Tier 2: Developing (BOLT 10-19s)

    private static let tier2: [PrescribedExercise] = [
        // Monday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 10,
                           coachingNote: "Solid box sets your baseline for the week."),
        // Tuesday
        PrescribedExercise(exerciseType: .custom, inhale: 4, hold: 4, exhale: 8, cycles: 8,
                           coachingNote: "Extended exhale with a hold. CO\u{2082} tolerance in action."),
        // Wednesday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 10, exhale: 6, cycles: 5,
                           coachingNote: "10-second exhale hold. Sit with the urge to breathe — it passes.", recovery: 25),
        // Thursday
        PrescribedExercise(exerciseType: .custom, inhale: 4, hold: 6, exhale: 8, cycles: 6,
                           coachingNote: "Pushing the hold to 6s. Breathe through the urge."),
        // Friday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 12,
                           coachingNote: "Longer session today. Endurance builds control."),
        // Saturday
        PrescribedExercise(exerciseType: .custom, inhale: 5, hold: 5, exhale: 10, cycles: 6,
                           coachingNote: "1:1:2 ratio. A classic CO\u{2082} tolerance builder."),
        // Sunday
        PrescribedExercise(exerciseType: .fourSevenEight, inhale: 4, hold: 7, exhale: 8, cycles: 4,
                           coachingNote: "Light finish. Recovery to close the week."),
    ]

    // MARK: - Tier 3: Good (BOLT 20-29s)

    private static let tier3: [PrescribedExercise] = [
        // Monday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 15,
                           coachingNote: "A solid 4-minute box. Sustained practice."),
        // Tuesday
        PrescribedExercise(exerciseType: .custom, inhale: 4, hold: 8, exhale: 8, cycles: 8,
                           coachingNote: "8-second holds. Your CO\u{2082} tolerance is real."),
        // Wednesday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 15, exhale: 6, cycles: 6,
                           coachingNote: "15-second exhale hold. This is real Buteyko training. Stay relaxed.", recovery: 20),
        // Thursday
        PrescribedExercise(exerciseType: .custom, inhale: 5, hold: 10, exhale: 10, cycles: 6,
                           coachingNote: "10-second hold. Where breakthroughs happen."),
        // Friday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 18,
                           coachingNote: "Approaching 5 minutes. Capacity is growing."),
        // Saturday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 15, exhale: 6, cycles: 6,
                           coachingNote: "Second exhale hold this week. Building serious CO\u{2082} tolerance.", recovery: 20),
        // Sunday
        PrescribedExercise(exerciseType: .fourSevenEight, inhale: 4, hold: 7, exhale: 8, cycles: 6,
                           coachingNote: "Easy close. Let the nervous system integrate."),
    ]

    // MARK: - Tier 4: Very Good (BOLT 30-39s)

    private static let tier4: [PrescribedExercise] = [
        // Monday
        PrescribedExercise(exerciseType: .custom, inhale: 4, hold: 12, exhale: 8, cycles: 8,
                           coachingNote: "12-second holds. Comfortable discomfort builds mastery."),
        // Tuesday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 22,
                           coachingNote: "Six-minute box. You have the endurance."),
        // Wednesday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 25, exhale: 8, cycles: 6,
                           coachingNote: "25-second exhale hold. Deep CO\u{2082} tolerance work. Stay completely relaxed.", recovery: 15),
        // Thursday
        PrescribedExercise(exerciseType: .fourSevenEight, inhale: 4, hold: 7, exhale: 8, cycles: 10,
                           coachingNote: "10 rounds. A deep parasympathetic reset."),
        // Friday
        PrescribedExercise(exerciseType: .custom, inhale: 4, hold: 10, exhale: 12, cycles: 8,
                           coachingNote: "Extended exhale day. 12 seconds out, fully relaxed."),
        // Saturday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 25, exhale: 8, cycles: 6,
                           coachingNote: "Second exhale hold. You're training what BOLT directly measures.", recovery: 15),
        // Sunday
        PrescribedExercise(exerciseType: .fourSevenEight, inhale: 4, hold: 7, exhale: 8, cycles: 6,
                           coachingNote: "Recovery session. Gentle close."),
    ]

    // MARK: - Tier 5: Elite (BOLT 40s+)

    private static let tier5: [PrescribedExercise] = [
        // Monday
        PrescribedExercise(exerciseType: .custom, inhale: 5, hold: 20, exhale: 10, cycles: 6,
                           coachingNote: "20-second holds. Top tier of breathers."),
        // Tuesday
        PrescribedExercise(exerciseType: .boxBreathing, inhale: 4, hold: 4, exhale: 4, cycles: 30,
                           coachingNote: "8-minute box. Meditative endurance."),
        // Wednesday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 35, exhale: 8, cycles: 8,
                           coachingNote: "35-second exhale hold. Peak Buteyko. Total relaxation through the urge.", recovery: 15),
        // Thursday
        PrescribedExercise(exerciseType: .fourSevenEight, inhale: 4, hold: 7, exhale: 8, cycles: 12,
                           coachingNote: "12 rounds. Deep parasympathetic mastery."),
        // Friday
        PrescribedExercise(exerciseType: .custom, inhale: 5, hold: 20, exhale: 15, cycles: 6,
                           coachingNote: "Peak challenge. 20s hold, 15s exhale."),
        // Saturday
        PrescribedExercise(exerciseType: .exhaleHold, inhale: 4, hold: 35, exhale: 8, cycles: 8,
                           coachingNote: "Second exhale hold. You're in elite territory. Own the discomfort.", recovery: 15),
        // Sunday
        PrescribedExercise(exerciseType: .fourSevenEight, inhale: 4, hold: 7, exhale: 8, cycles: 8,
                           coachingNote: "Restorative close. Even elites need recovery."),
    ]
}
