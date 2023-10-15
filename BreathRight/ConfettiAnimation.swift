import SwiftUI

struct ConfettiAnimation: View {
    @State private var animationEnd = false
    
    let confettiColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    func randomConfetti() -> some View {
        ConfettiPiece(color: confettiColors.randomElement() ?? .red, size: CGSize(width: 10, height: 4))
            .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: animationEnd ? UIScreen.main.bounds.height * CGFloat.random(in: 0.1...0.3) : UIScreen.main.bounds.height + CGFloat.random(in: 0...100))
            .rotationEffect(animationEnd ? .degrees(Double.random(in: -90...90)) : .degrees(0.0))
            .opacity(animationEnd ? 0.3 : 1)
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<200) { _ in
                randomConfetti()
            }
        }
        .onAppear() {
            withAnimation(Animation.easeOut(duration: 3.0).repeatForever(autoreverses: false)) {
                animationEnd.toggle()
            }
        }
    }
}


struct ConfettiPiece: View {
    let color: Color
    let size: CGSize
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size.width, height: size.height)
            .cornerRadius(2)
    }
}

