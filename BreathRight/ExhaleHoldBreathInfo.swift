import SwiftUI

struct ExhaleHoldBreathInfo: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.homeWarmBlueDark, Color.homeWarmBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 16)

                    // Title
                    Text("Exhale Hold")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 8)

                    // Hook line
                    Text("Train your body\u{2019}s CO\u{2082} tolerance to unlock better breathing, endurance, and calm.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // MARK: The Science
                    sectionDivider("the science")
                        .padding(.top, 28)

                    StudyCard(
                        finding: "Breath-hold training increases CO\u{2082} chemoreceptor tolerance, improving the ventilatory response threshold \u{2014} the exact physiological mechanism that BOLT score measures.",
                        citation: "— Delapille et al., Respiration Physiology, 2001"
                    )
                    .padding(.top, 14)

                    StudyCard(
                        finding: "Regular breath-hold practice stimulates erythropoietin (EPO) production and improves oxygen transport efficiency in trained individuals.",
                        citation: "— Djarova et al., European Journal of Applied Physiology, 2020"
                    )
                    .padding(.top, 10)

                    StudyCard(
                        finding: "Buteyko breathing method clinical trials demonstrated reduced asthma symptoms, decreased medication use, and improved nasal breathing capacity.",
                        citation: "— Cowie et al., New Zealand Medical Journal, 2008"
                    )
                    .padding(.top, 10)

                    // MARK: How It Works
                    sectionDivider("how it works")
                        .padding(.top, 28)

                    VStack(alignment: .leading, spacing: 14) {
                        MechanismRow(number: 1, icon: "wind", text: "Exhale removes O\u{2082} reserve, creating a controlled CO\u{2082} challenge")
                        MechanismRow(number: 2, icon: "timer", text: "Hold after exhale trains chemoreceptors to tolerate higher CO\u{2082}")
                        MechanismRow(number: 3, icon: "arrow.triangle.2.circlepath", text: "Recovery breathing restores gas balance")
                        MechanismRow(number: 4, icon: "chart.line.uptrend.xyaxis", text: "Over time, this resets your CO\u{2082} tolerance set-point higher")
                    }
                    .padding(.top, 14)

                    // MARK: Who Uses This
                    sectionDivider("who uses this")
                        .padding(.top, 28)

                    HStack(spacing: 8) {
                        ForEach(["Freedivers", "Buteyko", "Altitude Training"], id: \.self) { user in
                            Text(user)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                        }
                    }
                    .padding(.top, 14)

                    // MARK: Optimal Protocol
                    sectionDivider("optimal protocol")
                        .padding(.top, 28)

                    VStack(alignment: .leading, spacing: 10) {
                        protocolRow(label: "Start", value: "Comfortable hold duration")
                        protocolRow(label: "Progression", value: "Increase gradually over time")
                        protocolRow(label: "Cycles", value: "3\u{2013}6 per session")
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    )
                    .padding(.top, 14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func sectionDivider(_ text: String) -> some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(Color.homeGoldenAccent)
                .frame(width: 20, height: 1.5)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.45))
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }

    private func protocolRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}
