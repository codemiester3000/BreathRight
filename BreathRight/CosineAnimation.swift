import SwiftUI

struct CosineAnimation: View {
    @State private var phaseShift: CGFloat = 0.0

    var body: some View {
        ZStack {
            // The actual animated wave
            SineWave(phaseShift: phaseShift)
                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                .mask(
                    // Refined gradient mask for smoother fading
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.4), location: 0.25),
                            .init(color: .white, location: 0.6),
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

        }
        .frame(height: 55)
        .padding(.horizontal)
        .onAppear() {
            // Randomized delay for organic feel
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.1...2.5)) {
                withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                    phaseShift = 2 * .pi  // One full cycle to the right
                }
            }
        }
    }
    
    struct SineWave: Shape {
        var phaseShift: CGFloat
        
        var animatableData: CGFloat {
            get { phaseShift }
            set { phaseShift = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let width = Double(rect.width)
            let height = Double(rect.height)
            let midHeight = height / 2
            
            let amplitude = 0.5 * height - 5 // Adjust this value for higher or lower waves
            
            for x in stride(from: 0, through: width, by: 1) {
                let relX = x / width
                
                let y = Double(midHeight) + amplitude * sin(2 * .pi * relX + Double(phaseShift))
                
                if x == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            return path
        }
    }
}
