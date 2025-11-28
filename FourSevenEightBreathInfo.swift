import SwiftUI

struct FourSevenEightBreathInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("What is 4-7-8 Breathing?")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.primary) // Adapts to theme
            
            Text("The 4-7-8 breathing technique is a calming practice that involves breathing in for 4 seconds, holding the breath for 7 seconds, and exhaling for 8 seconds.")
                .font(.system(size: 16))
                .foregroundColor(Color.secondary) // Subtle in both themes
                .padding(.bottom, 20)
            
            Text("Benefits:")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.primary)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(FourSevenEightBenefit.allCases, id: \.self) { benefit in
                    BenefitRowNew(benefit: benefit)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Adapts to theme
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct BenefitRowNew: View {
    let benefit: FourSevenEightBenefit

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(benefit.description)
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

