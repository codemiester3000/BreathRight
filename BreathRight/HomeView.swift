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
    @StateObject private var geminiService = GeminiService()

    @State private var numCycles: Int = {
        let savedValue = UserDefaults.standard.integer(forKey: "numCycles")
        return savedValue != 0 ? savedValue : 10
    }()

    @State private var unlimtedCycles: Bool = UserDefaults.standard.bool(forKey: "unlimtedCycles")

    var body: some View {
        ZStack {
            // Warm gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.homeWarmBlueDark, Color.homeWarmBlue, Color.homeWarmBlueLight]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // Main content - scrollable
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Wave animation at top
                    ZStack {
                        ForEach(0..<3, id: \.self) { index in
                            CosineAnimation()
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .frame(height: 40)
                                .offset(y: CGFloat(index * 10))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .padding(.top, -10)
                    .padding(.bottom, 20)
                    .opacity(0.5)

                    // Status Row (greeting + streak + level)
                    NavigationLink(destination: StatsView()) {
                        StatusRow()
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Journey Card (BOLT progress or onboarding)
                    JourneyCard()
                        .padding(.top, 20)

                    // Today's Exercise with integrated AI coach
                    TodaysExerciseCard(geminiService: geminiService)
                        .padding(.top, 16)

                    // Free practice
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.homeWarmAccent)
                            .frame(width: 12, height: 2)
                        Text("free practice")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                    BreathCycleSelector(cycles: $numCycles, isUnlimited: $unlimtedCycles)
                        .padding(.bottom, 12)

                    VStack(spacing: 8) {
                        ForEach(BreathingExercise.allCases, id: \.self) { exercise in
                            NavigationLink(destination: destinationView(for: exercise)) {
                                ExerciseCard(
                                    exercise: exercise,
                                    numCycles: numCycles,
                                    isInfinite: unlimtedCycles
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // BOLT test
                    NavigationLink(destination: BOLTTestView()) {
                        BOLTTestCard()
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            dataManager.refreshStreak()
            if let tier = dataManager.currentBOLTTier() {
                let exercise = TrainingPlanProvider.todaysExercise(for: tier)
                geminiService.fetchExerciseTip(exercise: exercise, tier: tier, dataManager: dataManager)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for exercise: BreathingExercise) -> some View {
        switch exercise {
        case .boxBreathing:
            BoxBreathingView()
        case .fourSevenEight:
            FourSevenEightBreathingView()
        case .exhaleHold:
            ExhaleHoldView()
        case .custom:
            CustomBreathingView()
        }
    }
}

// MARK: - BOLT Test Card
struct BOLTTestCard: View {
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.homeGoldenAccent.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: "lungs.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.homeGoldenAccent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("BOLT Score Test")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Measure your CO\u{2082} tolerance \u{00B7} ~1 min")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.45))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.homeGoldenAccent.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
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
}

// MARK: - Compact Exercise Card
struct ExerciseCard: View {
    let exercise: BreathingExercise
    let numCycles: Int
    let isInfinite: Bool

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

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.homeWarmAccent)
            }

            // Name + meta
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                HStack(spacing: 8) {
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

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}


struct BreathCycleSelector: View {
    @Binding var cycles: Int
    @Binding var isUnlimited: Bool
    // 24pt margins on each side (48pt total) + 16pt spacing + 36pt infinity button = 100pt
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 100
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
                    // Track background
                    Capsule()
                        .frame(width: sliderWidth, height: 2)
                        .foregroundColor(.white.opacity(0.15))

                    // Track fill with accent gradient
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.homeWarmAccent.opacity(0.5), Color.homeWarmAccent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: isUnlimited ? sliderWidth : sliderWidth * CGFloat(cycles) / CGFloat(maxCycles), height: 2)

                    // Thumb with glow
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
                                UserDefaults.standard.set(adjustedValue, forKey: "numCycles")
                            }
                        }
                    )
                }

                // Infinity toggle button (golden when active)
                Button(action: {
                    isUnlimited.toggle()
                    UserDefaults.standard.set(isUnlimited, forKey: "unlimtedCycles")
                    if isUnlimited {
                        cycles = maxCycles
                        UserDefaults.standard.set(maxCycles, forKey: "numCycles")
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


