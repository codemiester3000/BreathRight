import SwiftUI
import AVFoundation

struct CustomBreathingView: View {
    // Breathing parameters
    @State private var inhaleSeconds: Int = UserDefaults.standard.integer(forKey: "customInhale") > 0 ? UserDefaults.standard.integer(forKey: "customInhale") : 4
    @State private var holdSeconds: Int = UserDefaults.standard.integer(forKey: "customHold") > 0 ? UserDefaults.standard.integer(forKey: "customHold") : 4
    @State private var exhaleSeconds: Int = UserDefaults.standard.integer(forKey: "customExhale") > 0 ? UserDefaults.standard.integer(forKey: "customExhale") : 4

    // Session state
    @State private var isBreathingActive: Bool = false
    @State private var showSummary: Bool = false
    @State private var elapsedTime: Int = 0
    @State private var elapsedTimer: Timer?

    // Breathing cycle state
    @State private var currentPhase: CustomBreathPhase = .inhale
    @State private var phaseProgress: CGFloat = 0.0
    @State private var phaseTimer: Timer?
    @State private var completedCycles: Int = 0
    @State private var flashOpacity: Double = 0

    // Audio
    @State private var audioPlayer: AVAudioPlayer?

    // User settings
    let savedNumCycles = UserDefaults.standard.integer(forKey: "numCycles")
    let savedIsInfinite = UserDefaults.standard.bool(forKey: "unlimtedCycles")

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.homeWarmBlueDark,
                    isBreathingActive ? Color.homeWarmBlue : Color.homeWarmBlueDark.opacity(0.9),
                    isBreathingActive ? Color.homeWarmBlueLight : Color.homeWarmBlue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut(duration: 1.0), value: isBreathingActive)

            // Grid lines
            VStack(spacing: 50) {
                ForEach(0..<14, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.02))
                        .frame(height: 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Particles
            GeometryReader { geometry in
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: CGFloat((index % 3) + 1) * 3)
                        .position(
                            x: CGFloat((index * 41) % Int(geometry.size.width)),
                            y: CGFloat((index * 83) % Int(geometry.size.height))
                        )
                }
            }

            if showSummary {
                Summary(elapsedTime: elapsedTime)
            } else if isBreathingActive {
                activeSessionView
            } else {
                setupView
            }
        }
        .onDisappear {
            stopSession()
        }
    }

    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Custom Breathing")
                            .font(.system(size: 26, weight: .light, design: .rounded))
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.homeGoldenAccent.opacity(0.8))
                                .frame(width: 12, height: 2)
                            Text("design your rhythm")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(0.5)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    Spacer()
                }

                // Separator
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.homeGoldenAccent.opacity(0.6))
                        .frame(width: 24, height: 1)
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                }
                .padding(.top, 20)

                // Cycles pill
                HStack(spacing: 5) {
                    Image(systemName: "arrow.3.trianglepath")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.homeGoldenAccent.opacity(0.8))
                    Text(savedIsInfinite ? "∞ cycles" : "\(savedNumCycles) cycles")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.06))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .padding(.top, 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 50)

            Spacer()

            // Duration controls
            VStack(spacing: 24) {
                DurationControl(
                    label: "Inhale",
                    value: $inhaleSeconds,
                    color: .white,
                    icon: "arrow.down"
                )

                DurationControl(
                    label: "Hold",
                    value: $holdSeconds,
                    color: .homeGoldenAccent,
                    icon: "pause"
                )

                DurationControl(
                    label: "Exhale",
                    value: $exhaleSeconds,
                    color: .homeWarmAccent,
                    icon: "arrow.up"
                )
            }
            .padding(.horizontal, 24)

            // Total time indicator
            HStack {
                Text("One cycle:")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
                Text("\(inhaleSeconds + holdSeconds + exhaleSeconds) seconds")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 24)

            Spacer()

            // Begin button
            Button(action: startSession) {
                HStack(spacing: 10) {
                    Text("Begin Session")
                        .font(.system(size: 15, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.homeGoldenAccent)
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

    // MARK: - Active Session View
    private var activeSessionView: some View {
        VStack(spacing: 0) {
            // Header with stats
            VStack(alignment: .leading, spacing: 0) {
                AnimatedHeaderView()
                    .padding(.top, -50)
                    .padding(.bottom, 40)
                    .opacity(0.6)

                // Stats pills
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .medium))
                        Text(formatTime(elapsedTime))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))

                    Spacer()

                    HStack(spacing: 5) {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(completedCycles) / \(savedIsInfinite ? "∞" : "\(savedNumCycles)")")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(flashOpacity + 0.08))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                }

                // Separator
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.homeGoldenAccent.opacity(0.6))
                        .frame(width: 24, height: 1)
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 50)

            Spacer()

            // Breathing circle
            CustomBreathingCircle(
                currentPhase: currentPhase,
                progress: phaseProgress,
                inhaleSeconds: inhaleSeconds,
                holdSeconds: holdSeconds,
                exhaleSeconds: exhaleSeconds
            )

            Spacer()

            // End session button
            Button(action: endSession) {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 10, weight: .medium))
                    Text("End Session")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5))
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Actions
    private func startSession() {
        // Save settings
        UserDefaults.standard.set(inhaleSeconds, forKey: "customInhale")
        UserDefaults.standard.set(holdSeconds, forKey: "customHold")
        UserDefaults.standard.set(exhaleSeconds, forKey: "customExhale")

        // Reset state
        elapsedTime = 0
        completedCycles = 0
        currentPhase = .inhale
        phaseProgress = 0

        // Start timers
        isBreathingActive = true

        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }

        playAudio(named: "Inhale")
        startPhaseTimer(for: .inhale)
    }

    private func startPhaseTimer(for phase: CustomBreathPhase) {
        phaseTimer?.invalidate()
        phaseProgress = 0
        currentPhase = phase

        let duration = phaseDuration(for: phase)
        var elapsed: Double = 0

        phaseTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            elapsed += 0.01
            phaseProgress = CGFloat(elapsed / Double(duration))

            if elapsed >= Double(duration) {
                timer.invalidate()
                advancePhase()
            }
        }
    }

    private func advancePhase() {
        switch currentPhase {
        case .inhale:
            playAudio(named: "Hold")
            startPhaseTimer(for: .hold)
        case .hold:
            playAudio(named: "Exhale")
            startPhaseTimer(for: .exhale)
        case .exhale:
            completedCycles += 1
            flashCyclesText()

            if completedCycles >= savedNumCycles && !savedIsInfinite {
                endSession()
            } else {
                playAudio(named: "Inhale")
                startPhaseTimer(for: .inhale)
            }
        }
    }

    private func endSession() {
        stopSession()
        showSummary = true
    }

    private func stopSession() {
        phaseTimer?.invalidate()
        phaseTimer = nil
        elapsedTimer?.invalidate()
        elapsedTimer = nil
        audioPlayer?.stop()
        isBreathingActive = false
    }

    private func phaseDuration(for phase: CustomBreathPhase) -> Int {
        switch phase {
        case .inhale: return inhaleSeconds
        case .hold: return holdSeconds
        case .exhale: return exhaleSeconds
        }
    }

    private func flashCyclesText() {
        withAnimation(.easeInOut(duration: 0.5)) {
            flashOpacity = 0.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                flashOpacity = 0
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return "\(mins) min \(String(format: "%02d", secs)) sec"
    }

    private func playAudio(named fileName: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)

                if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
                    let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    player.prepareToPlay()
                    DispatchQueue.main.async {
                        self.audioPlayer = player
                        self.audioPlayer?.play()
                    }
                }
            } catch {
                print("Audio error: \(error)")
            }
        }
    }
}

