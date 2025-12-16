import SwiftUI
import AVFoundation

struct FourSevenEightBreathingView: View {
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showTooltip: Bool = false
    @State private var isBreathingExerciseActive: Bool = false
    @State private var exerciseTimeElapsed: Double = 0
    @State private var currentPhaseTimeRemaining: Int = 0
    @State private var exerciseTimer: Timer?
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var progress: CGFloat = 0.0
    @State private var isPhaseTransition: Bool = false
    @State private var navigateToSummary = false
    @State private var isFirstLoad = true
    @State private var completedCycles = 0
    @State private var flashOpacity: Double = 0
    
    /// User Defaults values
    let savedNumCycles = UserDefaults.standard.integer(forKey: "numCycles")
    let savedIsInfinite = UserDefaults.standard.bool(forKey: "unlimtedCycles")
    
    var body: some View {
        ZStack {
            // Warm gradient background (darker on setup, lighter when active)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.homeWarmBlueDark,
                    isBreathingExerciseActive ? Color.homeWarmBlue : Color.homeWarmBlueDark.opacity(0.9),
                    isBreathingExerciseActive ? Color.homeWarmBlueLight : Color.homeWarmBlue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut(duration: 1.0), value: isBreathingExerciseActive)

            // Subtle grid lines
            VStack(spacing: 50) {
                ForEach(0..<14, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.02))
                        .frame(height: 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating particles
            GeometryReader { geometry in
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: CGFloat((index % 3) + 1) * 3)
                        .position(
                            x: CGFloat((index * 53) % Int(geometry.size.width)),
                            y: CGFloat((index * 91) % Int(geometry.size.height))
                        )
                }
            }

            // Main content
            VStack {
                if isBreathingExerciseActive {
                    timerView
                    
                    Spacer()
                    
                    Diagram(currentPhase: $currentPhase,
                            progress: $progress,
                            isPhaseTransition: $isPhaseTransition,
                            currentPhaseTimeRemaining: $currentPhaseTimeRemaining)
                    .frame(width: 300, height: 300)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        stopButton
                        Spacer()
                    }
                } else if navigateToSummary {
                    Summary(elapsedTime: Int(exerciseTimeElapsed))
                } else {
                    headerView
                    Spacer()
                    
                    CircleView()
                    
                    Spacer()
                    
                    HStack {
                        startButton
                        Spacer()
                    }
                    .padding(.bottom, 25)
                }
            }
        }
        
        .onDisappear {
            exerciseTimer?.invalidate()
            
            exerciseTimer = nil
            
            // Stop the audio
            audioPlayer?.stop()
        }
        .onAppear {
            isFirstLoad = false
        }
    }
    
    private var timerView: some View {
        VStack(alignment: .leading, spacing: 0) {

            AnimatedHeaderView()
                .padding(.top, -50)
                .padding(.bottom, 40)
                .opacity(0.6)

            // Stats pills row
            HStack {
                // Time pill
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .medium))
                    Text(formattedTime(for: Int(exerciseTimeElapsed)))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )

                Spacer()

                // Cycles pill
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
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
            }

            // Subtle separator with accent
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.homeWarmAccent.opacity(0.6))
                    .frame(width: 24, height: 1)
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 24)
        .padding(.top, 50)
    }
    
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("4-7-8 Breathing")
                        .font(.system(size: 26, weight: .light, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.homeWarmAccent.opacity(0.8))
                            .frame(width: 12, height: 2)
                        Text("relaxation technique")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(0.5)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Spacer()

                Button(action: {
                    showTooltip.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                            .frame(width: 36, height: 36)
                        Image(systemName: "questionmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .popover(isPresented: $showTooltip, arrowEdge: .top) {
                    FourSevenEightBreathInfo()
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 50)

            // Subtle separator with accent
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.homeWarmAccent.opacity(0.6))
                    .frame(width: 24, height: 1)
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Cycles indicator pill
            HStack(spacing: 5) {
                Image(systemName: "arrow.3.trianglepath")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.homeWarmAccent.opacity(0.8))
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
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
    
    private var startButton: some View {
        GeometryReader { geometry in
            Button(action: {
                playAudio(named: "Inhale")
                startBreathingExercise()
            }) {
                HStack(spacing: 10) {
                    Text("Begin Session")
                        .font(.system(size: 15, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.homeWarmAccent)
                }
                .foregroundColor(.white.opacity(0.95))
                .frame(width: geometry.size.width * 0.85, height: 50)
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
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }
            .frame(width: geometry.size.width)
        }
        .frame(height: 50)
        .padding(.bottom, 40)
    }

    private var stopButton: some View {
        Button(action: {
            stopBreathingExercise()
            navigateToSummary = true
        }) {
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
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
        }
    }
    
    func flashCyclesText() {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            flashOpacity = 0.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                flashOpacity = 0.1
            }
        }
    }
    
    private func stopBreathingExercise() {
        exerciseTimer?.invalidate()
        exerciseTimer = nil
        isBreathingExerciseActive = false
        //        exerciseTimeElapsed = 0.0
        currentPhaseTimeRemaining = 0
        progress = 0.0
    }
    
    public func startBreathingExercise() {
        isBreathingExerciseActive = true
        exerciseTimeElapsed = 0.0
        currentPhase = .inhale
        progress = 0.0
        isPhaseTransition = false
        startTimerForPhase(.inhale)
    }
    
    func playAudio(named fileName: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Step 1: Set the audio session category
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
                // Step 2: Activate the audio session
                try AVAudioSession.sharedInstance().setActive(true)
                
                if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
                    do {
                        let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                        audioPlayer.prepareToPlay()
                        DispatchQueue.main.async {
                            self.audioPlayer = audioPlayer
                            self.audioPlayer?.play()
                        }
                    } catch {
                        print("Error playing the audio")
                    }
                }
                
            } catch {
                print("Error setting audio session category or activating it.")
            }
        }
    }
    
    
    // Function to handle timer and update progress
    private func startTimerForPhase(_ phase: BreathingPhase) {
        exerciseTimer?.invalidate()
        var secondsElapsed = 0.0
        let totalSeconds = phase.duration
        
        currentPhaseTimeRemaining = Int(phase.duration) + 1
        
        exerciseTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            exerciseTimeElapsed += 0.01
            secondsElapsed += 0.01
            progress = CGFloat(secondsElapsed) / CGFloat(totalSeconds)
            
            currentPhaseTimeRemaining = Int(phase.duration - secondsElapsed) + 1
            
            if secondsElapsed >= totalSeconds {
                exerciseTimer?.invalidate()
                isPhaseTransition = true
                switch phase {
                case .inhale:
                    currentPhase = .hold
                    startTimerForPhase(.hold)
                    playAudio(named: "Hold")
                case .hold:
                    currentPhase = .exhale
                    startTimerForPhase(.exhale)
                    playAudio(named: "Exhale")
                case .exhale:
                    currentPhase = .inhale
                    self.completedCycles += 1 // Increment completedCycles here
                    self.flashCyclesText()
                    
                    if self.completedCycles >= self.savedNumCycles && !self.savedIsInfinite {
                        self.navigateToSummary = true
                        self.stopBreathingExercise()
                    } else {
                        self.startTimerForPhase(.inhale)
                        self.playAudio(named: "Inhale")
                    }
                }
            }
        }
    }
    
    
    private func formattedTime(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes) min \(String(format: "%02d", remainingSeconds)) sec"
    }
    
}

