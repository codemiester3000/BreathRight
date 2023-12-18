import SwiftUI

// Enum to represent breathing types
enum BreathingType: String, CaseIterable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
}

struct SettingsView: View {
    @AppStorage("selectedBreathingType") private var selectedBreathingType: BreathingType = .boxBreathing

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.2), Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Loop through the breathing types
                ForEach(BreathingType.allCases, id: \.self) { breathingType in
                    BreathingOptionView(breathingType: breathingType,
                                        isSelected: selectedBreathingType == breathingType)
                        .onTapGesture {
                            withAnimation {
                                self.selectedBreathingType = breathingType
                            }
                        }
                }
            }
            .padding()
        }
    }
}

// View for each breathing option
struct BreathingOptionView: View {
    let breathingType: BreathingType
    var isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color(hex: "2E8B57") : Color.gray)
                .frame(height: 150)
                .shadow(radius: 5)
                .animation(.easeInOut(duration: 0.1), value: isSelected) 

            HStack {
                Image(systemName: breathingType == BreathingType.boxBreathing ? "square" : "waveform.path.badge.minus") // Example icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                    .padding(.trailing)

                Text(breathingType.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 30)
    }
}
