import SwiftUI

struct Summary: View {
    let elapsedTime: Int

    @Environment(\.presentationMode) var presentationMode

    // Animation states
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var particlesVisible = false

    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return "\(minutes) min \(seconds) sec"
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.lighterBlue, Color.myTurqoise]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            // Floating particles background
            if particlesVisible {
                FloatingParticles()
            }

            VStack(spacing: 0) {
                Spacer()

                // Animated success icon
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 130, height: 130)
                        .scaleEffect(pulseScale)
                        .opacity(2 - Double(pulseScale))

                    // Main circle background
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Checkmark
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.white)
                        .scaleEffect(checkmarkScale)
                        .opacity(checkmarkOpacity)
                }
                .padding(.bottom, 32)

                // Title
                Text("Session Complete")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                // Subtitle
                Text("Great work on your breathing practice")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 32)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                // Stats card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text("Duration")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text(formattedTime)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 32)
                .opacity(contentOpacity)
                .offset(y: contentOffset)

                Spacer()

                // Dismiss button
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.15))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(contentOpacity)
            }
        }
        .onAppear {
            startCompletionAnimation()
        }
    }

    private func startCompletionAnimation() {
        // Show particles
        particlesVisible = true

        // Ring appears
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }

        // Checkmark bounces in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
            checkmarkScale = 1.0
            checkmarkOpacity = 1.0
        }

        // Pulse animation
        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.3)) {
            pulseScale = 1.8
        }

        // Content fades in
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            contentOpacity = 1.0
            contentOffset = 0
        }
    }
}

// Floating particles for celebration effect
struct FloatingParticles: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { index in
                FloatingParticle(
                    size: CGFloat.random(in: 4...8),
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    delay: Double.random(in: 0...2)
                )
            }
        }
    }
}

struct FloatingParticle: View {
    let size: CGFloat
    let startX: CGFloat
    let delay: Double

    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .frame(width: size, height: size)
            .position(x: startX, y: UIScreen.main.bounds.height + 50)
            .offset(y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 4).delay(delay)) {
                    yOffset = -UIScreen.main.bounds.height - 100
                    opacity = 0.6
                }
                withAnimation(.easeIn(duration: 1).delay(delay + 3)) {
                    opacity = 0
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
