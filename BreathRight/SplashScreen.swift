import SwiftUI

// Warmer blue color palette
extension Color {
    static let warmBlue = Color(red: 0.2, green: 0.45, blue: 0.65)
    static let warmBlueLight = Color(red: 0.35, green: 0.55, blue: 0.75)
    static let warmBlueDark = Color(red: 0.12, green: 0.3, blue: 0.5)
    static let warmAccent = Color(red: 0.4, green: 0.7, blue: 0.85)
}

struct SplashScreen: View {
    var onFinished: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var logoOffset: CGFloat = -20
    @State private var circleScale: CGFloat = 0.6
    @State private var circleOpacity: Double = 0
    @State private var waveOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.4
    @State private var particleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Warm gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.warmBlueDark, Color.warmBlue, Color.warmBlueLight]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // Animated background particles
            GeometryReader { geometry in
                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: CGFloat.random(in: 4...12), height: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(particleOpacity)
                }
            }

            // Technical grid lines (subtle)
            VStack(spacing: 40) {
                ForEach(0..<8, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.03))
                        .frame(height: 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Central breathing animation
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(Color.warmAccent.opacity(pulseOpacity * 0.5), lineWidth: 1)
                    .frame(width: 180, height: 180)
                    .scaleEffect(pulseScale)

                // Middle ring
                Circle()
                    .stroke(Color.warmAccent.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 140, height: 140)
                    .scaleEffect(circleScale)
                    .opacity(circleOpacity)

                // Inner glow circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.warmAccent.opacity(0.4), Color.warmAccent.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(circleScale)
                    .opacity(circleOpacity)

                // Animated sine wave inside circle
                SplashWave(offset: waveOffset)
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    .frame(width: 80, height: 30)
                    .opacity(circleOpacity)
            }

            // App name in upper left
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("uBreathe")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(.white)

                        // Technical subtitle
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(Color.warmAccent)
                                .frame(width: 12, height: 2)
                            Text("breathwork")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .opacity(logoOpacity)
                    .offset(y: logoOffset)

                    Spacer()
                }
                .padding(.leading, 28)
                .padding(.top, 60)

                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Logo fade in
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1.0
            logoOffset = 0
        }

        // Particles fade in
        withAnimation(.easeIn(duration: 1.2)) {
            particleOpacity = 1.0
        }

        // Circle scale up
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            circleScale = 1.0
            circleOpacity = 1.0
        }

        // Continuous wave animation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            waveOffset = .pi * 2
        }

        // Continuous pulse animation
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
            pulseOpacity = 0
        }

        // Transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onFinished()
        }
    }
}

// Animated wave shape for splash
struct SplashWave: Shape {
    var offset: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height / 2

        for x in stride(from: 0, through: width, by: 1) {
            let relX = x / width
            let y = midY + sin(relX * .pi * 2 + offset) * (height * 0.4)

            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}
