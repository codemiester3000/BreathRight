import SwiftUI

struct Summary: View {
    let elapsedTime: Int
    var exerciseType: String = "Box Breathing"
    var cyclesCompleted: Int = 0

    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode

    // Animation states
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var xpCountUp: Int = 0
    @State private var showLevelUp = false
    @State private var hasSaved = false

    private var exerciseInsight: String {
        switch exerciseType {
        case "Box Breathing":
            return "Even-ratio breathing trains your autonomic nervous system to find balance. Consistency here lowers your resting breath rate."
        case "4-7-8 Breathing":
            return "The extended exhale activates your vagus nerve. The 7-second hold is where your CO\u{2082} tolerance grows."
        case "Exhale Hold":
            return "Exhale holds are the core Buteyko exercise — they directly train what your BOLT score measures. Each session raises your CO\u{2082} threshold."
        case "Custom Breathing":
            return "Custom patterns let you target exactly where your breathing needs work. The hold phase is where CO\u{2082} tolerance builds."
        default:
            return "Every session strengthens your breathing practice."
        }
    }

    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return "\(minutes) min \(seconds) sec"
    }

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
                    Spacer().frame(height: 60)

                    // Success icon
                    ZStack {
                        Circle()
                            .stroke(Color.homeWarmAccent.opacity(0.3), lineWidth: 1)
                            .frame(width: 130, height: 130)
                            .scaleEffect(pulseScale)
                            .opacity(2 - Double(pulseScale))

                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .scaleEffect(ringScale)
                            .opacity(ringOpacity)

                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.homeWarmAccent.opacity(0.25), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(ringScale)
                            .opacity(ringOpacity)

                        Image(systemName: "checkmark")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(.white.opacity(0.95))
                            .scaleEffect(checkmarkScale)
                            .opacity(checkmarkOpacity)
                    }
                    .padding(.bottom, 28)

                    // Title
                    Text("Session Complete")
                        .font(.system(size: 26, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)

                    // Subtitle — exercise type name
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.homeWarmAccent.opacity(0.7))
                            .frame(width: 12, height: 2)
                        Text(exerciseType)
                            .font(.system(size: 12, weight: .medium))
                            .tracking(0.5)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 28)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                    // Personal best banner
                    if dataManager.isPersonalBest && elapsedTime > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.homeGoldenAccent)
                            Text("New Personal Best!")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.homeGoldenAccent)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.homeGoldenAccent.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.homeGoldenAccent.opacity(0.3), lineWidth: 0.5)
                        )
                        .padding(.bottom, 20)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    }

                    // Stats card
                    VStack(spacing: 14) {
                        // Duration
                        statsRow(icon: "clock", label: "Duration", value: formattedTime)

                        if cyclesCompleted > 0 {
                            Divider().background(Color.white.opacity(0.1))
                            statsRow(icon: "arrow.2.squarepath", label: "Cycles", value: "\(cyclesCompleted)")
                        }

                        Divider().background(Color.white.opacity(0.1))

                        // XP earned
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.homeGoldenAccent.opacity(0.8))
                                Text("XP Earned")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            Text("+\(xpCountUp)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.homeGoldenAccent)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .padding(.horizontal, 32)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                    // Exercise-specific physiological message
                    Text(exerciseInsight)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .padding(.top, 16)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)

                    // Tomorrow's exercise preview
                    if let tier = dataManager.currentBOLTTier() {
                        let tomorrow = TrainingPlanProvider.tomorrowsExercise(for: tier)
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.homeWarmAccent.opacity(0.6))
                            Text("Tomorrow: \(tomorrow.displayName) \u{00B7} \(tomorrow.timingLabel) \u{00B7} ~\(tomorrow.estimatedDurationLabel)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.04))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    }

                    // Streak + Level row
                    HStack(spacing: 12) {
                        // Streak card
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                                Text("\(dataManager.currentStreak)")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Text("day streak")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        )

                        // Level card
                        VStack(spacing: 6) {
                            let level = GamificationConstants.levelFor(xp: dataManager.currentXP)
                            Text(level.name)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.homeWarmAccent)
                            let progress = GamificationConstants.xpProgressInLevel(xp: dataManager.currentXP)
                            // XP progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(
                                            LinearGradient(
                                                colors: [.homeWarmAccent, .homeGoldenAccent],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * CGFloat(progress.fraction), height: 6)
                                }
                            }
                            .frame(height: 6)
                            .padding(.horizontal, 12)

                            Text("Level \(level.number)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        )
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                    // New achievements
                    if !dataManager.newlyUnlockedAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Rectangle()
                                    .fill(Color.homeGoldenAccent)
                                    .frame(width: 12, height: 2)
                                Text("new badges unlocked")
                                    .font(.system(size: 11, weight: .medium))
                                    .tracking(1.5)
                                    .foregroundColor(.white.opacity(0.5))
                            }

                            ForEach(dataManager.newlyUnlockedAchievements) { achievement in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.homeGoldenAccent.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: achievement.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(.homeGoldenAccent)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(achievement.name)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        Text(achievement.description)
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    }

                    Spacer().frame(height: 30)

                    // Done button
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Text("Done")
                                .font(.system(size: 15, weight: .medium))
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.homeWarmAccent)
                        }
                        .foregroundColor(.white.opacity(0.95))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    .opacity(contentOpacity)
                }
            }

            // Level up overlay
            if showLevelUp {
                LevelUpView(levelName: dataManager.newLevelName) {
                    showLevelUp = false
                }
            }
        }
        .onAppear {
            if !hasSaved {
                hasSaved = true
                dataManager.saveSession(
                    exerciseType: exerciseType,
                    durationSeconds: elapsedTime,
                    cyclesCompleted: cyclesCompleted
                )
                startCompletionAnimation()
            }
        }
    }

    private func statsRow(icon: String, label: String, value: String) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(.homeWarmAccent.opacity(0.8))
                Text(label)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
    }

    private func startCompletionAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
            checkmarkScale = 1.0
            checkmarkOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.3)) {
            pulseScale = 1.8
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            contentOpacity = 1.0
            contentOffset = 0
        }

        // XP count-up animation
        let targetXP = dataManager.lastSessionXP
        if targetXP > 0 {
            let steps = min(targetXP, 30)
            let interval = 0.8 / Double(steps)
            for i in 1...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(i) * interval) {
                    xpCountUp = targetXP * i / steps
                }
            }
        }

        // Level up trigger
        if dataManager.didLevelUp {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                showLevelUp = true
            }
        }
    }
}

