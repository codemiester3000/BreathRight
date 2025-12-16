import SwiftUI
import AVFoundation

struct BoxBreathingView: View {
    @State private var timer: Timer?
    @State private var currentCountDown: Int = 4
    @State private var isRectangleVisible: Bool = false
    @State private var squareAnimationWorkItem: DispatchWorkItem?
    @State private var isDragging: Bool = false
    @State private var isAnimating: Bool = false
    @State private var completedSides: Int = 0
    @State private var progress: CGFloat = 0
    @State private var sliderValue: CGFloat
    @State private var currentSideElapsedTime: Int = 0
    @State private var isSliderVisible: Bool = true
    @State private var isStopButtonVisible: Bool = false
    @State private var elapsedTime: Int = 0
    @State private var elapsedTimeTimer: Timer?
    @State private var sideToShow: Int = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var breathInstruction: String = "Inhale"
    @State private var showBreathInstruction = false
    @State private var showTooltip: Bool = false
    @State private var isSheetPresented = false
    @State private var showBreathingSelectionPage = false
    @State private var completedCycles = 0
    @State private var flashOpacity: Double = 0
    
    let minDuration: CGFloat = 2
    let maxDuration: CGFloat = 16
    let minSquareSize: CGFloat = 200
    let maxSquareSize: CGFloat = 280
    let topPadding: CGFloat = 100
    let animationTopPadding: CGFloat = 20
    
    /// User Defaults values
    let savedNumCycles = UserDefaults.standard.integer(forKey: "numCycles")
    let savedIsInfinite = UserDefaults.standard.bool(forKey: "unlimtedCycles")
    
    var durationInSeconds: Int {
        Int(minDuration + (maxDuration - minDuration) * sliderValue)
    }
    
    init() {
        let initialValue = (4 - minDuration) / (maxDuration - minDuration)
        _sliderValue = State(initialValue: initialValue)
    }
    