// MARK: - Custom Breath Phase
enum CustomBreathPhase: String {
    case inhale = "Inhale"
    case hold = "Hold"
    case exhale = "Exhale"
}

// MARK: - Duration Control
struct DurationControl: View {
    let label: String
    @Binding var value: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            // Label
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color.opacity(0.8))
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 80, alignment: .leading)

            Spacer()

            // Stepper controls
            HStack(spacing: 16) {
                Button(action: { if value > 1 { value -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                }

                Text("\(value)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 40)

                Button(action: { if value < 30 { value += 1 } }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                }
            }

            Text("sec")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 30, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }
}

// MARK: - Breathing Circle
struct CustomBreathingCircle: View {
    let currentPhase: CustomBreathPhase
    let progress: CGFloat
    let inhaleSeconds: Int
    let holdSeconds: Int
    let exhaleSeconds: Int

    @State private var textScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4

    private var phaseColor: Color {
        switch currentPhase {
        case .inhale: return .white
        case .hold: return .homeGoldenAccent
        case .exhale: return .homeWarmAccent
        }
    }

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [phaseColor.opacity(glowOpacity * 0.2), Color.clear],
                        center: .center,
                        startRadius: 100,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)

            // Track
            Circle()
                .stroke(lineWidth: 10)
                .foregroundColor(.white.opacity(0.1))
                .frame(width: 250, height: 250)

            // Progress
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [phaseColor, phaseColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(270))
                .frame(width: 250, height: 250)
                .shadow(color: phaseColor.opacity(0.4), radius: 10)

            // Phase text
            VStack(spacing: 8) {
                Text(currentPhase.rawValue)
                    .font(.system(size: 26, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .scaleEffect(textScale)

                Rectangle()
                    .fill(phaseColor.opacity(0.5))
                    .frame(width: 40, height: 2)
            }
        }
        .onAppear {
            startGlow()
            applyScale(for: currentPhase)
        }
        .onChange(of: currentPhase) { newPhase in
            applyScale(for: newPhase)
        }
    }

    private func startGlow() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
    }

    private func applyScale(for phase: CustomBreathPhase) {
        withAnimation(.easeInOut(duration: Double(phaseDuration(for: phase)))) {
            switch phase {
            case .inhale: textScale = 1.12
            case .hold: textScale = 1.0
            case .exhale: textScale = 0.88
            }
        }
    }

    private func phaseDuration(for phase: CustomBreathPhase) -> Int {
        switch phase {
        case .inhale: return inhaleSeconds
        case .hold: return holdSeconds
        case .exhale: return exhaleSeconds
        }
    }
}
