import SwiftUI
import AVFoundation

extension Color {
    static let robinhoodGreen = Color(hex: "3CB371")
    static let deepGreen = Color(hex: "2E8B57")
    static let deepBlue = Color(hex: "003366")
    static let lighterBlue = Color(hex: "0055b7")
    static let backgroundBeige = Color(hex: "f5be69")
    static let myTurqoise = Color(hex: "5de1e6")
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
    // Fixed offsets - computed once, not on every render
    private let xOffsets: [CGFloat] = [-80, -30, 20, -50, 10]

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                CosineAnimation()
                    .frame(height: 10)
                    .offset(x: xOffsets[index], y: CGFloat(index * 10))
            }
        }
    }
}
