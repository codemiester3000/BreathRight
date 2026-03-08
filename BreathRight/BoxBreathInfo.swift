import SwiftUI

// MARK: - Reusable Components

struct StudyCard: View {
    let finding: String
    let citation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.homeGoldenAccent.opacity(0.8))
                    .padding(.top, 2)
                Text(finding)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(citation)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.homeWarmAccent.opacity(0.7))
                .padding(.leading, 24)
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
    }
}

struct MechanismRow: View {
    let number: Int
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.homeWarmAccent.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.homeWarmAccent)
            }
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Box Breath Info

struct BoxBreathInfo: View {
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
                    Text("Box Breathing")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 8)

                    // Hook line
                    Text("Equal-ratio breathing used by Navy SEALs to control stress under fire.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(3)
                        .padding(.top, 8)

                    // MARK: The Science
                    sectionDivider("the science")
                        .padding(.top, 28)

                    StudyCard(
                        finding: "Equal-ratio breathing at 4-second intervals increased heart rate variability and shifted autonomic balance toward parasympathetic dominance in healthy adults.",
                        citation: "— Russo, Santarelli & O\u{2019}Rourke, Frontiers in Psychology, 2017"
                    )
                    .padding(.top, 14)

                    StudyCard(
                        finding: "Diaphragmatic breathing intervention significantly reduced cortisol levels and increased sustained attention scores after 8 weeks of practice.",
                        citation: "— Ma et al., Frontiers in Psychology, 2017"
                    )
                    .padding(.top, 10)

                    StudyCard(
                        finding: "Structured cyclic breathing patterns proved more effective than mindfulness meditation for reducing physiological stress markers and improving mood.",
                        citation: "— Balban et al., Cell Reports Medicine, 2023"
                    )
                    .padding(.top, 10)

                    // MARK: How It Works
                    sectionDivider("how it works")
                        .padding(.top, 28)

                    VStack(alignment: .leading, spacing: 14) {
                        MechanismRow(number: 1, icon: "wind", text: "Equal inhale-hold-exhale-hold phases create a rhythmic pattern")
                        MechanismRow(number: 2, icon: "bolt.heart", text: "Activates the vagus nerve through slow, controlled breathing")
                        MechanismRow(number: 3, icon: "arrow.triangle.swap", text: "Shifts autonomic nervous system from sympathetic to parasympathetic")
                        MechanismRow(number: 4, icon: "chart.line.downtrend.xyaxis", text: "Reduces cortisol and adrenaline production")
                    }
                    .padding(.top, 14)

                    // MARK: Who Uses This
                    sectionDivider("who uses this")
                        .padding(.top, 28)

                    HStack(spacing: 8) {
                        ForEach(["Navy SEALs", "Surgeons", "First Responders", "Athletes"], id: \.self) { user in
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
                        protocolRow(label: "Interval", value: "4 seconds per phase")
                        protocolRow(label: "Duration", value: "5\u{2013}10 minutes")
                        protocolRow(label: "Frequency", value: "Daily practice")
                        protocolRow(label: "Note", value: "Cumulative benefits build over time")
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

// MARK: - Legacy Benefit Support

enum Benefit: String, CaseIterable {
    case stressReduction = "Reduces stress and anxiety."
    case focusImprovement = "Improves focus and concentration."
    case emotionalRegulation = "Helps in emotional regulation."
    case bloodPressureLowering = "Lowers blood pressure."
    case wellBeingEnhancement = "Enhances overall well-being."

    var description: String {
        return self.rawValue
    }
}

struct BenefitRow: View {
    let benefit: Benefit

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "22c55e"))
            Text(benefit.description)
                .font(.system(size: 14))
                .foregroundColor(Color.primary)
        }
    }
}
