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
                // Loop through the breathing types
                ForEach(BreathingType.allCases, id: \.self) { breathingType in
                    Button(breathingType.rawValue) {
                        self.selectedBreathingType = breathingType
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                    Text(selectedBreathingType.rawValue)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                }
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.clear))
            }
        }
    }
}
