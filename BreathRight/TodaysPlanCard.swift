import SwiftUI

// MARK: - Status Row (Greeting + Streak + Level)

struct StatusRow: View {
    @EnvironmentObject var dataManager: DataManager

    private var hour: Int {
        Calendar.current.component(.hour, from: Date())
    }

    private var greeting: String {
        switch hour {
        case 6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var iconName: String {
        switch hour {
        case 6..<12: return "sun.horizon.fill"
        case 12..<17: return "sun.max.fill"
        default: return "moon.stars.fill"
        }
    }

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 13))
                    .foregroundColor(.homeWarmAccent.opacity(0.8))
                Text(greeting)
                    .font(.system(size: 15, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: dataManager.currentStreak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 12))
                        .foregroundColor(dataManager.currentStreak > 0 ? .orange : .white.opacity(0.4))
                    Text("\(dataManager.currentStreak)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }

                Text("\u{00B7}")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.3))

                HStack(spacing: 4) {
                    let level = GamificationConstants.levelFor(xp: dataManager.currentXP)
                    Text("Lv.\(level.number)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.homeWarmAccent)
                    Text(level.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - Journey Card

struct JourneyCard: View {
    @EnvironmentObject var dataManager: DataManager

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
        NavigationLink(destination: StatsView()) {
            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("your journey")
                    .padding(.top, 18)
                    .padding(.horizontal, 20)

                // BOLT score + tier
                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("BOLT")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        Text(String(format: "%.1fs", latestScore))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(tier.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.homeGoldenAccent)
                        Text(tier.boltRange)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)

                // Progress bar within tier
                let progress = tierProgress(score: latestScore, tier: tier)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                    GeometryReader { geo in
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
                .frame(height: 6)
                .padding(.top, 12)
                .padding(.horizontal, 20)

                // Bottom: retest nudge + arrow
                HStack {
                    retestNudge
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.homeWarmAccent.opacity(0.15))
                            .frame(width: 28, height: 28)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.homeWarmAccent)
                    }
                }
                .padding(.top, 14)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(cardStroke)
            .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
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
                NavigationLink(destination: BOLTTestView()) {
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
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.homeGoldenAccent.opacity(0.5))
                    .frame(width: 3)
                    .padding(.vertical, 20)
                Spacer()
            }
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
    @ObservedObject var geminiService: GeminiService
    @State private var navigateToExercise = false

    private var tier: BOLTTier? {
        dataManager.currentBOLTTier()
    }

    private var exercise: PrescribedExercise? {
        guard let tier = tier else { return nil }
        return TrainingPlanProvider.todaysExercise(for: tier)
    }

    var body: some View {
        if let exercise = exercise {
            VStack(alignment: .leading, spacing: 0) {
                // Section label
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.homeGoldenAccent.opacity(0.85))
                        .frame(width: 12, height: 2)
                    Text("your coach")
                        .font(.system(size: 11, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 18)
                .padding(.horizontal, 20)

                // AI Coach message — the warm, personal lead
                aiCoachSection
                    .padding(.top, 12)
                    .padding(.horizontal, 20)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                // Tier badge + day context + exercise details
                HStack(spacing: 8) {
                    if let tier = tier {
                        Text(tier.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.homeWarmBlueDark)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.homeGoldenAccent)
                            .clipShape(Capsule())
                    }

                    Text(TrainingPlanProvider.todayLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))

                    Spacer()

                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 9, weight: .medium))
                        Text("~\(exercise.estimatedDurationLabel)")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)

                // Exercise name + timing + cycles
                HStack(spacing: 6) {
                    Text(exercise.displayName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                    Spacer()
                    Text("\(exercise.timingLabel) \u{00B7} \(exercise.cycles) cycles")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 8)
                .padding(.horizontal, 20)

                // Start button — full width
                Button {
                    exercise.applyToUserDefaults()
                    navigateToExercise = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Begin Session")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.homeWarmBlueDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.homeGoldenAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Color.homeGoldenAccent.opacity(0.25), radius: 10, y: 4)
                }
                .padding(.top, 14)
                .padding(.horizontal, 20)
                .padding(.bottom, 18)

                // Hidden NavigationLink for programmatic navigation
                NavigationLink(
                    destination: exerciseDestination(for: exercise.exerciseType),
                    isActive: $navigateToExercise
                ) {
                    EmptyView()
                }
                .hidden()
                .frame(width: 0, height: 0)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.homeGoldenAccent.opacity(0.5))
                            .frame(width: 3)
                            .padding(.vertical, 20)
                        Spacer()
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.homeGoldenAccent.opacity(0.3), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        }
    }

    // MARK: - AI Coach Section

    @ViewBuilder
    private var aiCoachSection: some View {
        HStack(alignment: .top, spacing: 10) {
            // Sparkle icon
            ZStack {
                Circle()
                    .fill(Color.homeGoldenAccent.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: "sparkle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.homeGoldenAccent)
            }

            if geminiService.isLoadingTip {
                VStack(alignment: .leading, spacing: 6) {
                    // Shimmer placeholder lines
                    ForEach(0..<2, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 12)
                            .frame(maxWidth: i == 1 ? 180 : .infinity)
                    }
                }
                .padding(.top, 4)
            } else if !geminiService.exerciseTipText.isEmpty {
                Text(geminiService.exerciseTipText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func exerciseDestination(for exercise: BreathingExercise) -> some View {
        switch exercise {
        case .boxBreathing:
            BoxBreathingView()
        case .fourSevenEight:
            FourSevenEightBreathingView()
        case .custom:
            CustomBreathingView()
        }
    }
}
