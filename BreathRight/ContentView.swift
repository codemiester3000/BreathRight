import SwiftUI
import AVFoundation

extension Color {
    static let robinhoodGreen = Color(#colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1))
}


struct ContentView: View {
    
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
    
    let minDuration: CGFloat = 2
    let maxDuration: CGFloat = 16
    let minSquareSize: CGFloat = 200
    let maxSquareSize: CGFloat = 280
    let topPadding: CGFloat = 100
    let animationTopPadding: CGFloat = 20
    
    var durationInSeconds: Int {
        Int(minDuration + (maxDuration - minDuration) * sliderValue)
    }
    
    init() {
        let initialValue = (4 - minDuration) / (maxDuration - minDuration)
        _sliderValue = State(initialValue: initialValue)
        //        for family: String in UIFont.familyNames {
        //            print("\(family)")
        //            for names: String in UIFont.fontNames(forFamilyName: family) {
        //                print("== \(names)")
        //            }
        //        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    if isAnimating {
                        VStack(alignment: .leading)  {
                            BreathView(showText: $showBreathInstruction, instruction: $breathInstruction, duration: Double(durationInSeconds))
                                .padding(.top, 4)
                            Text(formattedTime(for: elapsedTime))
                                .font(.custom("Inter-Variable", size: 15))
                                .padding(.top, 4)
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("Box Breathing")
                                .font(.custom("Inter-Variable", size: 30))
                            Text("Configure your settings and press start to begin")
                                .font(.custom("Inter-Variable", size: 15))
                                .multilineTextAlignment(.leading)
                                .padding(.top, 4)
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
                            .stroke(Color.robinhoodGreen, lineWidth: 5)
                            .onAppear {
                                animateSquareDrawing(sideDuration: durationInSeconds)
                            }
                            
                            
                            animatedText(side: 1, x: UIScreen.main.bounds.width/2, y: -animationTopPadding - 30)
                            
                            animatedText(side: 2, x: UIScreen.main.bounds.width/2 + sizeForSquare/2 + 30, y: -animationTopPadding + sizeForSquare / 2)
                            
                            animatedText(side: 3, x: UIScreen.main.bounds.width/2, y: -animationTopPadding + sizeForSquare + 30)
                            
                            animatedText(side: 4, x: UIScreen.main.bounds.width/2 - sizeForSquare/2 - 30, y: -animationTopPadding + sizeForSquare/2)
                            

                        }
                    }
                    .frame(height: sizeForSquare)
                    .padding(.top, animationTopPadding)
                }
                
                if isRectangleVisible && !isAnimating {
                    VStack {
                        ZStack {
                            Rectangle()
                                .stroke(Color.robinhoodGreen, lineWidth: 7)
                                .frame(width: sizeForSquare, height: sizeForSquare)
                                .cornerRadius(6)
                                .animation(isDragging ? .none : .easeInOut(duration: 0.5))
                            
                            Text("\(durationInSeconds) sec")
                                .font(.custom("Inter-Variable", size: 18))
                                .offset(y: -(sizeForSquare / 2 + 20))
                            
                            Text("\(durationInSeconds)")
                                .font(.custom("Inter-Variable", size: 18))
                                .offset(y: sizeForSquare / 2 + 20)
                            
                            Text("\(durationInSeconds)")
                                .font(.custom("Inter-Variable", size: 18))
                                .offset(x: -(sizeForSquare / 2 + 20))
                            
                            Text("\(durationInSeconds)")
                                .font(.custom("Inter-Variable", size: 18))
                                .offset(x: sizeForSquare / 2 + 20)
                        }
                    }
                    .frame(height: sizeForSquare)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    if isAnimating {
                        HStack {
                            Button("Stop") {
                                squareAnimationWorkItem?.cancel()
                                isAnimating = false // stop the animation
                                progress = 0
                                completedSides = 0
                                isStopButtonVisible = false
                                isSliderVisible = true
                                
                                self.elapsedTimeTimer?.invalidate()
                                timer?.invalidate()
                            }
                            .font(.custom("Inter-Variable", size: 20))
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    } else {
                        HStack {
                            CustomSlider(value: $sliderValue, isDragging: $isDragging)
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 40)
                        
//                        CustomToggle()
//                            .padding(20)
                        
                        HStack {
                            Button("Begin Now") {
                                self.elapsedTime = 0
                                
                                // Start the elapsed time timer
                                self.elapsedTimeTimer?.invalidate()  // Invalidate any existing timer first
                                self.elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                    self.elapsedTime += 1
                                }
                                isAnimating = true
                            }
                            .font(.custom("Inter-Variable", size: 20))
                            .padding()
                            .background(Color.robinhoodGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                }
                .padding(.bottom, 75)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    isRectangleVisible = true
                }
            }
        }
    }
    
    func playAudio(named fileName: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Error playing the audio")
            }
        }
    }
    
    
    @ViewBuilder
    private func animatedText(side: Int, x: CGFloat, y: CGFloat) -> some View {
        Text("\(currentCountDown)")
            .font(.custom("Inter-Variable", size: 24))
            .position(x: x, y: y)
            .opacity(sideToShow == side ? 1 : 0)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2))
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
            if self.isAnimating {
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
                .font(.custom("Inter-Variable", size: 30))
                .transition(.opacity)
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
                        .fill(isOn ? Color.robinhoodGreen :  Color.gray.opacity(0.2))
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
    let trackColor = Color.gray.opacity(0.2)
    let thumbColor = Color.robinhoodGreen
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 60
    let thumbSize: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: geometry.size.width, height: 5)
                    .foregroundColor(trackColor)
                
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: geometry.size.width * value, height: 5)
                    .foregroundColor(thumbColor)
                
                Circle()
                    .frame(width: thumbSize, height: thumbSize)
                    .foregroundColor(thumbColor)
                    .position(x: geometry.size.width * value, y: geometry.size.height / 2)
                    .gesture(
                        DragGesture().onChanged { gesture in
                            self.value = min(max(gesture.location.x / geometry.size.width, 0), 1)
                            self.isDragging = true  // user has started dragging
                        }.onEnded { _ in
                            self.isDragging = false  // user has ended dragging
                        }
                    )
            }
        }
        .frame(width: sliderWidth)
    }
}
