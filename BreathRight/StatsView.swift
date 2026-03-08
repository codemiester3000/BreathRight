import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var geminiService = GeminiService()
    var isTab: Bool = false

    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.homeWarmBlueDark, Color.homeWarmBlue, Color.homeWarmBlueLight]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    if isTab {
                        heroHeader
                            .padding(.top, 12)
                    } else {
                        navHeader
                            .padding(.top, 16)
                    }

                    // Stats row
                    statsRow
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .modifier(FadeSlide(appeared: appeared, delay: 0.05))

                    // Weekly pulse
                    weeklyPulse
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .modifier(FadeSlide(appeared: appeared, delay: 0.1))

                    // AI Coach
                    if dataManager.totalSessions >= 3 {
                        aiCard
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .modifier(FadeSlide(appeared: appeared, delay: 0.15))
                    }

                    // BOLT section
                    if dataManager.currentBOLTTier() != nil {
                        boltSection
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .modifier(FadeSlide(appeared: appeared, delay: 0.2))
                    }

                    // Personal records
                    if dataManager.totalSessions > 0 {
                        recordsSection
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .modifier(FadeSlide(appeared: appeared, delay: 0.25))
                    }

                    // Milestones
                    let milestones = AchievementCatalog.nextMilestones(
                        unlockedIDs: dataManager.unlockedAchievementIDs,
                        totalSessions: dataManager.totalSessions,
                        currentStreak: dataManager.currentStreak,
                        totalMinutes: dataManager.totalMinutes,
                        bestBOLT: dataManager.fetchBestBOLTScore(),
                        uniqueTypes: dataManager.uniqueExerciseTypes().count
                    )
                    if !milestones.isEmpty {
                        milestonesSection(milestones: milestones)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .modifier(FadeSlide(appeared: appeared, delay: 0.3))
                    }

                    // Achievements
                    achievementsGrid
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .modifier(FadeSlide(appeared: appeared, delay: 0.35))

                    Spacer().frame(height: isTab ? 100 : 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            geminiService.fetchInsight(dataManager: dataManager)
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        let level = GamificationConstants.levelFor(xp: dataManager.currentXP)
        let progress = GamificationConstants.xpProgressInLevel(xp: dataManager.currentXP)

        return VStack(spacing: 0) {
            // Level ring
            ZStack {
                // Track
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 6)
                    .frame(width: 100, height: 100)

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(progress.fraction))
                    .stroke(
                        LinearGradient(
                            colors: [.homeWarmAccent, .homeGoldenAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                // Level number inside
                VStack(spacing: 1) {
                    Text("\(level.number)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("LVL")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.35))
                }
            }
            .modifier(FadeSlide(appeared: appeared, delay: 0))

            Text(level.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 14)

            // XP + tier
            HStack(spacing: 8) {
                Text("\(dataManager.currentXP) XP")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.45))

                if let tier = dataManager.currentBOLTTier() {
                    Text("\u{00B7}")
                        .foregroundColor(.white.opacity(0.2))
                    Text(tier.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(.homeWarmBlueDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color.homeGoldenAccent)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 6)

            // XP to next
            if let next = GamificationConstants.nextLevel(after: level.number) {
                Text("\(progress.current)/\(progress.needed) to \(next.name)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Nav Header (non-tab)

    private var navHeader: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            Spacer()
            Text("Your Journey")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statPill(
                value: "\(dataManager.currentStreak)",
                label: "day streak",
                icon: "flame.fill",
                color: dataManager.currentStreak > 0 ? .orange : .white.opacity(0.3)
            )
            divider
            statPill(
                value: "\(dataManager.totalSessions)",
                label: "sessions",
                icon: "figure.mind.and.body",
                color: .homeWarmAccent
            )
            divider
            statPill(
                value: formatMinutes(dataManager.totalMinutes),
                label: "total time",
                icon: "clock",
                color: .homeWarmAccent
            )
            divider
            statPill(
                value: dataManager.fetchBestBOLTScore() > 0
                    ? String(format: "%.0fs", dataManager.fetchBestBOLTScore())
                    : "\u{2014}",
                label: "best BOLT",
                icon: "lungs",
                color: .homeGoldenAccent
            )
        }
        .padding(.vertical, 16)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(width: 1, height: 36)
    }

    private func statPill(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Pulse

    private var weeklyPulse: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("this week")

            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date())!
                    let hasSession = dataManager.sessionsOnDate(date)
                    let isToday = Calendar.current.isDateInToday(date)

                    VStack(spacing: 6) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                hasSession
                                    ? LinearGradient(colors: [.homeWarmAccent, .homeGoldenAccent], startPoint: .bottom, endPoint: .top)
                                    : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.06)], startPoint: .bottom, endPoint: .top)
                            )
                            .frame(height: hasSession ? 32 : 12)
                            .frame(maxWidth: .infinity)

                        // Day label
                        Text(shortDay(date))
                            .font(.system(size: 9, weight: isToday ? .bold : .medium))
                            .foregroundColor(isToday ? .white.opacity(0.8) : .white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 50, alignment: .bottom)
        }
        .padding(16)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - AI Card

    private var aiCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.homeGoldenAccent)
                Text("AI INSIGHT")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.4))
            }

            if geminiService.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white.opacity(0.4))
                        .scaleEffect(0.7)
                    Text("Thinking...")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                Text(geminiService.insightText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.homeGoldenAccent.opacity(0.2), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
    }

    // MARK: - BOLT Section

    private var boltSection: some View {
        let scores = dataManager.fetchBOLTScores()
        let tier = dataManager.currentBOLTTier()!
        let allTiers = BOLTTier.allCases
        let currentIndex = allTiers.firstIndex(of: tier) ?? 0

        return VStack(alignment: .leading, spacing: 14) {
            sectionHeader("bolt progress")

            // Tier ladder — horizontal compact
            HStack(spacing: 0) {
                ForEach(Array(allTiers.enumerated()), id: \.offset) { index, t in
                    let isCurrent = t == tier
                    let isPast = index < currentIndex

                    VStack(spacing: 6) {
                        // Node
                        ZStack {
                            if isCurrent {
                                Circle()
                                    .fill(Color.homeGoldenAccent)
                                    .frame(width: 12, height: 12)
                                Circle()
                                    .stroke(Color.homeGoldenAccent.opacity(0.4), lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            } else {
                                Circle()
                                    .fill(isPast ? Color.homeWarmAccent.opacity(0.7) : Color.white.opacity(0.1))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(height: 20)

                        Text(t == .roomToGrow ? "Start" : t == .veryGood ? "V.Good" : t.rawValue)
                            .font(.system(size: isCurrent ? 9 : 8, weight: isCurrent ? .bold : .medium))
                            .foregroundColor(isCurrent ? .homeGoldenAccent : isPast ? .white.opacity(0.5) : .white.opacity(0.2))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)

                    if index < allTiers.count - 1 {
                        Rectangle()
                            .fill(isPast ? Color.homeGoldenAccent.opacity(0.5) : Color.white.opacity(0.08))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                            .offset(y: -10)
                    }
                }
            }

            // Score + trend
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Latest")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.35))
                    Text(String(format: "%.1fs", dataManager.fetchLatestBOLTScore()))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                if !scores.isEmpty {
                    BOLTChartView(scores: scores)
                        .frame(height: 80)
                }
            }

            if let days = dataManager.daysSinceLastBOLTTest() {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 9))
                    Text("Tested \(days)d ago")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(days >= 7 ? .homeGoldenAccent : .white.opacity(0.35))
            }
        }
        .padding(16)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Personal Records

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("personal records")

            HStack(spacing: 10) {
                recordCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(dataManager.longestStreak)",
                    unit: "days",
                    label: "Best Streak"
                )
                recordCard(
                    icon: "clock.fill",
                    iconColor: .homeWarmAccent,
                    value: formatDuration(dataManager.fetchLongestSession()),
                    unit: "",
                    label: "Longest Session"
                )
                recordCard(
                    icon: "lungs.fill",
                    iconColor: .homeGoldenAccent,
                    value: dataManager.fetchBestBOLTScore() > 0
                        ? String(format: "%.0f", dataManager.fetchBestBOLTScore())
                        : "\u{2014}",
                    unit: dataManager.fetchBestBOLTScore() > 0 ? "sec" : "",
                    label: "Best BOLT"
                )
            }
        }
        .padding(16)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func recordCard(icon: String, iconColor: Color, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Milestones

    private func milestonesSection(milestones: [MilestoneProgress]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("next up")

            VStack(spacing: 10) {
                ForEach(milestones) { m in
                    HStack(spacing: 12) {
                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.06), lineWidth: 3)
                                .frame(width: 38, height: 38)
                            Circle()
                                .trim(from: 0, to: CGFloat(min(m.fraction, 1.0)))
                                .stroke(
                                    LinearGradient(colors: [.homeWarmAccent, .homeGoldenAccent], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .frame(width: 38, height: 38)
                                .rotationEffect(.degrees(-90))
                            Image(systemName: m.icon)
                                .font(.system(size: 13))
                                .foregroundColor(.homeGoldenAccent.opacity(0.8))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(m.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Text(m.progressLabel)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.homeGoldenAccent.opacity(0.8))
                            }
                            Text(m.description)
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.35))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Achievements Grid

    private var achievementsGrid: some View {
        let unlocked = dataManager.unlockedAchievementIDs
        let total = AchievementCatalog.all.count
        let unlockedCount = unlocked.count

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader("achievements")
                Spacer()
                Text("\(unlockedCount)/\(total)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.homeGoldenAccent.opacity(0.7))
            }

            // Grouped by category
            ForEach(AchievementDefinition.Category.allCases, id: \.rawValue) { category in
                let categoryAchievements = AchievementCatalog.all.filter { $0.category == category }
                let categoryUnlocked = categoryAchievements.filter { unlocked.contains($0.id) }.count

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(category.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("\(categoryUnlocked)/\(categoryAchievements.count)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 14) {
                        ForEach(categoryAchievements) { a in
                            let isUnlocked = unlocked.contains(a.id)
                            VStack(spacing: 5) {
                                ZStack {
                                    Circle()
                                        .fill(isUnlocked ? Color.homeGoldenAccent.opacity(0.12) : Color.white.opacity(0.03))
                                        .frame(width: 44, height: 44)
                                    if isUnlocked {
                                        Circle()
                                            .stroke(Color.homeGoldenAccent.opacity(0.4), lineWidth: 1.5)
                                            .frame(width: 44, height: 44)
                                    }
                                    Image(systemName: a.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(isUnlocked ? .homeGoldenAccent : .white.opacity(0.1))
                                }
                                Text(a.name)
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(isUnlocked ? .white.opacity(0.7) : .white.opacity(0.15))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .padding(.top, category == AchievementDefinition.Category.allCases.first ? 0 : 6)
            }
        }
        .padding(16)
        .background(glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Shared Components

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(1.5)
            .foregroundColor(.white.opacity(0.3))
    }

    private var glassCard: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
            )
    }

    // MARK: - Helpers

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

    private func formatDuration(_ seconds: Int) -> String {
        if seconds == 0 { return "\u{2014}" }
        let m = seconds / 60
        let s = seconds % 60
        if m > 0 { return "\(m):\(String(format: "%02d", s))" }
        return "\(s)s"
    }
}

// MARK: - Fade + Slide Animation Modifier

private struct FadeSlide: ViewModifier {
    let appeared: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.45).delay(delay), value: appeared)
    }
}
