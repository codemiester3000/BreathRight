import SwiftUI

struct TierDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode

    let currentTier: BOLTTier

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
                    // Header
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

                        Text("Tier Roadmap")
                            .font(.system(size: 20, weight: .light, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()

                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    // Current score context
                    let latestScore = dataManager.fetchLatestBOLTScore()
                    if latestScore > 0 {
                        HStack(spacing: 6) {
                            Text("Your BOLT:")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.5))
                            Text(String(format: "%.1fs", latestScore))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.homeGoldenAccent)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 20)
                    }

                    // Tier cards
                    let allTiers = BOLTTier.allCases
                    let currentIndex = allTiers.firstIndex(of: currentTier) ?? 0

                    ForEach(Array(allTiers.enumerated()), id: \.offset) { index, tier in
                        let isCurrent = tier == currentTier
                        let isPast = index < currentIndex

                        tierDetailCard(
                            tier: tier,
                            isCurrent: isCurrent,
                            isPast: isPast,
                            isLast: index == allTiers.count - 1
                        )
                        .padding(.horizontal, 24)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Tier Detail Card

    private func tierDetailCard(tier: BOLTTier, isCurrent: Bool, isPast: Bool, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Connection line from above
            if tier != BOLTTier.allCases.first {
                HStack {
                    Rectangle()
                        .fill(isPast || isCurrent ? Color.homeGoldenAccent.opacity(0.4) : Color.white.opacity(0.08))
                        .frame(width: 2, height: 20)
                        .padding(.leading, 17)
                    Spacer()
                }
            }

            // Card content
            VStack(alignment: .leading, spacing: 14) {
                // Header row: node + name + range + badge
                HStack(spacing: 14) {
                    // Node
                    ZStack {
                        if isCurrent {
                            Circle()
                                .fill(Color.homeGoldenAccent.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Circle()
                                .fill(Color.homeGoldenAccent)
                                .frame(width: 20, height: 20)
                            Circle()
                                .stroke(Color.homeGoldenAccent.opacity(0.5), lineWidth: 1.5)
                                .frame(width: 36, height: 36)
                        } else if isPast {
                            Circle()
                                .fill(Color.homeWarmAccent.opacity(0.5))
                                .frame(width: 20, height: 20)
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 20, height: 20)
                            Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tier.rawValue)
                            .font(.system(size: isCurrent ? 18 : 16, weight: isCurrent ? .semibold : .medium, design: .rounded))
                            .foregroundColor(isCurrent ? .homeGoldenAccent : isPast ? .white.opacity(0.8) : .white.opacity(0.4))
                        Text("BOLT \(tier.boltRange)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(isCurrent ? .homeGoldenAccent.opacity(0.6) : .white.opacity(0.3))
                    }

                    Spacer()

                    if isCurrent {
                        Text("CURRENT")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.homeWarmBlueDark)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.homeGoldenAccent)
                            .clipShape(Capsule())
                    } else if isPast {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.homeWarmAccent.opacity(0.5))
                    }
                }

                // Benefits
                Text(tier.benefitsDescription)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(isCurrent ? .white.opacity(0.7) : .white.opacity(0.4))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                // Sample exercises for this tier
                let exercises = TrainingPlanProvider.exercises(for: tier)
                let sampleExercises = Array(Set(exercises.map { exerciseSummary($0) })).sorted().prefix(3)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Sample exercises")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.3))

                    ForEach(Array(sampleExercises), id: \.self) { summary in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(isCurrent ? Color.homeGoldenAccent.opacity(0.5) : Color.white.opacity(0.15))
                                .frame(width: 4, height: 4)
                            Text(summary)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(isCurrent ? .white.opacity(0.6) : .white.opacity(0.35))
                        }
                    }
                }
                .padding(.top, 2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isCurrent ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isCurrent
                            ? LinearGradient(
                                colors: [Color.homeGoldenAccent.opacity(0.3), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.06), Color.white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ),
                        lineWidth: isCurrent ? 1 : 0.5
                    )
            )

            // Connection line below
            if !isLast {
                HStack {
                    Rectangle()
                        .fill(isPast ? Color.homeGoldenAccent.opacity(0.4) : Color.white.opacity(0.08))
                        .frame(width: 2, height: 20)
                        .padding(.leading, 17)
                    Spacer()
                }
            }
        }
    }

    private func exerciseSummary(_ exercise: PrescribedExercise) -> String {
        "\(exercise.displayName) \(exercise.timingLabel) \u{00D7} \(exercise.cycles) cycles"
    }
}