    var body: some View {
        ZStack {
            // Warm gradient background (darker on setup, lighter when animating)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.homeWarmBlueDark,
                    isAnimating ? Color.homeWarmBlue : Color.homeWarmBlueDark.opacity(0.9),
                    isAnimating ? Color.homeWarmBlueLight : Color.homeWarmBlue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut(duration: 1.0), value: isAnimating)

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
                            x: CGFloat((index * 47) % Int(geometry.size.width)),
                            y: CGFloat((index * 97) % Int(geometry.size.height))
                        )
                }
            }

            if isSheetPresented {
                Summary(elapsedTime: self.elapsedTime)
            } else {
                VStack {
                    VStack(spacing: 0) {
                        HStack {
                            if isAnimating {
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
                                            Text(formattedTime(for: elapsedTime))
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

                                    // Breath instruction
                                    BreathView(showText: $showBreathInstruction, instruction: $breathInstruction, duration: Double(durationInSeconds))
                                        .padding(.top, 32)

                                }
                            } else {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Box Breathing")
                                                .font(.system(size: 26, weight: .light, design: .rounded))
                                                .foregroundColor(.white)

                                            HStack(spacing: 8) {
                                                Rectangle()
                                                    .fill(Color.homeWarmAccent.opacity(0.8))
                                                    .frame(width: 12, height: 2)
                                                Text("4-4-4-4 technique")
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
                                            BoxBreathInfo()
                                            Spacer()
                                        }
                                    }

                                    // Subtle separator with accent
                                    HStack(spacing: 0) {
                                        Rectangle()
                                            .fill(Color.homeWarmAccent.opacity(0.6))
                                            .frame(width: 24, height: 1)
                                        Rectangle()
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 1)
                                    }
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
                                    .padding(.top, 20)
                                }


                            }
                            Spacer()
                        }
                        .padding(.top, 50)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // If animation is active, we'll draw the animated square here
                        if isAnimating {
                            VStack {
                                ZStack {
                                    // Faded square
                                    Path { path in
                                        let rounding: CGFloat = 6
                                        let startingPoint = CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding)
                                        path.move(to: startingPoint)
                                        
                                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2 - rounding, y: -animationTopPadding))
                                        path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2 - rounding, y: -animationTopPadding + rounding), radius: rounding, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
                                        
                                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2, y: -animationTopPadding + sizeForSquare - rounding))
                                        path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2 - rounding, y: -animationTopPadding + sizeForSquare - rounding), radius: rounding, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
                                        
                                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding + sizeForSquare))
                                        path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding + sizeForSquare - rounding), radius: rounding, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
                                        
                                        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2, y: -animationTopPadding + rounding))
                                        path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding + rounding), radius: rounding, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
                                        path.addLine(to: startingPoint)
                                    }
                                    //.stroke(Color.white.opacity(0.2), lineWidth: 5)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 5)
                                    .shadow(color: Color.white.opacity(0.3), radius: 10, x: 0, y: 0)
                                    
                                    Path { path in
                                        let rounding: CGFloat = 6
                                        let startingPoint = CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding)
                                        path.move(to: startingPoint)
                                        
                                        if completedSides >= 1 {
                                            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2 - rounding, y: -animationTopPadding))
                                            path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2 - rounding, y: -animationTopPadding + rounding), radius: rounding, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
                                        }
                                        
                                        if completedSides >= 2 {
                                            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2, y: -animationTopPadding + sizeForSquare - rounding))
                                            path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2 - rounding, y: -animationTopPadding + sizeForSquare - rounding), radius: rounding, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
                                        }
                                        
                                        if completedSides >= 3 {
                                            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding + sizeForSquare))
                                            path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding + sizeForSquare - rounding), radius: rounding, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
                                        }
                                        
                                        if completedSides == 4 {
                                            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2, y: -animationTopPadding + rounding))
                                            path.addArc(center: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2 + rounding, y: -animationTopPadding + rounding), radius: rounding, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
                                            path.addLine(to: startingPoint)
                                        }
                                    }
                                    .trim(from: 0, to: progress)
                                    .stroke(Color.white, lineWidth: 5)
                                    .shadow(color: Color.white.opacity(0.5), radius: 5, x: 0, y: 0)
                                    .onAppear {
                                        animateSquareDrawing(sideDuration: durationInSeconds)
                                    }
                                    
                                    //                            animatedText(side: 1, x: UIScreen.main.bounds.width/2, y: -animationTopPadding - 30)
                                    //
                                    //                            animatedText(side: 2, x: UIScreen.main.bounds.width/2 + sizeForSquare/2 + 30, y: -animationTopPadding + sizeForSquare / 2)
                                    //
                                    //                            animatedText(side: 3, x: UIScreen.main.bounds.width/2, y: -animationTopPadding + sizeForSquare + 30)
                                    //
                                    //                            animatedText(side: 4, x: UIScreen.main.bounds.width/2 - sizeForSquare/2 - 30, y: -animationTopPadding + sizeForSquare/2)
                                }
                            }
                            .frame(height: sizeForSquare)
                            .padding(.top, animationTopPadding)
                        }
                        
                        if isRectangleVisible && !isAnimating {
                            VStack {
                                
                                ZStack {
                                    Rectangle()
                                        .stroke(Color.white, lineWidth: 9)
                                        .frame(width: sizeForSquare, height: sizeForSquare)
                                        .cornerRadius(6)
                                        .animation(isDragging ? .none : .easeInOut(duration: 0.5))
                                    
                                    //                                Text("\(durationInSeconds) sec")
                                    //                                    .font(.footnote)
                                    //                                    .foregroundColor(.white)
                                    //                                    .fontWeight(.bold)
                                    //                                    .offset(y: -(sizeForSquare / 2 + 25))
                                    //
                                    //                                Text("\(durationInSeconds)")
                                    //                                    .font(.footnote)
                                    //                                    .foregroundColor(.white)
                                    //                                    .fontWeight(.bold)
                                    //                                    .offset(y: sizeForSquare / 2 + 25)
                                    //
                                    //                                Text("\(durationInSeconds)")
                                    //                                    .font(.footnote)
                                    //                                    .foregroundColor(.white)
                                    //                                    .fontWeight(.bold)
                                    //                                    .offset(x: -(sizeForSquare / 2 + 25))
                                    //
                                    //                                Text("\(durationInSeconds)")
                                    //                                    .font(.footnote)
                                    //                                    .foregroundColor(.white)
                                    //                                    .fontWeight(.bold)
                                    //                                    .offset(x: sizeForSquare / 2 + 25)
                                    
                                }
                            }
                            .frame(height: sizeForSquare)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            if isAnimating {
                                HStack {
                                    Spacer()

                                    Button(action: {
                                        stopAnimationAndReset()
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

                                    Spacer()
                                }
                                
                            } else {
                                
                                
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        
                                        HStack {
                                            CustomSlider(value: $sliderValue, isDragging: $isDragging, timeInSecond: durationInSeconds)
                                            Spacer()
                                        }
                                        .frame(height: 40)
                                        .padding(.bottom, 44)
                                        .padding(.horizontal)
                                        
                                        
                                        GeometryReader { geometry in
                                            Button(action: {
                                                self.elapsedTime = 0

                                                // Start the elapsed time timer
                                                self.elapsedTimeTimer?.invalidate()
                                                self.elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                                    self.elapsedTime += 1
                                                }
                                                isAnimating = true
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
                                    
                                    
                                    
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                
                            }
                            
                        }
                        .padding(.bottom, 25)
                    }
                }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation {
                    isRectangleVisible = true
                }
            }
        }
        //        .sheet(isPresented: $isSheetPresented) {
        //            Summary(elapsedTime: self.elapsedTime)
        //        }
        .onDisappear {
            // Stop and invalidate the timer
            timer?.invalidate()
            elapsedTimeTimer?.invalidate()
            squareAnimationWorkItem?.cancel()
            
            // Stop the audio player
            audioPlayer?.stop()
            
            // Reset any state as needed
            isAnimating = false
            progress = 0
            completedSides = 0
            // ... any other state reset you might need ...
        }
    }
    
    func stopAnimationAndReset() {
        squareAnimationWorkItem?.cancel()
        isAnimating = false
        progress = 0
        completedSides = 0
        isStopButtonVisible = false
        isSliderVisible = true
        
        elapsedTimeTimer?.invalidate()
        timer?.invalidate()
        
        isSheetPresented.toggle()
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
    
    @ViewBuilder
    private func animatedText(side: Int, x: CGFloat, y: CGFloat) -> some View {
        Text("\(currentCountDown)")
            .font(.system(size: 20, weight: .medium))
            .position(x: x, y: y)
            .opacity(sideToShow == side ? 1 : 0)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2))
            .foregroundColor(.white)
    }
    
    
    func animateSquareDrawing(sideDuration: Int) {
        startCountdownTimer()
        
        for i in 1...4 {
            withAnimation(Animation.linear(duration: Double(sideDuration)).delay(Double(i - 1) * Double(sideDuration))) {
                progress += 0.25
                self.completedSides = i
            }
        }
        
        squareAnimationWorkItem = DispatchWorkItem {
            if !self.savedIsInfinite && self.completedCycles >= self.savedNumCycles - 1 {
                self.stopAnimationAndReset()
            }
            
            if self.isAnimating {
                self.completedCycles += 1
                self.flashCyclesText()
                
                self.progress = 0
                self.completedSides = 0
                self.sideToShow = 0
                self.breathInstruction = "Inhale"
                self.animateSquareDrawing(sideDuration: sideDuration)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 * Double(sideDuration) - 0.26, execute: squareAnimationWorkItem!)
    }
    
    func startCountdownTimer() {
        currentCountDown = durationInSeconds
        timer?.invalidate()
        
        self.showBreathInstruction = true
        
        withAnimation(Animation.linear) {
            breathInstruction = "Inhale"
        }
        
        playAudio(named: "Inhale")
        self.sideToShow = 1
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.currentCountDown > 1 {
                self.currentCountDown -= 1
            } else {
                // Display text to the user indicating the current
                // instruction (inhale, hold, exhale)
                self.showBreathInstruction = true
                currentCountDown = durationInSeconds
                self.sideToShow += 1
                
                if sideToShow % 4 == 2 || sideToShow % 4 == 0 {
                    playAudio(named: "Hold")
                    
                    withAnimation(Animation.linear) {
                        breathInstruction = "Hold"
                    }
                    
                }
                
                if sideToShow % 4 == 3 {
                    playAudio(named: "Exhale")
                    
                    withAnimation(Animation.linear) {
                        breathInstruction = "Exhale"
                    }
                }
            }
        }
    }
    
    func formattedTime(for seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d min %02d sec", minutes, remainingSeconds)
    }
    
    
    var sizeForSquare: CGFloat {
        minSquareSize + (maxSquareSize - minSquareSize) * sliderValue
    }
}

