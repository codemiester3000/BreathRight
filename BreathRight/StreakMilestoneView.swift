import SwiftUI

struct StreakMilestoneView: View {
    let streakDays: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var confettiVisible = false
    @State private var textOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.5

    private var reinforcementLine: String {
        switch streakDays {
        case 7:
            return "Consistency beats intensity. Your chemoreceptors are adapting."
        case 14:
            return "Two weeks of daily practice. Your resting breath rate is lowering."
        case 30:
            return "A month of daily practice. Your baseline breathing has changed."
        case 60:
            return "Two months in. Your CO\u{2082} tolerance is measurably different now."
        case 100:
            return "100 days. You've fundamentally rewired your breathing pattern."
        default:
            return "Keep going. Every day strengthens the adaptation."
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { onDismiss() }

            if confettiVisible {
                GoldenConfetti()
            }

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.orange.opacity(0.4), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(glowScale)

                    Circle()
                        .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                        .frame(width: 90, height: 90)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                }

                Text("\(streakDays)-Day Streak!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.homeGoldenAccent)
                    .opacity(textOpacity)

                Text(reinforcementLine)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
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
