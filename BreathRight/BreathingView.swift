import SwiftUI

struct BreathingView: View {
    var durationInSeconds: Double
    var sizeForSquare: CGFloat

    @State private var completedSides: Int = 0
    @State private var progress: CGFloat = 0
    @State private var fadeOut: Bool = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            Path { path in
                path.move(to: CGPoint(x: 100, y: 100))
                if completedSides >= 1 {
                    path.addLine(to: CGPoint(x: 100 + sizeForSquare, y: 100))
                }
                if completedSides >= 2 {
                    path.addLine(to: CGPoint(x: 100 + sizeForSquare, y: 100 + sizeForSquare))
                }
                if completedSides >= 3 {
                    path.addLine(to: CGPoint(x: 100, y: 100 + sizeForSquare))
                }
                if completedSides == 4 {
                    path.addLine(to: CGPoint(x: 100, y: 100))
                }
            }
            .trim(from: 0, to: progress)
            .stroke(Color.blue, lineWidth: 5)
            .onAppear {
                animateSquareDrawing()
            }
        }
    }
    
    func animateSquareDrawing() {
        for i in 1...4 {
            withAnimation(Animation.linear(duration: durationInSeconds).delay(Double(i - 1) * durationInSeconds)) {
                progress += 0.25
                completedSides = i
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4 * durationInSeconds) {
            resetDrawing()
        }
    }
    
    func resetDrawing() {
        progress = 0
        completedSides = 0
        animateSquareDrawing()
    }
}
