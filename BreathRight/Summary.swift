import SwiftUI

struct Summary: View {
    let elapsedTime: Int
    @State private var animationProgress: CGFloat = 0.0
    
    @Environment(\.presentationMode) var presentationMode
    
    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return "\(minutes) min \(seconds) sec"
    }
    
    var body: some View {
        ZStack {
            
            ConfettiAnimation()
            
            LinearGradient(gradient: Gradient(colors: [Color.deepBlue, Color.lighterBlue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                VStack(alignment: .leading) {
                    
                    HStack {
                        Text("Session Complete")
                            .font(.custom("Inter-Variable", size: 20))
                            .padding(.top)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                    
                    Text("Time completed: \(formattedTime)")
                        .font(.footnote)
                        .padding(16)
                        .background(
                            Color.gray.opacity(0.2)
                                .cornerRadius(8)
                        )
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    //Spacer()
                    
                    ForEach(0..<48, id: \.self) { _ in
                        AnimatedSquareView(size: 50)
                                        .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                                  y: CGFloat.random(in: 0...UIScreen.main.bounds.height - 100))
                                }
                    
                    Spacer()
                    
                    // Spacer()
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Dismiss")
                            .font(.footnote)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                }
                .padding()
                .padding(.bottom, 16)
                
                Spacer()
            }
        }
    }
}

struct DrawingSquareModifier: AnimatableModifier {
    var progress: CGFloat
    let size: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.overlay(
            Path { path in
                let start = CGPoint(x: 0, y: 0)
                path.move(to: start)

                // Define points for square sides
                let points = [
                    CGPoint(x: size, y: 0), // Top side
                    CGPoint(x: size, y: size), // Right side
                    CGPoint(x: 0, y: size), // Bottom side
                    CGPoint(x: 0, y: 0) // Left side
                ]

                let fullLength = points.count + 1 // Complete cycle length
                let currentSide = Int(progress)
                let sideProgress = progress - CGFloat(currentSide)

                for i in 0..<points.count {
                    if i < currentSide {
                        path.addLine(to: points[i])
                    } else if i == currentSide {
                        let interpolation = interpolate(from: path.currentPoint!, to: points[i], progress: sideProgress)
                        path.addLine(to: interpolation)
                        break
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        )
    }

    // Interpolate between two points
    private func interpolate(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: from.x + (to.x - from.x) * progress,
            y: from.y + (to.y - from.y) * progress
        )
    }
}

struct AnimatedSquareView: View {
    var size: CGFloat
    @State private var drawProgress: CGFloat = 0

    var body: some View {
        Rectangle()
            .background(.clear)
            .foregroundColor(.clear)
            .frame(width: size, height: size)
            .modifier(DrawingSquareModifier(progress: drawProgress, size: size))
            .onAppear {
                withAnimation(Animation.linear(duration: 4).repeatCount(1)) {
                    drawProgress = 4 // Each side + return to start
                }
            }
    }
}