struct CircleView: View {
    @State private var glowOpacity: Double = 0.3
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer pulse ring
            Circle()
                .stroke(Color.homeWarmAccent.opacity(0.2), lineWidth: 1)
                .frame(width: 280, height: 280)
                .scaleEffect(pulseScale)
                .opacity(Double(2.0 - pulseScale))

            // Subtle glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.homeWarmAccent.opacity(glowOpacity * 0.15), Color.clear],
                        center: .center,
                        startRadius: 80,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)

            // Main circle
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.white.opacity(0.15))
                .frame(width: 250, height: 250)

            // Inner accent ring
            Circle()
                .stroke(Color.homeWarmAccent.opacity(0.3), lineWidth: 1)
                .frame(width: 250, height: 250)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                pulseScale = 1.15
            }
        }
    }
}

struct Diagram: View {
    @Binding var currentPhase: BreathingPhase
    @Binding var progress: CGFloat
    @Binding var isPhaseTransition: Bool
    @Binding var currentPhaseTimeRemaining: Int
    @State private var textScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4

    var body: some View {
        ZStack {
            // Outer glow effect
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
                .animation(.easeInOut(duration: 0.8), value: phaseColor)

            // Background circle track
            Circle()
                .stroke(lineWidth: 10)
                .foregroundColor(.white.opacity(0.1))
                .frame(width: 250, height: 250)

            // Progress circle
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [phaseColor, phaseColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 270))
                .frame(width: 250, height: 250)
                .shadow(color: phaseColor.opacity(0.4), radius: 10, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.1), value: progress)
                .animation(.easeInOut(duration: 0.8), value: phaseColor)

            // Phase text
            VStack(spacing: 8) {
                Text(currentPhase.rawValue)
                    .font(.system(size: 26, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .scaleEffect(textScale)

                // Subtle indicator line
                Rectangle()
                    .fill(phaseColor.opacity(0.5))
                    .frame(width: 40, height: 2)
            }
        }
        .padding(40)
        .onAppear {
            applyScalingBasedOnPhase(currentPhase)
            startGlowAnimation()
        }
        .onChange(of: currentPhase) { newValue in
            applyScalingBasedOnPhase(newValue)
        }
    }

    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
    }

    private func applyScalingBasedOnPhase(_ phase: BreathingPhase) {
        withAnimation(.easeInOut(duration: 2.0)) {
            switch phase {
            case .inhale:
                textScale = 1.12
            case .hold:
                break
            case .exhale:
                textScale = 0.88
            }
        }
    }

    private var phaseColor: Color {
        switch currentPhase {
        case .inhale:
            return .white
        case .hold:
            return Color.homeWarmAccent // Warm cyan accent
        case .exhale:
            return Color.homeWarmAccent.opacity(0.8)
        }
    }
}


enum BreathingPhase: String {
    case inhale = "Inhale"
    case hold = "Hold"
    case exhale = "Exhale"
    
    var duration: Double {
        switch self {
        case .inhale:
            return 4.0
        case .hold:
            return 7.0
        case .exhale:
            return 8.0
        }
    }
}
