import SwiftUI

// Warm blue color palette for home screen (matching splash)
extension Color {
    static let homeWarmBlue = Color(red: 0.2, green: 0.45, blue: 0.65)
    static let homeWarmBlueLight = Color(red: 0.35, green: 0.55, blue: 0.75)
    static let homeWarmBlueDark = Color(red: 0.12, green: 0.3, blue: 0.5)
    static let homeWarmAccent = Color(red: 0.4, green: 0.7, blue: 0.85)
    // Warm golden accent for contrast
    static let homeGoldenAccent = Color(red: 0.95, green: 0.75, blue: 0.4)
}

// Enum for breathing exercises
enum BreathingExercise: String, CaseIterable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
    case exhaleHold = "Exhale Hold"
    case custom = "Custom Breathing"

    var benefits: [String] {
        switch self {
        case .boxBreathing:
            return ["Reduces stress", "Improves concentration", "Enhances relaxation"]
        case .fourSevenEight:
            return ["Improves sleep", "Manages cravings", "Reduces stress"]
        case .exhaleHold:
            return ["Builds CO\u{2082} tolerance", "Trains what BOLT measures", "Buteyko core exercise"]
        case .custom:
            return ["Personalized rhythm", "Flexible durations", "Your own pace"]
        }
    }

    var cyclesKey: String {
        switch self {
        case .boxBreathing: return "numCycles_boxBreathing"
        case .fourSevenEight: return "numCycles_fourSevenEight"
        case .exhaleHold: return "numCycles_exhaleHold"
        case .custom: return "numCycles_custom"
        }
    }

    var unlimitedKey: String {
        switch self {
        case .boxBreathing: return "unlimitedCycles_boxBreathing"
        case .fourSevenEight: return "unlimitedCycles_fourSevenEight"
        case .exhaleHold: return "unlimitedCycles_exhaleHold"
        case .custom: return "unlimitedCycles_custom"
        }
    }

    func savedCycles() -> Int {
        let val = UserDefaults.standard.integer(forKey: cyclesKey)
        return val != 0 ? val : UserDefaults.standard.integer(forKey: "numCycles").nonZero ?? 10
    }

    func savedIsUnlimited() -> Bool {
        return UserDefaults.standard.bool(forKey: unlimitedKey)
    }

    func timeForOneCycle() -> Int {
        switch self {
        case .boxBreathing:
            return 4 + 4 + 4 + 4
        case .fourSevenEight:
            return 4 + 7 + 8
        case .exhaleHold:
            let inhale = UserDefaults.standard.integer(forKey: "customInhale")
            let exhale = UserDefaults.standard.integer(forKey: "customExhale")
            let hold = UserDefaults.standard.integer(forKey: "customHold")
            let recovery = UserDefaults.standard.integer(forKey: "customRecovery")
            return (inhale > 0 ? inhale : 4) + (exhale > 0 ? exhale : 4) + (hold > 0 ? hold : 5) + (recovery > 0 ? recovery : 20)
        case .custom:
            let inhale = UserDefaults.standard.integer(forKey: "customInhale")
            let hold = UserDefaults.standard.integer(forKey: "customHold")
            let exhale = UserDefaults.standard.integer(forKey: "customExhale")
            return (inhale > 0 ? inhale : 4) + (hold > 0 ? hold : 4) + (exhale > 0 ? exhale : 4)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var tabBarState: TabBarState
    @StateObject private var geminiService = GeminiService()

    @State private var sublineOpacity: Double = 0
    @State private var waveBreathScale: CGFloat = 1.0
    @State private var showStreakMilestone = false
    @State private var ambientGlow: CGFloat = 0.6
    @State private var contentAppeared = false

    private static let motivationalLines = [
        "Your nervous system adapts with every session.",
        "Breathe less. Breathe slower. Breathe through your nose.",
        "CO\u{2082} tolerance is trainable. You're training it.",
        "The urge to breathe passes. That's where growth happens.",
        "Lower breath rate, higher HRV. That's the trade.",
        "Your chemoreceptors adapt to what you practice daily.",
        "Nasal breathing filters, warms, and humidifies every breath.",
        "Slow breathing shifts your autonomic balance toward rest.",
        "Each hold recalibrates your brainstem's CO\u{2082} set-point.",
        "Breath control is nervous system control.",
        "Consistency beats intensity. Show up daily.",
        "Your BOLT score reflects real physiological change.",
        "Extended exhales activate the vagus nerve directly.",
        "The diaphragm is a muscle. Train it like one.",
        "Functional breathing is the foundation of performance."
    ]

    private var dailyMotivation: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return Self.motivationalLines[day % Self.motivationalLines.count]
    }

    var body: some View {
        ZStack {
            // Warm gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.homeWarmBlueDark, Color.homeWarmBlue, Color.homeWarmBlueLight]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // Ambient glow orb — warm light source behind waves
            RadialGradient(
                colors: [
                    Color.homeWarmAccent.opacity(0.18 * ambientGlow),
                    Color.homeGoldenAccent.opacity(0.08 * ambientGlow),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.08),
                startRadius: 20,
                endRadius: 250
            )
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(false)

            // Floating particles
            FloatingParticles()
                .allowsHitTesting(false)

            // Main content - scrollable
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Wave animation at top
                    ZStack {
                        CosineAnimation(amplitudeScale: 0.9, speed: 7, strokeOpacity: 0.35)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .frame(height: 60)
                            .offset(y: -5)
                        CosineAnimation(amplitudeScale: 1.0, speed: 8, strokeOpacity: 0.5, strokeColor: .homeWarmAccent)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .frame(height: 60)
                            .offset(y: 12)
                        CosineAnimation(amplitudeScale: 0.7, speed: 10, strokeOpacity: 0.2, strokeColor: .homeGoldenAccent)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .frame(height: 55)
                            .offset(y: 28)
                        CosineAnimation(amplitudeScale: 0.8, speed: 9.5, strokeOpacity: 0.25)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .frame(height: 55)
                            .offset(y: 38)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .padding(.top, -15)
                    .padding(.bottom, 10)
                    .opacity(0.8)
                    .scaleEffect(y: waveBreathScale)

                    // Hero greeting section
                    StatusRow()
                    .opacity(contentAppeared ? 1.0 : 0.0)
                    .offset(y: contentAppeared ? 0 : 15)

                    // Motivational subline — centered
                    Text(dailyMotivation)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.horizontal, 20)
                        .opacity(sublineOpacity)

                    // Journey Card (BOLT progress or onboarding)
                    JourneyCard()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.90)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                        .opacity(contentAppeared ? 1.0 : 0.0)
                        .offset(y: contentAppeared ? 0 : 20)

                    // Today's Exercise with integrated AI coach
                    TodaysExerciseCard(geminiService: geminiService)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.90)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .opacity(contentAppeared ? 1.0 : 0.0)
                        .offset(y: contentAppeared ? 0 : 20)

                    // Exercises section
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.homeWarmAccent)
                            .frame(width: 16, height: 2)
                        Text("exercises")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.5))
                        Text("\u{00B7}")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.2))
                        Text("choose a technique")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 12)

                    VStack(spacing: 10) {
                        ForEach(BreathingExercise.allCases, id: \.self) { exercise in
                            NavigationLink(destination: destinationView(for: exercise).onAppear { geminiService.showExerciseTip = false }) {
                                ExerciseCard(exercise: exercise)
                            }
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.90)
                    .frame(maxWidth: .infinity, alignment: .center)

                    // BOLT test
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.homeGoldenAccent.opacity(0.7))
                            .frame(width: 16, height: 2)
                        Text("measure")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 10)

                    NavigationLink(destination: BOLTTestView()
                        .onAppear { tabBarState.isVisible = false }
                        .onDisappear { tabBarState.isVisible = true }
                    ) {
                        BOLTTestCard()
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.90)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 24)
            }
        }
        .environmentObject(geminiService)
        .navigationBarHidden(true)
        .overlay(
            Group {
                if showStreakMilestone, let milestone = dataManager.pendingStreakMilestone {
                    StreakMilestoneView(streakDays: milestone) {
                        UserDefaults.standard.set(milestone, forKey: "lastCelebratedStreakMilestone")
                        dataManager.pendingStreakMilestone = nil
                        showStreakMilestone = false
                    }
                }
            }
        )
        .onAppear {
            dataManager.refreshStreak()
            if let tier = dataManager.currentBOLTTier() {
                let exercise = TrainingPlanProvider.todaysExercise(for: tier)
                geminiService.fetchExerciseTip(exercise: exercise, tier: tier, dataManager: dataManager)
                dataManager.refreshTodayProtocolStatus(for: tier)
            }
            // Check for pending streak milestone
            if dataManager.pendingStreakMilestone != nil {
                showStreakMilestone = true
            }
            // Content entrance animation
            withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                contentAppeared = true
            }
            // Fade in motivational subline
            withAnimation(.easeIn(duration: 0.6).delay(0.5)) {
                sublineOpacity = 1.0
            }
            // Breathing pulse on waves
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                waveBreathScale = 1.08
            }
            // Ambient glow pulse
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                ambientGlow = 1.0
            }
        }
    }

    @ViewBuilder
    private func destinationView(for exercise: BreathingExercise) -> some View {
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

// MARK: - BOLT Test Card
struct BOLTTestCard: View {
    var body: some View {
        HStack(spacing: 14) {
            // Icon with golden glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.homeGoldenAccent.opacity(0.25), Color.homeGoldenAccent.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 24
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: "lungs.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.homeGoldenAccent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("BOLT Score Test")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                Text("Measure your CO\u{2082} tolerance \u{00B7} ~1 min")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.homeGoldenAccent.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.homeGoldenAccent.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [Color.homeGoldenAccent.opacity(0.25), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: Color.homeGoldenAccent.opacity(0.08), radius: 10, y: 4)
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: BreathingExercise

    private var numCycles: Int {
        exercise.savedCycles()
    }
    private var isInfinite: Bool {
        exercise.savedIsUnlimited()
    }

    private var etaText: String {
        let totalSeconds = exercise.timeForOneCycle() * numCycles
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else {
            let minutes = totalSeconds / 60
            return "\(minutes)m"
        }
    }

    private var iconName: String {
        switch exercise {
        case .boxBreathing: return "square"
        case .fourSevenEight: return "moon.zzz"
        case .exhaleHold: return "wind"
        case .custom: return "slider.horizontal.3"
        }
    }

    private var accentColor: Color {
        switch exercise {
        case .boxBreathing: return .homeWarmAccent
        case .fourSevenEight: return Color(red: 0.6, green: 0.5, blue: 0.9)
        case .exhaleHold: return .homeGoldenAccent
        case .custom: return Color(red: 0.5, green: 0.8, blue: 0.7)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.2), accentColor.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(accentColor)
            }

            // Name + meta
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                HStack(spacing: 6) {
                    Text(isInfinite ? "∞ cycles" : "\(numCycles) cycles")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                    Text("\u{00B7}")
                        .foregroundColor(.white.opacity(0.2))
                    Text(isInfinite ? "∞" : etaText)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 28, height: 28)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [accentColor.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: accentColor.opacity(0.06), radius: 8, y: 4)
    }
}


struct BreathCycleSelector: View {
    @Binding var cycles: Int
    @Binding var isUnlimited: Bool
    let exercise: BreathingExercise
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 148  // narrower for pre-workout screens
    let thumbSize: CGFloat = 16
    let maxCycles = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.3.trianglepath")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.homeWarmAccent.opacity(0.8))
                    Text("Breath cycles")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Text(isUnlimited ? "∞ cycles" : "\(cycles) cycles")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Slider row
            HStack(spacing: 16) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(width: sliderWidth, height: 2)
                        .foregroundColor(.white.opacity(0.15))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.homeWarmAccent.opacity(0.5), Color.homeWarmAccent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: isUnlimited ? sliderWidth : sliderWidth * CGFloat(cycles) / CGFloat(maxCycles), height: 2)

                    ZStack {
                        Circle()
                            .fill(Color.homeWarmAccent.opacity(0.2))
                            .frame(width: thumbSize + 8, height: thumbSize + 8)
                        Circle()
                            .fill(Color.white)
                            .frame(width: thumbSize, height: thumbSize)
                    }
                    .shadow(color: Color.homeWarmAccent.opacity(0.3), radius: 6, y: 0)
                    .offset(x: isUnlimited ? sliderWidth - thumbSize / 2 : sliderWidth * CGFloat(cycles) / CGFloat(maxCycles) - thumbSize / 2)
                    .gesture(
                        DragGesture().onChanged { gesture in
                            if !isUnlimited {
                                let newCycleValue = Int((gesture.location.x / sliderWidth) * CGFloat(maxCycles))
                                let adjustedValue = min(max(newCycleValue, 1), maxCycles)
                                cycles = adjustedValue
                                UserDefaults.standard.set(adjustedValue, forKey: exercise.cyclesKey)
                            }
                        }
                    )
                }

                Button(action: {
                    isUnlimited.toggle()
                    UserDefaults.standard.set(isUnlimited, forKey: exercise.unlimitedKey)
                    if isUnlimited {
                        cycles = maxCycles
                        UserDefaults.standard.set(maxCycles, forKey: exercise.cyclesKey)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isUnlimited ? Color.homeGoldenAccent : Color.white.opacity(0.08))
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(Color.white.opacity(isUnlimited ? 0 : 0.15), lineWidth: 0.5)
                            .frame(width: 36, height: 36)
                        Image(systemName: "infinity")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isUnlimited ? .homeWarmBlueDark : .white.opacity(0.6))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

private extension Int {
    var nonZero: Int? { self != 0 ? self : nil }
}

// MARK: - Floating Ambient Particles

struct FloatingParticles: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<18, id: \.self) { i in
                FloatingParticle(
                    screenWidth: geo.size.width,
                    screenHeight: geo.size.height,
                    index: i
                )
            }
        }
    }
}

struct FloatingParticle: View {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let index: Int

    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0

    private var startX: CGFloat {
        CGFloat.random(in: 20...(screenWidth - 20))
    }

    private var size: CGFloat {
        CGFloat.random(in: 2...5)
    }

    private var duration: Double {
        Double.random(in: 8...16)
    }

    private var delay: Double {
        Double.random(in: 0...8)
    }

    private var particleColor: Color {
        [Color.homeWarmAccent, Color.homeGoldenAccent, Color.white].randomElement()!
    }

    var body: some View {
        Circle()
            .fill(particleColor)
            .frame(width: size, height: size)
            .position(x: startX, y: screenHeight * 0.8)
            .offset(y: yOffset)
            .opacity(opacity)
            .blur(radius: size > 3.5 ? 1 : 0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    yOffset = -(screenHeight * 0.9)
                }
                withAnimation(
                    .easeInOut(duration: duration * 0.3)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacity = Double.random(in: 0.15...0.35)
                }
            }
    }
}