struct BreathView: View {
    @Binding var showText: Bool
    @Binding var instruction: String
    let duration: Double
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0

    var body: some View {
        if showText {
            VStack(spacing: 8) {
                Text(instruction)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .transition(.opacity)

                // Subtle indicator line
                Rectangle()
                    .fill(Color.homeWarmAccent.opacity(0.5))
                    .frame(width: 40, height: 2)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 1.0
                }
                animateBasedOnInstruction(instruction)
            }
            .onChange(of: instruction) { newValue in
                if instruction == "Inhale" || instruction == "Exhale" {
                    animateBasedOnInstruction(newValue)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func animateBasedOnInstruction(_ instruction: String) {
        withAnimation(.easeInOut(duration: duration)) {
            switch instruction {
            case "Inhale":
                scale = 1.12
            case "Exhale":
                scale = 0.88
            default:
                scale = 1.0
            }
        }
    }
}

//struct BreathView: View {
//    @Binding var showText: Bool
//    @Binding var instruction: String
//    let duration: Double
//    @State private var scale: CGFloat = 1.0
//    @State private var opacity: Double = 0.0
//    
//    var body: some View {
//        if showText {
//            Text(instruction)
//                .font(.system(.title2, design: .default))
//                .fontWeight(.medium)
//                .scaleEffect(scale)
//                .foregroundColor(.primary)
//                .opacity(opacity)
//                .onAppear {
//                    animateBasedOnInstruction(instruction)
//                }
//                .onChange(of: instruction) { newValue in
//                    animateBasedOnInstruction(newValue)
//                }
//                .transition(.opacity)
//                .padding(16)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.secondary.opacity(0.1))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
//                )
//        }
//    }
//    
//    private func animateBasedOnInstruction(_ instruction: String) {
//        withAnimation(.easeInOut(duration: duration)) {
//            switch instruction {
//            case "Inhale":
//                scale = 1.05
//                opacity = 1.0
//            case "Hold":
//                scale = 1.0
//                opacity = 0.8
//            case "Exhale":
//                scale = 0.95
//                opacity = 1.0
//            default:
//                scale = 1.0
//                opacity = 1.0
//            }
//        }
//    }
//}

struct CustomToggle: View {
    @State private var isOn: Bool = true
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70, height: 27)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0)
                        )
                    
                    Circle()
                        .fill(isOn ? Color.white :  Color.gray.opacity(0.2))
                        .frame(width: 35, height: 35)
                        .offset(x: isOn ? 20 : -20)
                        .onTapGesture {
                            withAnimation {
                                isOn.toggle()
                            }
                        }
                }
                
                Text(isOn ? "Voice A" : "Voice B")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct CustomSlider: View {
    @Binding var value: CGFloat
    @Binding var isDragging: Bool
    var timeInSecond: Int
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 80
    let thumbSize: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.homeWarmAccent.opacity(0.8))
                    Text("Breath duration")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Text("\(timeInSecond) sec")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .frame(width: geometry.size.width, height: 2)
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
                        .frame(width: geometry.size.width * value, height: 2)

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
                    .position(x: geometry.size.width * value, y: geometry.size.height / 2)
                    .gesture(
                        DragGesture().onChanged { gesture in
                            self.value = min(max(gesture.location.x / geometry.size.width, 0), 1)
                            self.isDragging = true
                        }.onEnded { _ in
                            self.isDragging = false
                        }
                    )
                }
            }
            .frame(width: sliderWidth, height: 24)
        }
    }
}




extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

