import SwiftUI

extension Color {
    static let robinhoodGreen = Color(#colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1))
}


struct ContentView: View {
    
    @State private var isDragging: Bool = false
    
    let minDuration: CGFloat = 2
    let maxDuration: CGFloat = 16
    
    
    @State private var sliderValue: CGFloat
    
    // Test Test
    let minSquareSize: CGFloat = 50
    let maxSquareSize: CGFloat = 250
    
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
            
            
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    CustomSlider(value: $sliderValue, isDragging: $isDragging)
                }
                .padding(.horizontal, 20)
                .frame(height: 40)
                
                HStack {
                    Button(action: {}) {
                        Text("Begin Now")
                            .font(.custom("Inter-Variable", size: 15))
                            .padding()
                            .background(Color.robinhoodGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .padding(.bottom, 125)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
