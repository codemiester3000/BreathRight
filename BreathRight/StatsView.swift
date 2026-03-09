import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var geminiService = GeminiService()
    var isTab: Bool = false

    @State private var appeared = false
    @State private var xpBarAnimated = false

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.07, blue: 0.10)
                .edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Nav bar for non-tab mode
                    if !isTab {
                        nonTabHeader
                            .padding(.top, 8)
                    }

                    // ── Hero ──
                    heroSection
                        .padding(.top, isTab ? 20 : 8)
                        .modifier(Reveal(appeared: appeared, delay: 0))

                    // ── Week ──
                    weekStrip
                        .padding(.top, 40)
                        .modifier(Reveal(appeared: appeared, delay: 0.06))

                    // ── Coach ──
                    if dataManager.totalSessions >= 3 {
                        coachQuote
                            .padding(.top, 36)
                            .modifier(Reveal(appeared: appeared, delay: 0.12))
                    }

                    // ── BOLT ──
                    if dataManager.currentBOLTTier() != nil {
                        boltSection
                            .padding(.top, 40)
                            .modifier(Reveal(appeared: appeared, delay: 0.18))
                    }

                    // ── Records ──
                    if dataManager.totalSessions > 0 {
                        recordsSection
                            .padding(.top, 40)
                            .modifier(Reveal(appeared: appeared, delay: 0.24))
                    }

                    // ── Milestones ──
                    let milestones = AchievementCatalog.nextMilestones(
                        unlockedIDs: dataManager.unlockedAchievementIDs,
                        totalSessions: dataManager.totalSessions,
                        currentStreak: dataManager.currentStreak,
                        totalMinutes: dataManager.totalMinutes,
                        bestBOLT: dataManager.fetchBestBOLTScore(),
                        uniqueTypes: dataManager.uniqueExerciseTypes().count
                    )
                    if !milestones.isEmpty {
                        milestonesTimeline(milestones)
                            .padding(.top, 40)
                            .modifier(Reveal(appeared: appeared, delay: 0.30))
                    }

                    // ── Trophies ──
                    trophyGrid
                        .padding(.top, 40)
                        .modifier(Reveal(appeared: appeared, delay: 0.36))

                    // ── History ──
                    let recent = dataManager.fetchRecentSessions(limit: 5)
                    if !recent.isEmpty {
                        historyList(recent)
                            .padding(.top, 40)
                            .modifier(Reveal(appeared: appeared, delay: 0.42))
                    }

                    Spacer().frame(height: isTab ? 120 : 60)
                }
                .padding(.horizontal, 28)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            geminiService.fetchInsight(dataManager: dataManager)
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            withAnimation(.easeOut(duration: 1.0).delay(0.4)) { xpBarAnimated = true }
        }
    }

    // MARK: - Non-Tab Header

    private var nonTabHeader: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        let level = GamificationConstants.levelFor(xp: dataManager.currentXP)
        let progress = GamificationConstants.xpProgressInLevel(xp: dataManager.currentXP)

        return VStack(spacing: 0) {
            // Level number — massive, confident
            Text("\(level.number)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, -8)

            // Level name
            Text(level.name.uppercased())
                .font(.system(size: 13, weight: .semibold))
                .tracking(4)
                .foregroundColor(.white.opacity(0.35))
                .padding(.top, -4)

            // XP bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 2)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(0.5))
                        .frame(
                            width: geo.size.width * (xpBarAnimated ? CGFloat(progress.fraction) : 0),
                            height: 2
                        )
                }
            }
            .frame(height: 2)
            .padding(.top, 20)

            // XP label
            if let next = GamificationConstants.nextLevel(after: level.number) {
                Text("\(progress.current) / \(progress.needed) to \(next.name)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.top, 8)
            }

            // Tier badge if exists
            if let tier = dataManager.currentBOLTTier() {
                Text(tier.rawValue.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(Color(red: 0.95, green: 0.75, blue: 0.4))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0.95, green: 0.75, blue: 0.4).opacity(0.25), lineWidth: 1)
                    )
                    .padding(.top, 14)
            }

            // Three stats
            HStack(spacing: 0) {
                statColumn(
                    number: "\(dataManager.currentStreak)",
                    label: "streak"
                )
                statDivider
                statColumn(
                    number: "\(dataManager.totalSessions)",
                    label: "sessions"
                )
                statDivider
                statColumn(
                    number: formatMinutes(dataManager.totalMinutes),
                    label: "total"
                )
            }
            .padding(.top, 28)
        }
    }

    private func statColumn(number: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(number)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(width: 1, height: 28)
    }

    // MARK: - Week Strip

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 16) {
            label("this week")

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date())!
                    let practiced = dataManager.sessionsOnDate(date)
                    let isToday = Calendar.current.isDateInToday(date)

                    VStack(spacing: 6) {
                        Circle()
                            .fill(practiced
                                ? Color.white
                                : isToday
                                    ? Color.white.opacity(0.12)
                                    : Color.white.opacity(0.04))
                            .frame(width: practiced ? 10 : 8, height: practiced ? 10 : 8)

                        Text(shortDay(date))
                            .font(.system(size: 9, weight: isToday ? .bold : .regular))
                            .foregroundColor(isToday ? .white.opacity(0.6) : .white.opacity(0.2))
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if dataManager.currentStreak > 0 {
                Text("\(dataManager.currentStreak)-day streak")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
            }
        }
    }

    // MARK: - Coach Quote

    private var coachQuote: some View {
        VStack(alignment: .leading, spacing: 0) {
            if geminiService.isLoading {
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 4, height: 4)
                            .scaleEffect(appeared ? 1.0 : 0.4)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.15),
                                value: appeared
                            )
                    }
                }
                .padding(.leading, 16)
            } else {
                Text(geminiService.insightText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.45))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 16)
            }
        }
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 2),
            alignment: .leading
        )
    }

    // MARK: - BOLT

    private var boltSection: some View {
        let scores = dataManager.fetchBOLTScores()
        let tier = dataManager.currentBOLTTier()!
        let latestScore = dataManager.fetchLatestBOLTScore()

        return VStack(alignment: .leading, spacing: 16) {
            label("bolt")

            // Score + tier
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(format: "%.1f", latestScore))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("sec")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.2))
                Spacer()
                Text(tier.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.35))
            }

            // Chart
            if !scores.isEmpty {
                BOLTChartView(scores: scores)
                    .frame(height: 80)
            }

            // Retest
            if let days = dataManager.daysSinceLastBOLTTest() {
                NavigationLink(destination: TierDetailView(currentTier: tier).environmentObject(dataManager)) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 10))
                        Text(days == 0 ? "Tested today" : "Tested \(days)d ago")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(days >= 7 ? .white.opacity(0.5) : .white.opacity(0.2))
                }
            }
        }
    }

    // MARK: - Records

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            label("records")

            HStack(spacing: 0) {
                recordItem(
                    value: "\(dataManager.longestStreak)",
                    unit: "d",
                    caption: "best streak"
                )
                recordItem(
                    value: formatDurationShort(dataManager.fetchLongestSession()),
                    unit: "",
                    caption: "longest"
                )
                recordItem(
                    value: dataManager.fetchBestBOLTScore() > 0
                        ? String(format: "%.0f", dataManager.fetchBestBOLTScore())
                        : "\u{2014}",
                    unit: dataManager.fetchBestBOLTScore() > 0 ? "s" : "",
                    caption: "best bolt"
                )
            }
        }
    }

    private func recordItem(value: String, unit: String, caption: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.2))
                }
            }
            Text(caption)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Milestones Timeline

    private func milestonesTimeline(_ milestones: [MilestoneProgress]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            label("next up")

            VStack(spacing: 0) {
                ForEach(Array(milestones.enumerated()), id: \.element.id) { index, m in
                    HStack(spacing: 14) {
                        // Dot + line
                        VStack(spacing: 0) {
                            Circle()
                                .fill(m.fraction >= 0.8
                                    ? Color.white
                                    : Color.white.opacity(0.15))
                                .frame(width: 6, height: 6)
                            if index < milestones.count - 1 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.06))
                                    .frame(width: 1)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 6)

                        // Content
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(m.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(m.description)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.2))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text(m.progressLabel)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(m.fraction >= 0.8 ? 0.6 : 0.25))
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
        }
    }

    // MARK: - Trophy Grid

    private var trophyGrid: some View {
        let unlocked = dataManager.unlockedAchievementIDs
        let all = AchievementCatalog.all

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                label("trophies")
                Spacer()
                Text("\(unlocked.count)/\(all.count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.15))
            }

            // Compact 6-column grid — icons only
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 14) {
                ForEach(all) { a in
                    let isUnlocked = unlocked.contains(a.id)
                    Image(systemName: a.icon)
                        .font(.system(size: 15))
                        .foregroundColor(isUnlocked ? .white : .white.opacity(0.06))
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(isUnlocked
                                    ? Color.white.opacity(0.08)
                                    : Color.white.opacity(0.02))
                        )
                }
            }
        }
    }

    // MARK: - History

    private func historyList(_ sessions: [BreathingSession]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            label("recent")

            ForEach(Array(sessions.enumerated()), id: \.offset) { index, session in
                HStack {
                    Text(session.exerciseType ?? "Session")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                        .lineLimit(1)
                    Spacer()
                    Text(timeAgo(session.date ?? Date()))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.15))
                    Text("+\(session.xpEarned)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.2))
                        .frame(width: 36, alignment: .trailing)
                }

                if index < sessions.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.03))
                        .frame(height: 1)
                }
            }
        }
    }

    // MARK: - Primitives

    private func label(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(2)
            .foregroundColor(.white.opacity(0.15))
    }

    // MARK: - Formatters

    private func shortDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return String(f.string(from: date).prefix(2)).uppercased()
    }

    private func formatMinutes(_ mins: Double) -> String {
        if mins >= 60 {
            return String(format: "%.0fh", mins / 60)
        }
        return "\(Int(mins))m"
    }

    private func formatDurationShort(_ seconds: Int) -> String {
        if seconds == 0 { return "\u{2014}" }
        let m = seconds / 60
        let s = seconds % 60
        if m > 0 { return "\(m):\(String(format: "%02d", s))" }
        return "\(s)s"
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        let days = seconds / 86400
        if days == 1 { return "yesterday" }
        if days < 7 { return "\(days)d ago" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

// MARK: - Reveal Modifier

private struct Reveal: ViewModifier {
    let appeared: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.4).delay(delay), value: appeared)
    }
}
