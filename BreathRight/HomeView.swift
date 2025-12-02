import SwiftUI

// Enum for breathing exercises
enum BreathingExercise: String, CaseIterable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
    //    case custom = "Custom"
    
    // Benefits for each exercise
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
            // Box breathing is typically 4 seconds inhale, 4 seconds hold, 4 seconds exhale, 4 seconds hold
            return 4 + 4 + 4 + 4 // 16 seconds
        case .fourSevenEight:
            // 4-7-8 breathing is 4 seconds inhale, 7 seconds hold, 8 seconds exhale
            return 4 + 7 + 8 // 19 seconds
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
        VStack(alignment: .leading, spacing: 0) {

            AnimatedHeaderView()
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .opacity(0.8)

            GreetingHeader()
                .padding(.top, 24)

            BreathCycleSelector(cycles: $numCycles, isUnlimited: $unlimtedCycles)
                .padding(.top, 32)

            Text("SELECT YOUR EXERCISE")
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 32)
                .padding(.bottom, 16)

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
        .padding(.horizontal, 20)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.lighterBlue, Color.myTurqoise]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
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

// MARK: - Professional Greeting Header
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
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Ready to breathe?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Icon with subtle glow
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
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
                    .stroke(Color.white.opacity(0.12 - Double(index) * 0.03), lineWidth: 1)
                    .frame(width: 24 - CGFloat(index * 5), height: 24 - CGFloat(index * 5))
                    .rotationEffect(.degrees(rotation + Double(index * 20)))
            }
        }
        .frame(width: 32, height: 32)
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
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
                .fill(Color.white.opacity(0.15))
                .frame(width: 3, height: 3)

            // Orbiting dots
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.2 - Double(index) * 0.05))
                    .frame(width: 4, height: 4)
                    .offset(x: 10 + CGFloat(index * 2))
                    .rotationEffect(.degrees(rotation + Double(index * 120)))
            }
        }
        .frame(width: 32, height: 32)
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Professional Exercise Card
struct ExerciseCard: View {
    let exercise: BreathingExercise
    let numCycles: Int
    let isInfinite: Bool

    private let screenWidth = UIScreen.main.bounds.width

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
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.top, 18)
                .padding(.horizontal, 20)

                // Benefits list
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(exercise.benefits, id: \.self) { benefit in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.backgroundBeige.opacity(0.9))
                                .frame(width: 5, height: 5)
                            Text(benefit)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 20)

                Spacer()

                // Bottom metadata row
                HStack(spacing: 12) {
                    // Cycles pill
                    Label {
                        Text(isInfinite ? "∞" : "\(numCycles)")
                            .font(.system(size: 11, weight: .medium))
                    } icon: {
                        Image(systemName: "repeat")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())

                    // Duration pill
                    Label {
                        Text(isInfinite ? "∞" : etaText)
                            .font(.system(size: 11, weight: .medium))
                    } icon: {
                        Image(systemName: "clock")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())

                    Spacer()

                    // Arrow
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 20)
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
            .padding(.top, 14)
            .padding(.trailing, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 155)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.25))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }
}


struct BreathCycleSelector: View {
    @Binding var cycles: Int
    @Binding var isUnlimited: Bool
    // 20pt margins on each side (40pt total) + 16pt spacing + 36pt infinity button = 92pt
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 92
    let thumbSize: CGFloat = 18
    let trackColor = Color.white.opacity(0.2)
    let thumbColor = Color.white
    let maxCycles = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.3.trianglepath")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text("Breath cycles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Text(isUnlimited ? "∞ cycles" : "\(cycles) cycles")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }

            // Slider row
            HStack(spacing: 16) {
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .frame(width: sliderWidth, height: 2)
                        .foregroundColor(trackColor)

                    // Track fill
                    Capsule()
                        .frame(width: isUnlimited ? sliderWidth : sliderWidth * CGFloat(cycles) / CGFloat(maxCycles), height: 2)
                        .foregroundColor(thumbColor)

                    // Thumb
                    Circle()
                        .fill(thumbColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
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
                    Image(systemName: "infinity")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isUnlimited ? .myTurqoise : .white.opacity(0.7))
                        .frame(width: 36, height: 36)
                        .background(isUnlimited ? Color.white : Color.clear)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(isUnlimited ? 0 : 0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}


