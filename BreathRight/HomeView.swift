import SwiftUI

// Warm blue color palette for home screen (matching splash)
extension Color {
    static let homeWarmBlue = Color(red: 0.2, green: 0.45, blue: 0.65)
    static let homeWarmBlueLight = Color(red: 0.35, green: 0.55, blue: 0.75)
    static let homeWarmBlueDark = Color(red: 0.12, green: 0.3, blue: 0.5)
    static let homeWarmAccent = Color(red: 0.4, green: 0.7, blue: 0.85)
}

// Enum for breathing exercises
enum BreathingExercise: String, CaseIterable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"

    var benefits: [String] {
        switch self {
        case .boxBreathing:
            return ["Reduces stress", "Improves concentration", "Enhances relaxation"]
        case .fourSevenEight:
            return ["Improves sleep", "Manages cravings", "Reduces stress"]
        }
    }

    func timeForOneCycle() -> Int {
        switch self {
        case .boxBreathing:
            return 4 + 4 + 4 + 4
        case .fourSevenEight:
            return 4 + 7 + 8
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

            // Main content
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

                Spacer()
            }
            .padding(.horizontal, 24)
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
            // Add cases for other exercises
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

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.system(size: 26, weight: .light, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.homeWarmAccent.opacity(0.8))
                        .frame(width: 12, height: 2)
                    Text("ready to breathe?")
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
                            colors: [Color.homeWarmAccent.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)

                Circle()
                    .stroke(Color.homeWarmAccent.opacity(0.3), lineWidth: 1)
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.white.opacity(0.85))
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

// MARK: - Spa-Tech Exercise Card
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

                    Spacer()

                    // Arrow with glow
                    ZStack {
                        Circle()
                            .fill(Color.homeWarmAccent.opacity(0.1))
                            .frame(width: 28, height: 28)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.homeWarmAccent.opacity(0.8))
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
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
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

                // Infinity toggle button
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
                            .fill(isUnlimited ? Color.white : Color.white.opacity(0.08))
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(Color.white.opacity(isUnlimited ? 0 : 0.15), lineWidth: 0.5)
                            .frame(width: 36, height: 36)
                        Image(systemName: "infinity")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(isUnlimited ? .homeWarmBlue : .white.opacity(0.6))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}


