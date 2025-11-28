import SwiftUI

struct BoxBreathInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("What is Box Breathing?")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)
                .padding(.bottom, 12)

            // Description
            Text("Box breathing is a powerful stress-relieving technique. It involves inhaling, holding, exhaling, and holding the breath again, each for an equal count.")
                .font(.system(size: 14))
                .foregroundColor(Color.secondary)
                .lineSpacing(4)
                .padding(.bottom, 20)

            // Benefits section
            Text("BENEFITS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.secondary)
                .tracking(1)
                .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Benefit.allCases, id: \.self) { benefit in
                    BenefitRow(benefit: benefit)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
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
