import SwiftUI

// Enum for breathing exercises
enum BreathingExercise: String, CaseIterable {
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
    //    case custom = "Custom"
    
    // Benefits for each exercise
    var benefits: [String] {
        switch self {
        case .boxBreathing:
            return ["Reduces stress", "Improves concentration", "Enhances relaxation"]
        case .fourSevenEight:
            return ["Improves sleep", "Manages cravings", "Reduces stress"]
        }
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.lighterBlue, Color.myTurqoise]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    
                    AnimatedHeaderView()
                        .padding(.top, -45)
                        .padding(.bottom, 42)
                        //.padding(.bottom, 32)
                    
                    // Dynamic greeting
                    HStack {
                        Text(greetingMessage())
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: greetingIconName())
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                    .padding(.top)
                    
                    Divider().background(.white)
                    
                    //Spacer()
                    
                    // Subheader
                    Text("Select Your Breathing Module:")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.bottom)
                        .padding(.top)
                    
                    ForEach(BreathingExercise.allCases, id: \.self) { exercise in
                        NavigationLink(destination: destinationView(for: exercise)) {
                            BeautifulButton(title: exercise.rawValue, benefits: exercise.benefits)
                                .padding(.bottom, 12)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for exercise: BreathingExercise) -> some View {
        switch exercise {
        case .boxBreathing:
            BoxBreathingView()
        case .fourSevenEight:
            FourSevenEightBreathingView()
            // Add cases for other exercises
        }
    }
    
    // Function to determine greeting based on time of day
    private func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private func greetingIconName() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "sunrise.fill" // Morning icon
        case 12..<17: return "sun.max.fill" // Afternoon icon
        case 17..<20: return "moon.stars.fill" // Evening icon
        default: return "moon.stars.fill" // Night icon
        }
    }
}

struct BeautifulButton: View {
    let title: String
    let benefits: [String]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Divider().background(Color.white).frame(width: 175)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(benefits, id: \.self) { benefit in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.backgroundBeige)
                            Text(benefit)
                                .foregroundColor(.white)
                        }
                    }
                }
                .font(.caption)
            }
            .frame(width: 160, height: 140)
            .padding(.leading, 8)
            
            Spacer() // Add a spacer to push the arrow to the right
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .imageScale(.large)
        }
        .padding()
        .frame(width: 300, height: 140)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 1)
        )
        .shadow(radius: 5)
    }
}
