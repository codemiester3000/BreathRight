import SwiftUI

extension Color {
    static let robinhoodGreen = Color(#colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1))
}


struct ContentView: View {
    
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
    
    let minDuration: CGFloat = 2
    let maxDuration: CGFloat = 16
    let minSquareSize: CGFloat = 50
    let maxSquareSize: CGFloat = 250
    let topPadding: CGFloat = 100
    
    var durationInSeconds: Int {
        Int(minDuration + (maxDuration - minDuration) * sliderValue)
    }
    
    init() {
        let initialValue = (4 - minDuration) / (maxDuration - minDuration)
        _sliderValue = State(initialValue: initialValue)
        
        for family: String in UIFont.familyNames {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Box Breathing")
                            .font(.custom("Inter-Variable", size: 30))
                        Text("Configure your settings and press start to begin")
                            .font(.custom("Inter-Variable", size: 15))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 4)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // If animation is active, we'll draw the animated square here
                if isAnimating {
                    
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2, y: 100))
                            if completedSides >= 1 {
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2, y: 100))
                            }
                            if completedSides >= 2 {
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 + sizeForSquare/2, y: 100 + sizeForSquare))
                            }
                            if completedSides >= 3 {
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2, y: 100 + sizeForSquare))
                            }
                            if completedSides == 4 {
                                path.addLine(to: CGPoint(x: UIScreen.main.bounds.width/2 - sizeForSquare/2, y: 100))
                            }
                        }
                        .trim(from: 0, to: progress)
                        .stroke(Color.robinhoodGreen, lineWidth: 5)
                        .onAppear {
                            animateSquareDrawing(sideDuration: durationInSeconds)
                        }
                        .padding(.top, 60)
                        
                        switch completedSides {
                        case 1:
                            Text("\(4)")
                                .position(x: UIScreen.main.bounds.width/2 , y: 100 + 60)
                        case 2:
                            Text("\(4)")
                                .position(x: UIScreen.main.bounds.width/2 + sizeForSquare/2, y: 100 + sizeForSquare / 2 + 60)
                        case 3:
                            Text("\(4)")
                                .position(x: UIScreen.main.bounds.width/2, y: 100 + sizeForSquare + 60)
                        case 4:
                            Text("\(4)")
                                .position(x: UIScreen.main.bounds.width/2, y: 100 + 60)
                        default:
                            EmptyView()
                        }
                    }
                    
                }
                
                if isRectangleVisible && !isAnimating {
                    VStack {
                        ZStack {
                            Rectangle()
                                .stroke(Color.robinhoodGreen, lineWidth: 4)
                                .frame(width: sizeForSquare, height: sizeForSquare)
                                .animation(isDragging ? .none : .easeInOut(duration: 0.5))
                            
                            Text("\(durationInSeconds) sec")
                                .offset(y: -(sizeForSquare / 2 + 20))
                            
                            Text("\(durationInSeconds)")
                                .offset(y: sizeForSquare / 2 + 20)
                            
                            Text("\(durationInSeconds)")
                                .offset(x: -(sizeForSquare / 2 + 20))
                            
                            Text("\(durationInSeconds)")
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
                            }
                            .font(.custom("Inter-Variable", size: 20))
                            .padding()
                            .background(Color.red)
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
                        
                        HStack {
                            Button("Begin Now") {
                                // When user clicks "Begin Now", we'll start the square drawing animation
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
                .padding(.bottom, 125)
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
    
    func animateSquareDrawing(sideDuration: Int) {
        for i in 1...4 {
            withAnimation(Animation.linear(duration: Double(sideDuration)).delay(Double(i - 1) * Double(sideDuration))) {
                progress += 0.25
                completedSides = i
            }
        }
        
        squareAnimationWorkItem = DispatchWorkItem {
            if self.isAnimating {
                self.progress = 0
                self.completedSides = 0
                self.animateSquareDrawing(sideDuration: sideDuration)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 * Double(sideDuration), execute: squareAnimationWorkItem!)
    }
    
    
    var sizeForSquare: CGFloat {
        minSquareSize + (maxSquareSize - minSquareSize) * sliderValue
    }
    
}

struct CustomSlider: View {
    @Binding var value: CGFloat
    @Binding var isDragging: Bool
    let trackColor = Color.gray.opacity(0.2)
    let thumbColor = Color.robinhoodGreen
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 40
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
