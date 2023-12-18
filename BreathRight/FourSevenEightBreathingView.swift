import SwiftUI

struct FourSevenEightBreathingView: View {
    
    @State private var showTooltip: Bool = false
    @State private var isBreathingExerciseActive: Bool = false
    @State private var exerciseTimeElapsed: Int = 0
    @State private var exerciseTimer: Timer?
    
    // State for diagram animation
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var progress: CGFloat = 0.0
    @State private var isPhaseTransition: Bool = false
    
    var body: some View {
        VStack {
            headerView
            if isBreathingExerciseActive {
                breathingExerciseView
            } else {
                startButton
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.2), Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .onDisappear {
            exerciseTimer?.invalidate()
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("4-7-8 Breathing")
                    .font(.custom("Inter-Variable", size: 30))
                
                Button(action: {
                    showTooltip.toggle()
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(Color.gray)
                }
                .popover(isPresented: $showTooltip, arrowEdge: .top) {
                    BoxBreathInfo()
                    Spacer()
                }
                
                Spacer()
                
                Image("TinyIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 5)
                .padding(.top, 30)
        }
    }
    
    private var startButton: some View {
        Button(action: {
            startBreathingExercise()
        }) {
            Text("Begin Now")
                .font(.custom("Inter-Variable", size: 20))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.deepGreen)
                .foregroundColor(.white)
                .cornerRadius(50)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
    }
    
    private var breathingExerciseView: some View {
        VStack {
            Text("Time Elapsed: \(formattedTime(for: exerciseTimeElapsed))")
                .font(.custom("Inter-Variable", size: 16))
                .padding(8)
                .background(Color.gray.opacity(0.2).cornerRadius(8))
            
            Diagram(currentPhase: $currentPhase, progress: $progress, isPhaseTransition: $isPhaseTransition)
                .frame(width: 300, height: 300)
        }
    }
    
    private func startBreathingExercise() {
        isBreathingExerciseActive = true
        exerciseTimeElapsed = 0
        currentPhase = .inhale
        progress = 0.0
        isPhaseTransition = false
        startTimerForPhase(.inhale)
    }
    
    // Function to handle timer and update progress
    private func startTimerForPhase(_ phase: BreathingPhase) {
        exerciseTimer?.invalidate()
        var secondsElapsed = 0.0
        let totalSeconds = phase.duration
        
        exerciseTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            exerciseTimeElapsed += 1
            secondsElapsed += 0.01
            progress = CGFloat(secondsElapsed) / CGFloat(totalSeconds)
            
            if secondsElapsed >= totalSeconds {
                exerciseTimer?.invalidate()
                isPhaseTransition = true
                switch phase {
                case .inhale:
                    currentPhase = .hold
                    startTimerForPhase(.hold)
                case .hold:
                    currentPhase = .exhale
                    startTimerForPhase(.exhale)
                case .exhale:
                    currentPhase = .inhale
                    startTimerForPhase(.inhale)
                }
            }
        }
    }
    
    
    private func formattedTime(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct Diagram: View {
    @Binding var currentPhase: BreathingPhase
    @Binding var progress: CGFloat
    @Binding var isPhaseTransition: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(phaseColor)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(phaseColor)
                .rotationEffect(Angle(degrees: 270))
                .animation(isPhaseTransition ? nil : .smooth, value: progress)
            
            VStack {
                Text(currentPhase.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("\(currentPhase.duration) seconds")
                    .font(.title2)
            }
        }
        .padding(40)
    }
    
    private var phaseColor: Color {
        switch currentPhase {
        case .inhale:
            return Color.green
        case .hold:
            return Color.yellow
        case .exhale:
            return Color.red
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
