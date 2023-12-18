import SwiftUI

struct BoxBreathInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("What is Box Breathing?")
                .font(.custom("Inter-Variable", size: 22))
                .fontWeight(.bold)
                .foregroundColor(Color.primary) // Adapts to theme
            
            Text("Box breathing is a powerful stress-relieving technique. It involves inhaling, holding, exhaling, and holding the breath again, each for an equal count.")
                .font(.custom("Inter-Variable", size: 16))
                .foregroundColor(Color.secondary) // Subtle in both themes
                .padding(.bottom, 20)
            
            Text("Benefits:")
                .font(.custom("Inter-Variable", size: 18))
                .fontWeight(.bold)
                .foregroundColor(Color.primary)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Benefit.allCases, id: \.self) { benefit in
                    BenefitRow(benefit: benefit)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Adapts to theme
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct BenefitRow: View {
    let benefit: Benefit

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(benefit.description)
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
