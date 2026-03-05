import SwiftUI

struct TierUpView: View {
    let tierName: String
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var confettiVisible = false
    @State private var textOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.5

    private var tierBenefits: String {
        guard let tier = BOLTTier(rawValue: tierName) else { return "" }
        return tier.benefitsDescription
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

                    Image(systemName: "lungs.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.homeGoldenAccent)
                }

                Text("New Tier: \(tierName)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.homeGoldenAccent)
                    .opacity(textOpacity)

                Text(tierBenefits)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
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
