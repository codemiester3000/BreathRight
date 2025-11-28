import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var breathScale: CGFloat = 0.8
    @State private var breathOpacity: Double = 0.3
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20

    var body: some View {
        if isActive {
            NavigationView {
                HomeView()
            }
            .accentColor(.white)
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lighterBlue, Color.myTurqoise]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    Spacer()

                    // Animated breathing circle
                    ZStack {
                        // Outer pulsing ring
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 140, height: 140)
                            .scaleEffect(ringScale)
                            .opacity(ringOpacity)

                        // Middle ring
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            .frame(width: 110, height: 110)
                            .scaleEffect(breathScale)

                        // Inner breathing circle
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(breathScale)
                            .opacity(breathOpacity)

                        // Center dot
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .opacity(breathOpacity + 0.3)
                    }
                    .padding(.bottom, 48)

                    // App name
                    Text("BreathRight")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .offset(y: textOffset)

                    // Tagline
                    Text("Breathe. Focus. Relax.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        .padding(.top, 8)

                    Spacer()
                    Spacer()
                }
            }
            .onAppear {
                startAnimations()
            }
        }
    }

    private func startAnimations() {
        // Breathing circle animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            breathScale = 1.1
            breathOpacity = 0.6
        }

        // Outer ring pulse
        withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
            ringScale = 1.3
            ringOpacity = 0
        }

        // Initial ring visibility
        ringOpacity = 0.4

        // Text fade in
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            textOpacity = 1.0
            textOffset = 0
        }

        // Transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }
}
