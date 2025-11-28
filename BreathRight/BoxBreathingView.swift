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
            LinearGradient(gradient: Gradient(colors: [Color.lighterBlue, isAnimating ? Color.myTurqoise : Color.lighterBlue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 1.0), value: isAnimating)
            
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
                                        .opacity(0.8)

                                    // Stats pills row
                                    HStack {
                                        // Time pill
                                        HStack(spacing: 6) {
                                            Image(systemName: "clock")
                                                .font(.system(size: 11, weight: .medium))
                                            Text(formattedTime(for: elapsedTime))
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

                                    // Breath instruction
                                    BreathView(showText: $showBreathInstruction, instruction: $breathInstruction, duration: Double(durationInSeconds))
                                        .padding(.top, 32)

                                }
                            } else {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        Text("Box Breathing")
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
                                            BoxBreathInfo()
                                            Spacer()
                                        }

                                        Spacer()
                                    }

                                    // Subtle separator
                                    Rectangle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 1)
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
            Text(instruction)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(scale)
                .opacity(opacity)
                .transition(.opacity)
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
                scale = 1.15
            case "Exhale":
                scale = 0.85
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
    let trackColor = Color.white.opacity(0.2)
    let thumbColor = Color.white
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 80
    let thumbSize: CGFloat = 18

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text("Breath duration")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Text("\(timeInSecond) sec")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }

            // Slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .frame(width: geometry.size.width, height: 2)
                        .foregroundColor(trackColor)

                    // Track fill
                    Capsule()
                        .frame(width: geometry.size.width * value, height: 2)
                        .foregroundColor(thumbColor)

                    // Thumb
                    Circle()
                        .fill(thumbColor)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
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

