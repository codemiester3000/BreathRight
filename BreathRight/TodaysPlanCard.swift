import SwiftUI

// MARK: - Hero Greeting Section

struct StatusRow: View {
    @EnvironmentObject var dataManager: DataManager

    private var hour: Int {
        Calendar.current.component(.hour, from: Date())
    }

    private var timeGreeting: String {
        switch hour {
        case 6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var greeting: String {
        if dataManager.totalSessions == 0 {
            return timeGreeting
        }
        if dataManager.todayProtocolCompleted {
            return "Nice Work Today"
        }
        let streak = dataManager.currentStreak
        let approachingMilestones = [6, 13, 29, 59, 99]
        if approachingMilestones.contains(streak) {
            return "Day \(streak) · Almost There"
        }
        if streak == 0 {
            return "Welcome Back"
        }
        if streak > 0 {
            return "Day \(streak)"
        }
        return timeGreeting
    }

    private var iconName: String {
        switch hour {
        case 6..<12: return "sun.horizon.fill"
        case 12..<17: return "sun.max.fill"
        default: return "moon.stars.fill"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Large greeting headline
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.homeGoldenAccent.opacity(0.9))
                    Text(greeting)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            // Streak + Level badges
            HStack(spacing: 12) {
                // Streak badge
                HStack(spacing: 6) {
                    Image(systemName: dataManager.currentStreak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 14))
                        .foregroundColor(dataManager.currentStreak > 0 ? .orange : .white.opacity(0.4))
                    Text("\(dataManager.currentStreak)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("streak")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            dataManager.currentStreak > 0
                                ? Color.orange.opacity(0.3)
                                : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
                .shadow(color: dataManager.currentStreak > 0 ? .orange.opacity(0.15) : .clear, radius: 8, y: 2)

                // Level badge
                HStack(spacing: 6) {
                    let level = GamificationConstants.levelFor(xp: dataManager.currentXP)
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(.homeGoldenAccent)
                    Text("Lv.\(level.number)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(level.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.homeGoldenAccent.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .homeGoldenAccent.opacity(0.1), radius: 8, y: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Journey Card

struct JourneyCard: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var tabBarState: TabBarState

    private var tier: BOLTTier? {
        dataManager.currentBOLTTier()
    }

    private var latestScore: Double {
        dataManager.fetchLatestBOLTScore()
    }

    var body: some View {
        if let tier = tier {
            hasBOLTCard(tier: tier)
        } else {
            noBOLTCard
        }
    }

    // MARK: - Has BOLT Score

    private func hasBOLTCard(tier: BOLTTier) -> some View {
        let progress = tierProgress(score: latestScore, tier: tier)

        return HStack(spacing: 14) {
            // BOLT score
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("BOLT")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                    Text(String(format: "%.1fs", latestScore))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text(tier.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.homeGoldenAccent)
            }

            // Progress bar
            VStack(alignment: .trailing, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.homeWarmAccent, .homeGoldenAccent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(progress))
                    }
                }
                .frame(height: 5)

                HStack {
                    retestNudge
                    Spacer()
                    if let nextTier = tier.nextTier {
                        let threshold: Double = {
                            switch nextTier {
                            case .developing: return 10
                            case .good: return 20
                            case .veryGood: return 30
                            case .elite: return 40
                            default: return 0
                            }
                        }()
                        let delta = threshold - latestScore
                        Text(String(format: "%.1fs to %@", delta, nextTier.rawValue))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    } else {
                        Text("Top tier")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.homeGoldenAccent.opacity(0.7))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(cardStroke)
        .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
    }

    // MARK: - No BOLT Score

    private var noBOLTCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("your journey")
                .padding(.top, 18)
                .padding(.horizontal, 20)

            Text("Unlock Your Training Plan")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white.opacity(0.95))
                .padding(.top, 12)
                .padding(.horizontal, 20)

            Text("Take a BOLT test to measure your breath hold and get personalized daily exercises.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.55))
                .lineSpacing(3)
                .padding(.top, 8)
                .padding(.horizontal, 20)

            HStack {
                Spacer()
                NavigationLink(destination: BOLTTestView()
                    .onAppear { tabBarState.isVisible = false }
                    .onDisappear { tabBarState.isVisible = true }
                ) {
                    HStack(spacing: 6) {
                        Text("Take BOLT Test")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.homeWarmBlueDark)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.homeGoldenAccent)
                    .clipShape(Capsule())
                    .shadow(color: Color.homeGoldenAccent.opacity(0.3), radius: 8, y: 2)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(cardStroke)
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }

    // MARK: - Helpers

    private var retestNudge: some View {
        Group {
            if let days = dataManager.daysSinceLastBOLTTest() {
                let highlight = days >= 7
                HStack(spacing: 5) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 10, weight: .medium))
                    Text("Retest")
                        .font(.system(size: 11, weight: .medium))
                    Text("\u{00B7}")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                    Text("tested \(days)d ago")
                        .font(.system(size: 11, weight: .regular))
                }
                .foregroundColor(highlight ? .homeGoldenAccent : .white.opacity(0.45))
            }
        }
    }

    private func tierProgress(score: Double, tier: BOLTTier) -> Double {
        switch tier {
        case .roomToGrow: return min(max(score / 10.0, 0), 1.0)
        case .developing: return min(max((score - 10) / 10.0, 0), 1.0)
        case .good: return min(max((score - 20) / 10.0, 0), 1.0)
        case .veryGood: return min(max((score - 30) / 10.0, 0), 1.0)
        case .elite: return 1.0
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.homeGoldenAccent.opacity(0.85))
                .frame(width: 12, height: 2)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.5))
        }
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    private var cardStroke: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                LinearGradient(
                    colors: [Color.homeGoldenAccent.opacity(0.3), Color.white.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

// MARK: - Today's Exercise Card

struct TodaysExerciseCard: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var tabBarState: TabBarState
    @ObservedObject var geminiService: GeminiService
    @State private var navigateToExercise = false
    @State private var bonusExercise: PrescribedExercise? = nil

    private var tier: BOLTTier? {
        dataManager.currentBOLTTier()
    }

    private var exercise: PrescribedExercise? {
        guard let tier = tier else { return nil }
        return TrainingPlanProvider.todaysExercise(for: tier)
    }

    private var isCompleted: Bool {
        dataManager.todayProtocolCompleted
    }

    var body: some View {
        if let exercise = exercise {
            if isCompleted {
                completedCard(exercise: exercise)
            } else {
                activeCard(exercise: exercise)
            }
        }
    }

    // MARK: - Active (not yet completed) card

    private func activeCard(exercise: PrescribedExercise) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section label
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.homeGoldenAccent.opacity(0.85))
                    .frame(width: 16, height: 2)
                Text("today's protocol")
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            // Day label
            if let tier = tier {
                Text("\(TrainingPlanProvider.todayLabel) \u{00B7} \(TrainingPlanProvider.todaysDayLabel(for: tier))")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1.2)
                    .foregroundColor(.white.opacity(0.35))
                    .textCase(.uppercase)
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
            }

            // Exercise name
            Text(exercise.displayName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 6)
                .padding(.horizontal, 20)

            // Benefit tag + duration
            HStack(spacing: 6) {
                Text(exercise.benefitTag)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.homeGoldenAccent.opacity(0.9))
                Text("\u{00B7}")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
                Text("~\(exercise.estimatedDurationLabel)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.top, 4)
            .padding(.horizontal, 20)

            // Science line
            Text(exercise.scienceLine)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .lineSpacing(3)
                .padding(.top, 12)
                .padding(.horizontal, 20)

            // Begin Session CTA
            Button {
                exercise.applyToUserDefaults()
                geminiService.showExerciseTip = true
                navigateToExercise = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text("Begin Session")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.homeWarmBlueDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.homeGoldenAccent, Color.homeGoldenAccent.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.homeGoldenAccent.opacity(0.35), radius: 12, y: 4)
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)

            // Technical details
            Text("\(exercise.timingLabel) \u{00B7} \(exercise.cycles) cycles")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 8)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            // Hidden NavigationLink
            NavigationLink(
                destination: exerciseDestination(for: bonusExercise?.exerciseType ?? exercise.exerciseType),
                isActive: $navigateToExercise
            ) { EmptyView() }
            .hidden()
            .frame(width: 0, height: 0)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RadialGradient(
                    colors: [Color.homeGoldenAccent.opacity(0.08), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 150
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.homeGoldenAccent.opacity(0.35), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }

    // MARK: - Completed card — celebration + bonus exercise offer

    private func completedCard(exercise: PrescribedExercise) -> some View {
        VStack(spacing: 0) {
            // Completed header
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.green)
                }

                Text("Today's Protocol Done")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text("\(exercise.displayName) \u{00B7} \(exercise.timingLabel)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Bonus exercise section
            if let tier = tier {
                let bonus = bonusExercise ?? TrainingPlanProvider.bonusExercise(for: tier)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.homeWarmAccent.opacity(0.7))
                            .frame(width: 12, height: 2)
                        Text("bonus round")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 16)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bonus.displayName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            HStack(spacing: 6) {
                                Text(bonus.benefitTag)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.homeWarmAccent.opacity(0.8))
                                Text("\u{00B7}")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.2))
                                Text("~\(bonus.estimatedDurationLabel)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        Spacer()
                        Button {
                            bonus.applyToUserDefaults()
                            bonusExercise = bonus
                            geminiService.showExerciseTip = true
                            navigateToExercise = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 9, weight: .bold))
                                Text("Go")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.homeWarmBlueDark)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(Color.homeWarmAccent)
                            .clipShape(Capsule())
                            .shadow(color: Color.homeWarmAccent.opacity(0.25), radius: 6, y: 2)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Hidden NavigationLink
            NavigationLink(
                destination: exerciseDestination(for: bonusExercise?.exerciseType ?? exercise.exerciseType),
                isActive: $navigateToExercise
            ) { EmptyView() }
            .hidden()
            .frame(width: 0, height: 0)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                // Green success glow
                RadialGradient(
                    colors: [Color.green.opacity(0.06), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 120
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.green.opacity(0.25), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }

    @ViewBuilder
    private func exerciseDestination(for exercise: BreathingExercise) -> some View {
        Group {
            switch exercise {
            case .boxBreathing:
                BoxBreathingView().environmentObject(geminiService)
            case .fourSevenEight:
                FourSevenEightBreathingView().environmentObject(geminiService)
            case .exhaleHold:
                ExhaleHoldView().environmentObject(geminiService)
            case .custom:
                CustomBreathingView().environmentObject(geminiService)
            }
        }
        .onAppear { tabBarState.isVisible = false }
        .onDisappear { tabBarState.isVisible = true }
    }
}
