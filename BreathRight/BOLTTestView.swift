import SwiftUI

struct BOLTTestView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode

    enum TestPhase {
        case instructions
        case prep
        case timing
        case result
    }

    @State private var phase: TestPhase = .instructions
    @State private var timerValue: Double = 0
    @State private var timer: Timer?
    @State private var prepCountdown: Int = 3
    @State private var prepTimer: Timer?
    @State private var resultOpacity: Double = 0
    @State private var resultScale: CGFloat = 0.8
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.homeWarmBlueDark, Color.homeWarmBlue, Color.homeWarmBlueLight]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            switch phase {
            case .instructions:
                instructionsView
            case .prep:
                prepView
            case .timing:
                timingView
            case .result:
                resultView
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            timer?.invalidate()
            prepTimer?.invalidate()
        }
    }

    // MARK: - Instructions

    private var instructionsView: some View {
        VStack(spacing: 0) {
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
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.homeWarmAccent.opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.homeWarmAccent)
                }

                Text("BOLT Score Test")
                    .font(.system(size: 26, weight: .light, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.homeWarmAccent.opacity(0.7))
                        .frame(width: 12, height: 2)
                    Text("CO2 tolerance measurement")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(0.5)
                        .foregroundColor(.white.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 16) {
                    instructionStep(number: "1", text: "Breathe normally for 30 seconds")
                    instructionStep(number: "2", text: "Exhale gently through your nose")
                    instructionStep(number: "3", text: "Pinch your nose and start the timer")
                    instructionStep(number: "4", text: "Tap stop at the first urge to breathe")
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                Text("Don't hold until discomfort — stop at the first distinct desire to inhale")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            Button(action: { startPrep() }) {
                HStack(spacing: 10) {
                    Text("Start Test")
                        .font(.system(size: 15, weight: .medium))
                    Image(systemName: "chevron.right")
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
        }
    }

    private func instructionStep(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.homeWarmAccent.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.homeWarmAccent)
            }
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.75))
                .padding(.top, 4)
        }
    }

    // MARK: - Prep countdown

    private var prepView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Breathe normally...")
                .font(.system(size: 22, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 160, height: 160)

                Circle()
                    .stroke(Color.homeWarmAccent.opacity(0.6), lineWidth: 8)
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulseScale)
                    .opacity(Double(2.0 - pulseScale))

                Text("\(prepCountdown)")
                    .font(.system(size: 60, weight: .light, design: .rounded))
                    .foregroundColor(.white)
            }

            Text("Exhale gently, then pinch your nose")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Active timing

    private var timingView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Hold...")
                .font(.system(size: 20, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.6))

            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.homeGoldenAccent.opacity(0.15), Color.clear],
                            center: .center,
                            startRadius: 80,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)

                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 220, height: 220)

                Text(String(format: "%.1f", timerValue))
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundColor(.white)

                Text("seconds")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .offset(y: 40)
            }

            Text("Tap when you feel the first urge to breathe")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.45))

            Spacer()

            Button(action: { stopTimer() }) {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 12))
                    Text("Stop")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.homeWarmBlueDark)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.homeGoldenAccent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.homeGoldenAccent.opacity(0.3), radius: 12, y: 4)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }

    // MARK: - Result

    private var resultView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [scoreColor.opacity(0.2), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    Circle()
                        .stroke(scoreColor.opacity(0.5), lineWidth: 2)
                        .frame(width: 100, height: 100)

                    VStack(spacing: 2) {
                        Text(String(format: "%.1f", timerValue))
                            .font(.system(size: 36, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        Text("seconds")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Text(scoreTitle)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(scoreColor)

                Text(scoreDescription)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // New achievements
                if !dataManager.newlyUnlockedAchievements.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(dataManager.newlyUnlockedAchievements) { achievement in
                            HStack(spacing: 10) {
                                Image(systemName: achievement.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(.homeGoldenAccent)
                                Text(achievement.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.homeGoldenAccent)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.homeGoldenAccent.opacity(0.1))
                            )
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .scaleEffect(resultScale)
            .opacity(resultOpacity)

            Spacer()

            VStack(spacing: 12) {
                Button(action: { retakeTest() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12, weight: .medium))
                        Text("Retake Test")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
                }

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
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
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(resultOpacity)
        }
    }

    // MARK: - Score interpretation

    private var scoreColor: Color {
        if timerValue < 10 { return .orange }
        if timerValue < 20 { return .homeWarmAccent }
        if timerValue < 30 { return .homeWarmAccent }
        if timerValue < 40 { return .green }
        return .homeGoldenAccent
    }

    private var scoreTitle: String {
        if timerValue < 10 { return "Room to Grow" }
        if timerValue < 20 { return "Developing" }
        if timerValue < 30 { return "Good" }
        if timerValue < 40 { return "Very Good" }
        return "Elite"
    }

    private var scoreDescription: String {
        if timerValue < 10 {
            return "Your CO2 tolerance is low. Regular breathing practice will help improve it significantly."
        }
        if timerValue < 20 {
            return "You're building CO2 tolerance. Keep practicing daily and you'll see improvement."
        }
        if timerValue < 30 {
            return "Solid CO2 tolerance. You're in a good range — keep pushing higher."
        }
        if timerValue < 40 {
            return "Excellent CO2 tolerance. You're well above average."
        }
        return "Outstanding. You have elite-level breath control and CO2 tolerance."
    }

    // MARK: - Actions

    private func startPrep() {
        phase = .prep
        prepCountdown = 3

        withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
            pulseScale = 1.3
        }

        prepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if prepCountdown > 1 {
                prepCountdown -= 1
            } else {
                prepTimer?.invalidate()
                startTiming()
            }
        }
    }

    private func startTiming() {
        phase = .timing
        timerValue = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timerValue += 0.1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil

        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Save score
        dataManager.saveBOLTScore(seconds: timerValue)

        // Show result
        phase = .result
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            resultScale = 1.0
            resultOpacity = 1.0
        }
    }

    private func retakeTest() {
        timerValue = 0
        resultOpacity = 0
        resultScale = 0.8
        pulseScale = 1.0
        phase = .instructions
    }
}
