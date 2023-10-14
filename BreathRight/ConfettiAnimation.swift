import SwiftUI

struct ConfettiAnimation: View {
    @State private var animationEnd = false
    
    let confettiColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    func randomConfetti() -> some View {
        ConfettiPiece(color: confettiColors.randomElement() ?? .red, size: CGSize(width: 10, height: 4))
            .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: animationEnd ? -30 : UIScreen.main.bounds.height + 30)
            .rotationEffect(.degrees(Double.random(in: 0...360)))
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<100) { _ in
                randomConfetti()
            }
        }
        .onAppear() {
            withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
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

