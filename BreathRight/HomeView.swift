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
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.lighterBlue, Color.myTurqoise]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 0) {

                    AnimatedHeaderView()
                        .padding(.top, -60)
                        .padding(.bottom, 16)
                        .opacity(0.8)

                    VStack(alignment: .leading, spacing: 0) {
                        // Greeting section
                        HStack {
                            Text(greetingMessage())
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: greetingIconName())
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 24)

                        // Subtle separator
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 1)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        // Breath cycle selector
                        HStack {
                            BreathCycleSelector(cycles: $numCycles, isUnlimited: $unlimtedCycles)
                            Spacer()
                        }
                        .padding(.top, 32)
                        .padding(.horizontal, 24)

                        // Section header - refined uppercase style
                        Text("SELECT YOUR EXERCISE")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 32)
                            .padding(.bottom, 16)
                            .padding(.leading, 24)
                    }
                    
                    VStack(alignment: .center, spacing: 16) {
                        ForEach(BreathingExercise.allCases, id: \.self) { exercise in
                            NavigationLink(destination: destinationView(for: exercise)) {
                                BeautifulButton(
                                    title: exercise.rawValue,
                                    benefits: exercise.benefits,
                                    numCycles: numCycles,
                                    timeForCycle: exercise.timeForOneCycle(),
                                    isInfinite: unlimtedCycles
                                )
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
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
            // Add cases for other exercises
        }
    }
    
    // Function to determine greeting based on time of day
    private func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private func greetingIconName() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "sunrise.fill" // Morning icon
        case 12..<17: return "sun.max.fill" // Afternoon icon
        case 17..<20: return "moon.stars.fill" // Evening icon
        default: return "moon.stars.fill" // Night icon
        }
    }
}

struct BeautifulButton: View {
    let title: String
    let benefits: [String]
    let numCycles: Int
    let timeForCycle: Int
    let isInfinite: Bool

    let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top accent line
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.4))
                .frame(width: 40, height: 2)
                .padding(.top, 20)
                .padding(.leading, 20)

            // Title
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 12)
                .padding(.horizontal, 20)

            // Benefits list
            VStack(alignment: .leading, spacing: 6) {
                ForEach(benefits, id: \.self) { benefit in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.backgroundBeige)
                        Text(benefit)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)

            Spacer()

            // Bottom metadata row
            HStack(spacing: 16) {
                // Cycles pill
                HStack(spacing: 4) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 10, weight: .medium))
                    Text(isInfinite ? "∞" : "\(numCycles)")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())

                // Duration pill
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 10, weight: .medium))
                    Text(isInfinite ? "∞" : etaText)
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())

                Spacer()

                // Arrow indicator
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(width: screenWidth * 0.88, height: 170)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
    }
    
    private var etaText: String {
        let totalSeconds = timeForCycle * numCycles
        if totalSeconds < 60 {
            return "\(totalSeconds) sec"
        } else {
            let roundedMinutes = (totalSeconds + 30) / 60 // Round to nearest minute
            return "\(roundedMinutes) min"
        }
    }
}


struct BreathCycleSelector: View {
    @Binding var cycles: Int
    @Binding var isUnlimited: Bool
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 140
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