struct DrawingSquareModifier: AnimatableModifier {
    var progress: CGFloat
    let size: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.overlay(
            Path { path in
                let start = CGPoint(x: 0, y: 0)
                path.move(to: start)

                let points = [
                    CGPoint(x: size, y: 0),
                    CGPoint(x: size, y: size),
                    CGPoint(x: 0, y: size),
                    CGPoint(x: 0, y: 0)
                ]

                let currentSide = Int(progress)
                let sideProgress = progress - CGFloat(currentSide)

                for i in 0..<points.count {
                    if i < currentSide {
                        path.addLine(to: points[i])
                    } else if i == currentSide {
                        let interpolation = interpolate(from: path.currentPoint!, to: points[i], progress: sideProgress)
                        path.addLine(to: interpolation)
                        break
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        )
    }

    private func interpolate(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: from.x + (to.x - from.x) * progress,
            y: from.y + (to.y - from.y) * progress
        )
    }
}

struct AnimatedSquareView: View {
    var size: CGFloat
    @State private var drawProgress: CGFloat = 0

    var body: some View {
        Rectangle()
            .background(.clear)
            .foregroundColor(.clear)
            .frame(width: size, height: size)
            .modifier(DrawingSquareModifier(progress: drawProgress, size: size))
            .onAppear {
                withAnimation(Animation.linear(duration: 4).repeatCount(1)) {
                    drawProgress = 4
                }
            }
    }
}
