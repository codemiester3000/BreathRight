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
        VStack() {
            
            AnimatedHeaderView()
                .padding(.top, -40)
                .padding(.bottom, 60)
            
            HStack {
                Text("\(formattedTime(for: Int(exerciseTimeElapsed)))")
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.2)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .mask(RoundedRectangle(cornerRadius: 16))
                            )
                    )
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Spacer()
                
                Text("\(completedCycles) / \(savedIsInfinite ? "∞" : "\(savedNumCycles)") cycles")
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(flashOpacity))
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.2)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .mask(RoundedRectangle(cornerRadius: 16))
                            )
                    )
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            }
            .padding(.horizontal)
            
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 5)
                .padding(.top, 30)
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
    
    
    private var headerView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("4-7-8 Breathing")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Button(action: {
                    showTooltip.toggle()
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(Color.gray)
                }
                .popover(isPresented: $showTooltip, arrowEdge: .top) {
                    FourSevenEightBreathInfo()
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 5)
                .padding(.vertical, 30)
            
            HStack {
                Image(systemName: "arrow.3.trianglepath").foregroundColor(.white)
                Text(savedIsInfinite ? "∞ cycles" : "\(savedNumCycles) cycles")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var startButton: some View {
        GeometryReader { geometry in
            Button(action: {
                playAudio(named: "Inhale")
                startBreathingExercise()
            }) {
                Text("Breathe")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 12)
                    .frame(width: geometry.size.width * 0.8) // Set the width to 80% of the screen width
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .background(Color.myTurqoise.opacity(0.2))
            }
            .frame(width: geometry.size.width) // This is to ensure the button is centered
        }
        .frame(height: 50) // Set a fixed height for the button
        .padding(.bottom, 32)
    }
    
    private var stopButton: some View {
        Button("Stop") {
            //isSheetPresented.toggle()
            stopBreathingExercise()
            navigateToSummary = true
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
    var body: some View {
        Circle()
            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
            .foregroundColor(Color.white.opacity(0.4))   //Color(hex: "2E8B57").opacity(0.4))
            .rotationEffect(Angle(degrees: 270))
            .frame(width: 300, height: 300)
    }
}

struct Diagram: View {
    @Binding var currentPhase: BreathingPhase
    @Binding var progress: CGFloat
    @Binding var isPhaseTransition: Bool
    @Binding var currentPhaseTimeRemaining: Int
    @State private var textScale: CGFloat = 1.0
    
    @State private var circleOpacity: Double = 0.0
    
    private func fadeInCircle() {
        // Initially hide the circle
        self.circleOpacity = 0.7
        // Fade in the circle
        withAnimation(.easeInOut(duration: 1.0)) {
            self.circleOpacity = 1.0
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(phaseColor)
                .frame(width: 300, height: 300)
                .animation(.easeIn(duration: 0.5), value: phaseColor)
                .onAppear {
                    fadeInCircle()
                }
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(phaseColor)
                .rotationEffect(Angle(degrees: 270))
                .animation(isPhaseTransition ? nil : .smooth, value: progress)
                .animation(.easeIn(duration: 0.5), value: phaseColor)
                .onAppear {
                    fadeInCircle()
                }
            
            VStack {
                Text(currentPhase.rawValue)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .scaleEffect(textScale)
                    .foregroundColor(.white)
            }
        }
        .padding(40)
        .onAppear {
            applyScalingBasedOnPhase(currentPhase)
        }
        .onChange(of: currentPhase) { newValue in
            applyScalingBasedOnPhase(newValue)
        }
    }
    
    private func applyScalingBasedOnPhase(_ phase: BreathingPhase) {
        withAnimation(.easeInOut(duration: 2.0)) {
            switch phase {
            case .inhale:
                textScale = 1.2 // Scale up for inhale
            case .hold:
                // Do nothing, maintain current scale
                break
            case .exhale:
                textScale = 0.8 // Scale down for exhale
            }
        }
    }
    
    private var phaseColor: Color {
        switch currentPhase {
        case .inhale:
            return Color.white
        case .hold:
            return Color(hex: "862e8b")
        case .exhale:
            return Color(hex: "2e8b86")
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
