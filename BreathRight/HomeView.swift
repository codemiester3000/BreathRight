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
    case custom = "Custom Breathing"

    var benefits: [String] {
        switch self {
        case .boxBreathing:
            return ["Reduces stress", "Improves concentration", "Enhances relaxation"]
        case .fourSevenEight:
            return ["Improves sleep", "Manages cravings", "Reduces stress"]
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
        case .custom:
            // Custom will calculate dynamically based on user settings
            let inhale = UserDefaults.standard.integer(forKey: "customInhale")
            let hold = UserDefaults.standard.integer(forKey: "customHold")
            let exhale = UserDefaults.standard.integer(forKey: "customExhale")
            return (inhale > 0 ? inhale : 4) + (hold > 0 ? hold : 4) + (exhale > 0 ? exhale : 4)
        }
    }
}

struct HomeView: View {
    @State private var numCycles: Int = {
        let savedValue = UserDefaults.standard.integer(forKey: "numCycles")
        return savedValue != 0 ? savedValue : 10 // If savedValue is 0 (not set), return 10
    }()

    @State private var unlimtedCycles: Bool = UserDefaults.standard.bool(forKey: "unlimtedCycles")

    var body: some View {
        ZStack {
            // Warm gradient background (matching splash)
            LinearGradient(
                gradient: Gradient(colors: [Color.homeWarmBlueDark, Color.homeWarmBlue, Color.homeWarmBlueLight]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // Subtle grid lines (technical element)
            VStack(spacing: 50) {
                ForEach(0..<12, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.025))
                        .frame(height: 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating particles
            GeometryReader { geometry in
                ForEach(0..<10, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: CGFloat((index % 3) + 1) * 4)
                        .position(
                            x: CGFloat((index * 37) % Int(geometry.size.width)),
                            y: CGFloat((index * 89) % Int(geometry.size.height))
                        )
                }
            }

            // Main content - scrollable
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Wave animation at top
                    ZStack {
                        ForEach(0..<5, id: \.self) { index in
                            CosineAnimation()
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .frame(height: 55)
                                .offset(y: CGFloat(index * 12))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .padding(.top, -20)
                    .padding(.bottom, 48)
                    .opacity(0.7)

                    GreetingHeader()

                    BreathCycleSelector(cycles: $numCycles, isUnlimited: $unlimtedCycles)
                        .padding(.top, 40)

                    // Section label with accent bar
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.homeWarmAccent)
                            .frame(width: 16, height: 2)
                        Text("select exercise")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    VStack(spacing: 16) {
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
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func destinationView(for exercise: BreathingExercise) -> some View {
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

// MARK: - Refined Greeting Header
struct GreetingHeader: View {
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

    // Golden for sun, cyan for moon
    private var iconAccentColor: Color {
        switch hour {
        case 6..<17: return .homeGoldenAccent
        default: return .homeWarmAccent
        }
    }

    // Random motivational taglines
    private static let taglines = [
        "find your calm",
        "breathe with intention",
        "your moment of peace",
        "center yourself",
        "embrace stillness",
        "inhale clarity"
    ]

    @State private var tagline: String = taglines.randomElement() ?? "find your calm"

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.system(size: 26, weight: .light, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.homeGoldenAccent.opacity(0.85))
                        .frame(width: 12, height: 2)
                    Text(tagline)
                        .font(.system(size: 12, weight: .medium))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.55))
                }
            }

            Spacer()

            // Icon with soft glow ring
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [iconAccentColor.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)

                Circle()
                    .stroke(iconAccentColor.opacity(0.4), lineWidth: 1)
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(iconAccentColor.opacity(0.9))
            }
        }
    }
}

// MARK: - Geometric Animations for Cards
struct RotatingSquaresAnimation: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.homeWarmAccent.opacity(0.6 - Double(index) * 0.12), lineWidth: 1)
                    .frame(width: 22 - CGFloat(index * 5), height: 22 - CGFloat(index * 5))
                    .rotationEffect(.degrees(rotation + Double(index * 20)))
            }
        }
        .frame(width: 28, height: 28)
        .onAppear {
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct OrbitingDotsAnimation: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Center point
            Circle()
                .fill(Color.homeWarmAccent.opacity(0.7))
                .frame(width: 4, height: 4)

            // Orbiting dots
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.homeWarmAccent.opacity(0.6 - Double(index) * 0.1))
                    .frame(width: 4, height: 4)
                    .offset(x: 9 + CGFloat(index * 2))
                    .rotationEffect(.degrees(rotation + Double(index * 120)))
            }
        }
        .frame(width: 28, height: 28)
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct PulsingBarsAnimation: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.homeWarmAccent.opacity(0.6))
                    .frame(width: 3, height: barHeight(for: index))
                    .animation(.easeInOut(duration: 1.2), value: phase)
            }
        }
        .frame(width: 28, height: 28)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
                phase = (phase + 1) % 3
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let heights: [[CGFloat]] = [
            [18, 10, 14],
            [10, 18, 10],
            [14, 10, 18]
        ]
        return heights[phase][index]
    }
}

// MARK: - Spa-Tech Exercise Card
struct ExerciseCard: View {
    let exercise: BreathingExercise
    let numCycles: Int
    let isInfinite: Bool

    @State private var pillScale: CGFloat = 1.0

    private var etaText: String {
        let totalSeconds = exercise.timeForOneCycle() * numCycles
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else {
            let minutes = totalSeconds / 60
            return "\(minutes)m"
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Title row
                HStack(alignment: .center) {
                    Text(exercise.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))

                    Spacer()
                }
                .padding(.top, 18)
                .padding(.horizontal, 20)

                // Benefits list
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(exercise.benefits, id: \.self) { benefit in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.homeWarmAccent.opacity(0.7))
                                .frame(width: 4, height: 4)
                            Text(benefit)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.top, 14)
                .padding(.horizontal, 20)

                Spacer()

                // Bottom metadata row
                HStack(spacing: 10) {
                    // Cycles pill
                    HStack(spacing: 5) {
                        Image(systemName: "repeat")
                            .font(.system(size: 9, weight: .medium))
                        Text(isInfinite ? "∞" : "\(numCycles)")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
                    .scaleEffect(pillScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: numCycles)

                    // Duration pill
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 9, weight: .medium))
                        Text(isInfinite ? "∞" : etaText)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
                    .scaleEffect(pillScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: numCycles)

                    Spacer()

                    // Arrow with glow
                    ZStack {
                        Circle()
                            .fill(Color.homeWarmAccent.opacity(0.15))
                            .frame(width: 30, height: 30)
                        Circle()
                            .stroke(Color.homeWarmAccent.opacity(0.3), lineWidth: 1)
                            .frame(width: 30, height: 30)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.homeWarmAccent)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }

            // Geometric animation in upper right
            Group {
                switch exercise {
                case .boxBreathing:
                    RotatingSquaresAnimation()
                case .fourSevenEight:
                    OrbitingDotsAnimation()
                case .custom:
                    PulsingBarsAnimation()
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            ZStack {
                // Base fill with subtle gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Subtle left accent edge (golden)
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
                        colors: [Color.white.opacity(0.25), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        .onChange(of: numCycles) { _ in
            animatePills()
        }
        .onChange(of: isInfinite) { _ in
            animatePills()
        }
    }

    private func animatePills() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            pillScale = 1.08
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                pillScale = 1.0
            }
        }
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


