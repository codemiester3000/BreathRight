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
            // Loop through the breathing types
            ForEach(BreathingType.allCases, id: \.self) { breathingType in
                BreathingOptionView(breathingType: breathingType,
                                    isSelected: selectedBreathingType == breathingType)
                    .onTapGesture {
                        self.selectedBreathingType = breathingType
                    }
            }
        }
        .padding()
    }
}

// View for each breathing option
struct BreathingOptionView: View {
    let breathingType: BreathingType
    var isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.blue : Color.gray)
                .frame(height: 150)
                .shadow(radius: 5)

            Text(breathingType.rawValue)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
    }
}
