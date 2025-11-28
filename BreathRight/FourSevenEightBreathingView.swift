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
            LinearGradient(gradient: Gradient(colors: [Color.lighterBlue, isBreathingExerciseActive ? Color.myTurqoise : Color.lighterBlue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 1.0), value: isBreathingExerciseActive)
            
            // Your original VStack content on top of the LinearGradient
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
                .opacity(0.8)

            // Stats pills row
            HStack {
                // Time pill
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .medium))
                    Text(formattedTime(for: Int(exerciseTimeElapsed)))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())

                Spacer()

                // Cycles pill
                HStack(spacing: 6) {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.system(size: 11, weight: .medium))
                    Text("\(completedCycles) / \(savedIsInfinite ? "∞" : "\(savedNumCycles)")")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(flashOpacity + 0.12))
                .clipShape(Capsule())
            }

            // Subtle separator
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
                .padding(.top, 20)
        }
        .padding(.horizontal, 24)
        .padding(.top, 50)
    }
    
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("4-7-8 Breathing")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Button(action: {
                    showTooltip.toggle()
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.5))
                }
                .popover(isPresented: $showTooltip, arrowEdge: .top) {
                    FourSevenEightBreathInfo()
                    Spacer()
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 50)

            // Subtle separator
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            // Cycles indicator pill
            HStack(spacing: 6) {
                Image(systemName: "arrow.3.trianglepath")
                    .font(.system(size: 12, weight: .medium))
                Text(savedIsInfinite ? "∞ cycles" : "\(savedNumCycles) cycles")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
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
                Text("Begin Session")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width * 0.85, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            }
            .frame(width: geometry.size.width)
        }
        .frame(height: 52)
        .padding(.bottom, 40)
    }

    private var stopButton: some View {
        Button(action: {
            stopBreathingExercise()
            navigateToSummary = true
        }) {
            Text("End Session")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
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

    var body: some View {
        ZStack {
            // Subtle glow
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.white)
                .opacity(glowOpacity * 0.1)
                .frame(width: 260, height: 260)
                .blur(radius: 6)

            // Main circle
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.white.opacity(0.2))
                .frame(width: 250, height: 250)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
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
                .stroke(lineWidth: 24)
                .foregroundColor(phaseColor)
                .opacity(glowOpacity * 0.15)
                .frame(width: 270, height: 270)
                .blur(radius: 8)
                .animation(.easeInOut(duration: 0.8), value: phaseColor)

            // Background circle track
            Circle()
                .stroke(lineWidth: 12)
                .foregroundColor(.white.opacity(0.15))
                .frame(width: 250, height: 250)

            // Progress circle
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [phaseColor, phaseColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 270))
                .frame(width: 250, height: 250)
                .shadow(color: phaseColor.opacity(0.5), radius: 12, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.1), value: progress)
                .animation(.easeInOut(duration: 0.8), value: phaseColor)

            // Phase text
            VStack(spacing: 4) {
                Text(currentPhase.rawValue)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(textScale)
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
                textScale = 1.15
            case .hold:
                break
            case .exhale:
                textScale = 0.85
            }
        }
    }

    private var phaseColor: Color {
        switch currentPhase {
        case .inhale:
            return .white
        case .hold:
            return Color.backgroundBeige // Warm gold/beige from theme
        case .exhale:
            return Color.myTurqoise // Turquoise from theme
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
