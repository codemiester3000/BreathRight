import SwiftUI

struct FourSevenEightBreathInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("What is 4-7-8 Breathing?")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)
                .padding(.bottom, 12)

            // Description
            Text("The 4-7-8 breathing technique is a calming practice that involves breathing in for 4 seconds, holding the breath for 7 seconds, and exhaling for 8 seconds.")
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
                ForEach(FourSevenEightBenefit.allCases, id: \.self) { benefit in
                    BenefitRowNew(benefit: benefit)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
    }
}

struct BenefitRowNew: View {
    let benefit: FourSevenEightBenefit

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

enum FourSevenEightBenefit: String, CaseIterable {
    case promotesRelaxation = "Promotes relaxation and calmness."
    case aidsInSleep = "Aids in falling asleep more quickly."
    case managesStress = "Manages stress effectively."
    case improvesFocus = "Improves focus and mental clarity."
    case enhancesMindfulness = "Enhances mindfulness and self-awareness."

    var description: String {
        return self.rawValue
    }
}

