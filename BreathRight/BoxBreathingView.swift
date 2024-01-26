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
                                VStack(alignment: .leading)  {
                                    HStack {
                                        Text(formattedTime(for: elapsedTime))
                                            .font(.footnote)
                                            .padding(8)  // Small padding around the text
                                            .background(
                                                Color.gray.opacity(0.2)
                                                    .cornerRadius(8)
                                            )
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        //                                        Image(systemName: "square")
                                        //                                            .resizable()
                                        //                                            .aspectRatio(contentMode: .fit)
                                        //                                            .frame(width: 24, height: 24)
                                        //                                            .foregroundColor(.white)
                                        
                                        // todo: put the cycles count here:
                                        
                                        Text("\(completedCycles) of \(savedIsInfinite ? "∞" : "\(savedNumCycles)") cycles")
                                            .font(.footnote)
                                            .padding(8)  // Small padding around the text
                                            .background(
                                                Color.gray.opacity(0.2)
                                                    .cornerRadius(8)
                                            )
                                            .foregroundColor(.white)

                                    }
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                        .padding(.horizontal, 5)
                                        .padding(.top, 20)
                                    
                                    BreathView(showText: $showBreathInstruction, instruction: $breathInstruction, duration: Double(durationInSeconds))
                                        .padding(.top, 40)
                                        .padding(.leading, 4)
                                    
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Box Breathing")
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
                                            BoxBreathInfo()
                                            Spacer()
                                        }
                                        .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 1)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 20)
                                    
                                    HStack {
                                        Image(systemName: "arrow.3.trianglepath").foregroundColor(.white)
                                        Text(savedIsInfinite ? "∞ cycles"  : "\(savedNumCycles) cycles")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
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
                                    .stroke(Color.white.opacity(0.2), lineWidth: 5)
                                    
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
                                    Button("Stop") {
                                        stopAnimationAndReset()
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding(.horizontal, 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .background(Color.lighterBlue.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.leading, 24)
                                    
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
                                                self.elapsedTimeTimer?.invalidate()  // Invalidate any existing timer first
                                                self.elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                                    self.elapsedTime += 1
                                                }
                                                isAnimating = true
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
            .font(.custom("Inter-Variable", size: 20))
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
    
    var body: some View {
        if showText {
            Text("\(instruction)")
                .font(.custom("Inter-Variable", size: 20))
                .transition(.opacity)
                .foregroundColor(.white)
        }
    }
}

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
                    .font(.custom("Inter-Variable", size: 15))
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct CustomSlider: View {
    @Binding var value: CGFloat
    @Binding var isDragging: Bool
    var timeInSecond: Int
    let trackColor = Color.backgroundBeige.opacity(0.5)
    let thumbColor = Color.white
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 80
    let thumbSize: CGFloat = 20 // smaller thumb for a minimalist look
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "heart.square").foregroundColor(.white)
                
                Text("Adjust Breath Duration") // The text label
                    .font(.system(size: 16)) // You can adjust the font size and style
                    .foregroundColor(.white) // Text color, adjust as needed
                    .frame(alignment: .leading) // Left aligned
                
                Spacer()
                
                Text("\(timeInSecond) Sec") // The text label
                    .font(.system(size: 16)) // You can adjust the font size and style
                    .foregroundColor(.white) // Text color, adjust as needed
                    .frame(alignment: .leading) // Left aligned
                    .padding(.trailing, 12)
            }
            .padding(.bottom, 24)
            
            HStack(alignment: .center, spacing: 10) { // Added alignment and spacing
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule() // sleek and modern shape
                            .frame(width: geometry.size.width, height: 3) // thinner track
                            .foregroundColor(trackColor)
                        
                        Capsule()
                            .frame(width: geometry.size.width * value, height: 3)
                            .foregroundColor(thumbColor)
                        
                        Circle() // keeping the thumb circular for a clean look
                            .frame(width: thumbSize, height: thumbSize)
                            .foregroundColor(thumbColor)
                            .position(x: geometry.size.width * value, y: geometry.size.height / 2)
                        // drag gesture remains the same
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
                .frame(width: sliderWidth)
            }
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

