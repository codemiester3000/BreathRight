import SwiftUI
import AVFoundation

struct FourSevenEightBreathingView: View {
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showTooltip: Bool = false
    @State private var isBreathingExerciseActive: Bool = false
    @State private var exerciseTimeElapsed: Double = 0
    @State private var currentPhaseTimeRemaining: Int = 0
    @State private var exerciseTimer: Timer?
    @State private var isSheetPresented = false
    
    // State for diagram animation
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var progress: CGFloat = 0.0
    @State private var isPhaseTransition: Bool = false
    
    var body: some View {
        ZStack {            
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
                        stopButton
                        Spacer()
                    }
                } else {
                    headerView
                    Spacer()
                    
                    CircleView()
                    
                    Spacer()
                    
                    HStack {
                        startButton
                        Spacer()
                    }
                }
            }
        }
        .onDisappear {
            exerciseTimer?.invalidate()
        }
        .sheet(isPresented: $isSheetPresented) {
            Summary(elapsedTime: Int(exerciseTimeElapsed))
        }
    }
    
    private var timerView: some View {
        VStack() {
            
            HStack {
                Text("\(formattedTime(for: Int(exerciseTimeElapsed)))")
                    .font(.footnote)
                    .padding(8)
                    .background(Color.gray.opacity(0.2).cornerRadius(8))
                
                Spacer()
                
                Image("TinyIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
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
                
                Image("TinyIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 5)
                .padding(.top, 30)
        }
    }
    
    private var startButton: some View {
        Button("Begin") {
            playAudio(named: "Inhale")
            startBreathingExercise()
        }
        .font(.footnote)
        .padding()
        .background(.white)
        .foregroundColor(.black)
        .cornerRadius(50)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.leading, 30)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var stopButton: some View {
        Button("Stop") {
            isSheetPresented.toggle()
            stopBreathingExercise()
        }
        .font(.footnote)
        .padding()
        .background(.white)
        .foregroundColor(.black)
        .cornerRadius(50)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        .padding(.leading, 30)
        .padding(.top, 10)
        .padding(.bottom, 20)
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
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
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
                    startTimerForPhase(.inhale)
                    playAudio(named: "Inhale")
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
            .foregroundColor(Color(hex: "2E8B57").opacity(0.4))
            .rotationEffect(Angle(degrees: 270))
            .frame(width: 300, height: 300)
    }
}

struct Diagram: View {
    @Binding var currentPhase: BreathingPhase
    @Binding var progress: CGFloat
    @Binding var isPhaseTransition: Bool
    @Binding var currentPhaseTimeRemaining: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(phaseColor)
                .frame(width: 300, height: 300)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(phaseColor)
                .rotationEffect(Angle(degrees: 270))
                .animation(isPhaseTransition ? nil : .smooth, value: progress)
            
            VStack {
                Text(currentPhase.rawValue)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .animation(.easeIn, value: currentPhase)
//                Text("\(currentPhaseTimeRemaining) seconds")
//                    .font(.title2)
            }
        }
        .padding(40)
    }
    
    private var phaseColor: Color {
        switch currentPhase {
        case .inhale:
            return Color(hex: "2E8B57")
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
