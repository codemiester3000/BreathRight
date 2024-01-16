import SwiftUI
import AVFoundation

extension Color {
    static let robinhoodGreen = Color(hex: "3CB371")
    static let deepGreen = Color(hex: "2E8B57")
    static let deepBlue = Color(hex: "003366")
    static let lighterBlue = Color(hex: "0055b7")
}

struct MainView: View {
    
    @AppStorage("selectedBreathingType") var selectedBreathingType: BreathingType = .boxBreathing
    
    var body: some View {
        VStack {
            AnimatedHeaderView()
            
            switch selectedBreathingType {
                        case .boxBreathing:
                            BoxBreathingView()
                        case .fourSevenEight:
                            FourSevenEightBreathingView() // This is the new view for 4-7-8 Breathing
                        }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.deepBlue, Color.lighterBlue]), startPoint: .top, endPoint: .bottom)
        )
    }
}

struct AnimatedHeaderView: View {
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                CosineAnimation()
                    .frame(height: 10) // Setting a fixed height for each animation
                    .offset(x: CGFloat.random(in: -100...50), y: CGFloat(index * 10))
            }
        }
        .padding(.vertical, 30)
    }
}
