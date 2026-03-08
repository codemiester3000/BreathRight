import SwiftUI

struct CustomBreathInfo: View {
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
                    Text("Custom Breathing")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 8)

                    // Hook line
                    Text("The best breathing exercise is the one you do daily. Build your own rhythm.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // MARK: The Science
                    sectionDivider("the science")
                        .padding(.top, 28)

                    StudyCard(
                        finding: "Any controlled breathing pattern below 10 breaths per minute consistently increases heart rate variability, regardless of specific inhale-exhale ratios.",
                        citation: "— Zaccaro et al., Frontiers in Human Neuroscience, 2018"
                    )
                    .padding(.top, 14)

                    StudyCard(
                        finding: "Self-paced breathing protocols maintain long-term adherence while delivering equivalent autonomic benefits compared to fixed-ratio techniques.",
                        citation: "— Gerritsen & Band, Frontiers in Human Neuroscience, 2018"
                    )
                    .padding(.top, 10)

                    StudyCard(
                        finding: "Breathing rate is the primary driver of autonomic effects \u{2014} slower breathing produces greater parasympathetic activation across all patterns tested.",
                        citation: "— Russo et al., Frontiers in Psychology, 2017"
                    )
                    .padding(.top, 10)

                    // MARK: How It Works
                    sectionDivider("how it works")
                        .padding(.top, 28)

                    VStack(alignment: .leading, spacing: 14) {
                        MechanismRow(number: 1, icon: "metronome", text: "Slower breathing rate is the universal key to autonomic benefits")
                        MechanismRow(number: 2, icon: "arrow.down", text: "Longer exhales amplify parasympathetic activation")
                        MechanismRow(number: 3, icon: "pause.circle", text: "Adding holds increases CO\u{2082} tolerance over time")
                        MechanismRow(number: 4, icon: "person.fill.checkmark", text: "Personalized rhythms improve adherence and comfort")
                    }
                    .padding(.top, 14)

                    // MARK: Key Insight
                    sectionDivider("key insight")
                        .padding(.top, 28)

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.homeGoldenAccent.opacity(0.8))
                            .padding(.top, 2)
                        Text("Consistency matters more than specific ratios. The best breathing exercise is the one you do daily.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
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

                    // MARK: Optimal Protocol
                    sectionDivider("optimal protocol")
                        .padding(.top, 28)

                    VStack(alignment: .leading, spacing: 10) {
                        protocolRow(label: "Cycle", value: "\u{2265} 10 seconds (< 6 breaths/min)")
                        protocolRow(label: "Duration", value: "At least 5 minutes")
                        protocolRow(label: "Frequency", value: "Daily practice")
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
