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
            LinearGradient(gradient: Gradient(colors: [.black, .black]), startPoint: .top, endPoint: .bottom)
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
                .fill(isSelected ? .white : Color.gray)
                .frame(height: 150)
                .shadow(radius: 5)
                .animation(.easeInOut(duration: 0.1), value: isSelected) 
            
            HStack {
                Image(systemName: breathingType == BreathingType.boxBreathing ? "square" : "waveform.path.badge.minus") // Example icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(isSelected ? .black : .white)
                    .padding(.trailing)
                
                Text(breathingType.rawValue)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .black : .white)
            }
        }
        .padding(.vertical, 20)
    }
}
