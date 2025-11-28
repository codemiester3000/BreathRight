import SwiftUI

// Enum to represent breathing types
enum BreathingType: String, CaseIterable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
}

struct SettingsView: View {
    @AppStorage("selectedBreathingType") private var selectedBreathingType: BreathingType = .boxBreathing

    var body: some View {
        VStack {
            Menu {
                ForEach(BreathingType.allCases, id: \.self) { breathingType in
                    Button(breathingType.rawValue) {
                        self.selectedBreathingType = breathingType
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(selectedBreathingType.rawValue)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}
