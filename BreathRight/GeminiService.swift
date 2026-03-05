import Foundation

@MainActor
class GeminiService: ObservableObject {
    @Published var isLoading = false
    @Published var insightText: String = ""
    @Published var hasError = false

    @Published var isLoadingTip = false
    @Published var exerciseTipText: String = ""
    @Published var showExerciseTip = false

    private let cacheKey = "gemini_insight_text"
    private let cacheDateKey = "gemini_insight_date"
    private let tipCacheKey = "gemini_exercise_tip_text"
    private let tipCacheDateKey = "gemini_exercise_tip_date"
    private let apiKey = "AIzaSyBNyCpS0KFhMf4iBd1sPPBfR-VYPO97jcA"

    private static let fallbackMessages = [
        "Consistent practice lowers your resting breath rate over time. That means better CO\u{2082} tolerance, which is what the BOLT score actually measures. Keep practicing daily.",
        "Breathwork isn't magic — it's training your chemoreceptors to tolerate higher CO\u{2082} levels. That tolerance is what makes you calmer under stress. It takes weeks of daily work.",
        "The goal is simple: breathe less, through your nose, more slowly. Every session trains that pattern. Your BOLT score is the objective measure of progress."
    ]

    func fetchInsight(dataManager: DataManager) {
        // Check cache first
        let today = dateString(for: Date())
        if let cachedDate = UserDefaults.standard.string(forKey: cacheDateKey),
           cachedDate == today,
           let cachedText = UserDefaults.standard.string(forKey: cacheKey),
           !cachedText.isEmpty {
            insightText = cachedText
            return
        }

        isLoading = true
        hasError = false

        let tier = dataManager.currentBOLTTier()
        let boltScore = dataManager.fetchLatestBOLTScore()
        let level = GamificationConstants.levelFor(xp: dataManager.currentXP)

        let prompt = buildPrompt(
            boltScore: boltScore,
            tier: tier,
            streak: dataManager.currentStreak,
            sessions: dataManager.totalSessions,
            minutes: dataManager.totalMinutes,
            level: level.number,
            levelName: level.name
        )

        Task {
            do {
                let text = try await callGemini(prompt: prompt)
                insightText = text
                UserDefaults.standard.set(text, forKey: cacheKey)
                UserDefaults.standard.set(today, forKey: cacheDateKey)
                isLoading = false
            } catch {
                hasError = true
                insightText = Self.fallbackMessages.randomElement() ?? Self.fallbackMessages[0]
                isLoading = false
            }
        }
    }

    func fetchExerciseTip(exercise: PrescribedExercise, tier: BOLTTier, dataManager: DataManager) {
        let today = dateString(for: Date())
        if let cachedDate = UserDefaults.standard.string(forKey: tipCacheDateKey),
           cachedDate == today,
           let cachedText = UserDefaults.standard.string(forKey: tipCacheKey),
           !cachedText.isEmpty {
            exerciseTipText = cachedText
            return
        }

        isLoadingTip = true

        let boltScore = dataManager.fetchLatestBOLTScore()
        let streak = dataManager.currentStreak
        let sessions = dataManager.totalSessions

        let prompt = """
        You are a direct breathing coach. No cheerleading — the user wants honesty, not motivation posters. \
        User data:
        - BOLT score: \(String(format: "%.1f", boltScore))s (\(tier.rawValue) tier, range \(tier.boltRange))
        - Streak: \(streak) day\(streak == 1 ? "" : "s")
        - Total sessions: \(sessions)

        Today's exercise: \(exercise.displayName) — \(exercise.timingLabel) pattern, \
        \(exercise.cycles) cycles, ~\(exercise.estimatedDurationLabel). \
        Coaching context: "\(exercise.coachingNote)"

        Write 2 sentences. First: briefly acknowledge their current state (streak, sessions) — be honest, \
        if they're just starting say so, don't inflate it. Second: explain the actual physiological reason \
        this specific exercise pattern was prescribed for their BOLT tier today. Reference real mechanisms \
        (vagal tone from extended exhale, CO\u{2082} chemoreceptor adaptation from holds, parasympathetic \
        activation, etc.) — only what's relevant to this exercise. Be specific to the numbers in the pattern. \
        No markdown, no bullet points, no emojis. Direct and honest.
        """

        Task {
            do {
                let text = try await callGemini(prompt: prompt)
                exerciseTipText = text
                UserDefaults.standard.set(text, forKey: tipCacheKey)
                UserDefaults.standard.set(today, forKey: tipCacheDateKey)
                isLoadingTip = false
            } catch {
                exerciseTipText = Self.exerciseFallback(exercise: exercise, tier: tier, streak: streak)
                isLoadingTip = false
            }
        }
    }

    private static func exerciseFallback(exercise: PrescribedExercise, tier: BOLTTier, streak: Int) -> String {
        let streakPart = streak > 1 ? "\(streak)-day streak. " : ""
        return "\(streakPart)Today's \(exercise.displayName) (\(exercise.timingLabel)) is prescribed for your BOLT tier (\(tier.boltRange)). \(exercise.coachingNote)"
    }

    private func buildPrompt(
        boltScore: Double,
        tier: BOLTTier?,
        streak: Int,
        sessions: Int,
        minutes: Double,
        level: Int,
        levelName: String
    ) -> String {
        let tierName = tier?.rawValue ?? "No test yet"
        let nextTierName = tier?.nextTier?.rawValue ?? "N/A"
        let nextBenefits = tier?.nextTier?.benefitsDescription ?? tier?.benefitsDescription ?? ""

        return """
        You are a direct, knowledgeable breathing coach. Be honest and specific — no empty encouragement. \
        The user's data:
        - BOLT score: \(boltScore > 0 ? String(format: "%.1f seconds", boltScore) : "Not tested yet")
        - BOLT tier: \(tierName)
        - Next tier: \(nextTierName)
        - Current streak: \(streak) days
        - Total sessions: \(sessions)
        - Total practice time: \(Int(minutes)) minutes
        - Practice level: \(level) (\(levelName)) — this reflects cumulative practice volume

        Write 2-3 sentences. Tell them where they actually stand — what their BOLT score and practice \
        volume mean for their CO\u{2082} tolerance and breath control. Be specific about what's happening \
        physiologically at their level (chemoreceptor adaptation, vagal tone, Bohr effect — only what's \
        relevant). Then tell them concretely what reaching the next tier (\(nextTierName)) would unlock: \
        \(nextBenefits) \
        If their numbers are low, be straight about it — they can handle it. If they're putting in real work, \
        acknowledge it as what it is: accumulated training. \
        No markdown, no bullet points, no emojis. Direct and honest.
        """
    }

    private func callGemini(prompt: String) async throws -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiError.invalidURL
        }

        let requestBody = GeminiRequest(
            contents: [GeminiContent(parts: [GeminiPart(text: prompt)])]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw GeminiError.badResponse
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = geminiResponse.candidates?.first?.content?.parts?.first?.text,
              !text.isEmpty else {
            throw GeminiError.emptyResponse
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Error

enum GeminiError: Error {
    case invalidURL
    case badResponse
    case emptyResponse
}

// MARK: - Request Models

private struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
}

private struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Codable {
    let text: String
}

// MARK: - Response Models

private struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]?
}

private struct GeminiCandidate: Decodable {
    let content: GeminiResponseContent?
}

private struct GeminiResponseContent: Decodable {
    let parts: [GeminiPart]?
}
