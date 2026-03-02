import SwiftUI

struct LevelUpView: View {
    let levelName: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var confettiVisible = false
    @State private var textOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { onDismiss() }

            // Golden confetti
            if confettiVisible {
                GoldenConfetti()
            }

            // Level up card
            VStack(spacing: 20) {
                // Glow ring
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.homeGoldenAccent.opacity(0.4), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(glowScale)

                    Circle()
                        .stroke(Color.homeGoldenAccent.opacity(0.6), lineWidth: 2)
                        .frame(width: 90, height: 90)

                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.homeGoldenAccent)
                }

                Text("Level Up!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.homeGoldenAccent)
                    .opacity(textOpacity)

                Text(levelName)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(textOpacity)

                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.homeWarmBlueDark)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.homeGoldenAccent)
                        .clipShape(Capsule())
                }
                .opacity(textOpacity)
                .padding(.top, 10)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            confettiVisible = true

            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                glowScale = 1.3
            }
        }
    }
}

// Golden-themed confetti for level up
struct GoldenConfetti: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<40, id: \.self) { i in
                GoldenConfettiPiece(
                    startX: CGFloat.random(in: 0...geo.size.width),
                    delay: Double.random(in: 0...1.5),
                    size: CGFloat.random(in: 4...10)
                )
            }
        }
    }
}

struct GoldenConfettiPiece: View {
    let startX: CGFloat
    let delay: Double
    let size: CGFloat

    @State private var yOffset: CGFloat = -100
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    private var color: Color {
        [Color.homeGoldenAccent, Color.homeGoldenAccent.opacity(0.7), Color.white.opacity(0.8), Color.homeWarmAccent].randomElement()!
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: size, height: size * 0.4)
            .position(x: startX, y: 0)
            .offset(y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 2.5).delay(delay)) {
                    yOffset = UIScreen.main.bounds.height + 50
                    rotation = Double.random(in: -360...360)
                }
                withAnimation(.easeIn(duration: 0.5).delay(delay + 2.0)) {
                    opacity = 0
                }
            }
    }
}
