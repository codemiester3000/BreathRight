import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var geminiService = GeminiService()

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
                VStack(alignment: .leading, spacing: 0) {
                    // 1. Header
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

                        Text("Your Progress")
                            .font(.system(size: 20, weight: .light, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()

                        // Spacer for symmetry
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // 2. AI Coaching Insight
                    aiCoachingCard
                        .padding(.horizontal, 24)

                    // 3. Tier Progression (only if BOLT exists)
                    if let tier = dataManager.currentBOLTTier() {
                        NavigationLink(destination: TierDetailView(currentTier: tier)) {
                            tierProgressionCard(tier: tier)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }

                    // 4. Next Milestones
                    let milestones = AchievementCatalog.nextMilestones(
                        unlockedIDs: dataManager.unlockedAchievementIDs,
                        totalSessions: dataManager.totalSessions,
                        currentStreak: dataManager.currentStreak,
                        totalMinutes: dataManager.totalMinutes,
                        bestBOLT: dataManager.fetchBestBOLTScore(),
                        uniqueTypes: dataManager.uniqueExerciseTypes().count
                    )
                    if !milestones.isEmpty {
                        nextMilestonesCard(milestones: milestones)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                    }

                    // 5. Level card
                    levelCard
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // 6. Stats row
                    HStack(spacing: 12) {
                        statCard(
                            icon: "flame.fill",
                            iconColor: .orange,
                            value: "\(dataManager.currentStreak)",
                            label: "Day Streak"
                        )
                        statCard(
                            icon: "figure.mind.and.body",
                            iconColor: .homeWarmAccent,
                            value: "\(dataManager.totalSessions)",
                            label: "Total Sessions"
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // 7. Weekly activity
                    weeklyActivityView
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                    // 8. BOLT Score trend
                    boltTrendSection
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                    // 9. Personal bests
                    personalBestsCard
                        .padding(.horizontal, 24)
                        .padding(.top, 20)

                    // 10. Achievements
                    achievementsSection
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            geminiService.fetchInsight(dataManager: dataManager)
        }
    }

    // MARK: - AI Coaching Card

    private var aiCoachingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeGoldenAccent)
                    .frame(width: 12, height: 2)
                Text("ai coach")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Image(systemName: "sparkle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.homeGoldenAccent.opacity(0.6))
            }

            if geminiService.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(.white.opacity(0.5))
                        .scaleEffect(0.8)
                    Text("Analyzing your journey...")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.vertical, 8)
            } else {
                Text(geminiService.insightText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [Color.homeGoldenAccent.opacity(0.2), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }

    // MARK: - Tier Progression Card (Full Roadmap)

    private func tierProgressionCard(tier: BOLTTier) -> some View {
        let allTiers = BOLTTier.allCases
        let currentIndex = allTiers.firstIndex(of: tier) ?? 0

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeGoldenAccent)
                    .frame(width: 12, height: 2)
                Text("tier roadmap")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                HStack(spacing: 4) {
                    Text("Details")
                        .font(.system(size: 10, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.3))
            }

            // Full tier ladder
            VStack(spacing: 0) {
                ForEach(Array(allTiers.enumerated()), id: \.offset) { index, t in
                    let isCurrent = t == tier
                    let isPast = index < currentIndex
                    let isFuture = index > currentIndex

                    HStack(spacing: 14) {
                        // Vertical track + node
                        VStack(spacing: 0) {
                            // Connector above (hidden for first)
                            if index > 0 {
                                Rectangle()
                                    .fill(isPast || isCurrent
                                        ? Color.homeGoldenAccent.opacity(0.5)
                                        : Color.white.opacity(0.1))
                                    .frame(width: 2, height: 14)
                            } else {
                                Color.clear.frame(width: 2, height: 14)
                            }

                            // Node
                            ZStack {
                                if isCurrent {
                                    Circle()
                                        .fill(Color.homeGoldenAccent.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    Circle()
                                        .fill(Color.homeGoldenAccent)
                                        .frame(width: 14, height: 14)
                                    Circle()
                                        .stroke(Color.homeGoldenAccent.opacity(0.5), lineWidth: 1)
                                        .frame(width: 24, height: 24)
                                } else if isPast {
                                    Circle()
                                        .fill(Color.homeWarmAccent.opacity(0.6))
                                        .frame(width: 10, height: 10)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(width: 10, height: 10)
                                    Circle()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                                        .frame(width: 10, height: 10)
                                }
                            }

                            // Connector below (hidden for last)
                            if index < allTiers.count - 1 {
                                Rectangle()
                                    .fill(isPast
                                        ? Color.homeGoldenAccent.opacity(0.5)
                                        : Color.white.opacity(0.1))
                                    .frame(width: 2, height: 14)
                            } else {
                                Color.clear.frame(width: 2, height: 14)
                            }
                        }
                        .frame(width: 24)

                        // Tier info
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                Text(t.rawValue)
                                    .font(.system(size: isCurrent ? 15 : 13, weight: isCurrent ? .semibold : .medium, design: .rounded))
                                    .foregroundColor(isCurrent ? .homeGoldenAccent : isPast ? .white.opacity(0.7) : .white.opacity(0.35))

                                Text(t.boltRange)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(isCurrent ? .homeGoldenAccent.opacity(0.6) : .white.opacity(0.25))

                                if isCurrent {
                                    Spacer()
                                    Text("YOU")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(1)
                                        .foregroundColor(.homeWarmBlueDark)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.homeGoldenAccent)
                                        .clipShape(Capsule())
                                }
                            }

                            if isCurrent {
                                Text(t.benefitsDescription)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.5))
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 2)
                            }

                            if isCurrent, let next = t.nextTier {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 9, weight: .bold))
                                    Text("Next: \(next.benefitsDescription)")
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(.homeWarmAccent.opacity(0.7))
                                .padding(.top, 4)
                            }
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [Color.homeGoldenAccent.opacity(0.15), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }

    // MARK: - Next Milestones Card

    private func nextMilestonesCard(milestones: [MilestoneProgress]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeGoldenAccent)
                    .frame(width: 12, height: 2)
                Text("next milestones")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
            }

            ForEach(milestones) { milestone in
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 36, height: 36)
                            Image(systemName: milestone.icon)
                                .font(.system(size: 14))
                                .foregroundColor(.homeGoldenAccent.opacity(0.7))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(milestone.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Text(milestone.progressLabel)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            // Description — always visible
                            Text(milestone.description)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.white.opacity(0.4))

                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 5)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(
                                            LinearGradient(
                                                colors: [.homeWarmAccent, .homeGoldenAccent],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * CGFloat(min(milestone.fraction, 1.0)), height: 5)
                                }
                            }
                            .frame(height: 5)
                            .padding(.top, 2)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - Level Card

    private var levelCard: some View {
        VStack(spacing: 12) {
            let level = GamificationConstants.levelFor(xp: dataManager.currentXP)
            let progress = GamificationConstants.xpProgressInLevel(xp: dataManager.currentXP)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.name)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Level \(level.number)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.homeWarmAccent)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(dataManager.currentXP) XP")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.homeGoldenAccent)
                    if let next = GamificationConstants.nextLevel(after: level.number) {
                        Text("\(progress.current)/\(progress.needed) to \(next.name)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.homeWarmAccent, .homeGoldenAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(progress.fraction), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.homeWarmAccent.opacity(0.3), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }

    // MARK: - Stat Card

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - Weekly Activity

    private var weeklyActivityView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeWarmAccent)
                    .frame(width: 12, height: 2)
                Text("last 7 days")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
            }

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date())!
                    let hasSession = dataManager.sessionsOnDate(date)
                    let dayName = shortDayName(for: date)

                    VStack(spacing: 6) {
                        Circle()
                            .fill(hasSession ? Color.homeWarmAccent : Color.white.opacity(0.1))
                            .frame(width: 28, height: 28)
                            .overlay(
                                hasSession ?
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.homeWarmBlueDark) as? AnyView
                                    : nil
                            )
                        Text(dayName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private func shortDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).prefix(2).uppercased()
    }

    // MARK: - BOLT Score Trend

    private var boltTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeGoldenAccent)
                    .frame(width: 12, height: 2)
                Text("bolt score trend")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
            }

            let scores = dataManager.fetchBOLTScores()

            if scores.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "lungs")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.2))
                        Text("No BOLT tests yet")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.3))
                        Text("Take your first test from the home screen")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                BOLTChartView(scores: scores)
                    .frame(height: 150)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    // MARK: - Personal Bests

    private var personalBestsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeGoldenAccent)
                    .frame(width: 12, height: 2)
                Text("personal bests")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
            }

            HStack(spacing: 12) {
                bestCard(
                    icon: "clock",
                    label: "Longest Session",
                    value: formatDuration(dataManager.fetchLongestSession())
                )
                bestCard(
                    icon: "lungs",
                    label: "Best BOLT",
                    value: dataManager.fetchBestBOLTScore() > 0
                        ? String(format: "%.1fs", dataManager.fetchBestBOLTScore())
                        : "\u{2014}"
                )
                bestCard(
                    icon: "flame.fill",
                    label: "Best Streak",
                    value: "\(dataManager.longestStreak)d"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }

    private func bestCard(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.homeGoldenAccent.opacity(0.7))
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatDuration(_ seconds: Int) -> String {
        if seconds == 0 { return "\u{2014}" }
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeGoldenAccent)
                    .frame(width: 12, height: 2)
                Text("achievements")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("\(dataManager.unlockedAchievementIDs.count)/\(AchievementCatalog.all.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(AchievementCatalog.all) { achievement in
                    AchievementBadgeView(
                        achievement: achievement,
                        isUnlocked: dataManager.unlockedAchievementIDs.contains(achievement.id)
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}
