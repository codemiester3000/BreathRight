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
    
    func timeForOneCycle() -> Int {
            switch self {
            case .boxBreathing:
                // Box breathing is typically 4 seconds inhale, 4 seconds hold, 4 seconds exhale, 4 seconds hold
                return 4 + 4 + 4 + 4 // 16 seconds
            case .fourSevenEight:
                // 4-7-8 breathing is 4 seconds inhale, 7 seconds hold, 8 seconds exhale
                return 4 + 7 + 8 // 19 seconds
            }
        }
}

struct HomeView: View {
    @State private var numCycles: Int = 10
    @State private var unlimtedCycles: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.lighterBlue, Color.myTurqoise]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center) {
                    
                    AnimatedHeaderView()
                        .padding(.top, -45)
                        .padding(.bottom, 42)
                        //.padding(.bottom, 32)
                    
                    VStack(alignment: .leading) {
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
                        .padding(.horizontal)
                        
                        Divider().background(.white)
                        
                        //Spacer()
                        HStack {
                            BreathCycleSelector(cycles: $numCycles, isUnlimited: $unlimtedCycles)
                            Spacer()
                        }
                        .frame(height: 40)
                        .padding(.top, 32)
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        // Subheader
                        Text("Select your breathing exercise:")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.bottom)
                            .padding(.top)
                            .padding(.leading)
                    }
                   
                    
                    VStack(alignment: .center) {
                        ForEach(BreathingExercise.allCases, id: \.self) { exercise in
                            NavigationLink(destination: destinationView(for: exercise)) {
                                BeautifulButton(title: exercise.rawValue, benefits: exercise.benefits, numCycles: numCycles, timeForCycle: exercise.timeForOneCycle())
                                    .padding(.bottom, 12)
                            }
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
    let numCycles: Int // New parameter for the number of cycles
    let timeForCycle: Int

    let screenWidth = UIScreen.main.bounds.width

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Divider().background(Color.white).frame(width: screenWidth * 0.8 * 0.58)

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
                .frame(width: screenWidth * 0.8 * 0.53, height: 140)
                .padding(.leading, 8)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .imageScale(.large)
            }
            .padding([.top, .leading, .trailing])

            HStack {
                HStack {
                    Image(systemName: "arrow.2.squarepath")
                        .foregroundColor(.backgroundBeige)
                        .font(.caption)

                    Text("\(numCycles) cycles")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(.trailing, 12)
                }
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.backgroundBeige)
                        .font(.caption)

                    Text(etaText)
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(.trailing, 12)
                }
                Spacer()
            }
            .padding(.bottom, 32)
            .padding(.horizontal)

            // Maintaining the styling for the whole button
        }
        .frame(width: screenWidth * 0.9, height: 160) // Adjusted height for the new row
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 1)
        )
        .shadow(radius: 5)
    }
    
    private var etaText: String {
            let totalSeconds = timeForCycle * numCycles
            if totalSeconds < 60 {
                return "\(totalSeconds) sec"
            } else {
                let roundedMinutes = (totalSeconds + 30) / 60 // Round to nearest minute
                return "\(roundedMinutes) min"
            }
        }
}


struct BreathCycleSelector: View {
    @Binding var cycles: Int // Binding to the number of breath cycles
    @Binding var isUnlimited: Bool // Binding to toggle unlimited cycles
    let sliderWidth: CGFloat = UIScreen.main.bounds.width - 120
    let thumbSize: CGFloat = 20
    let trackColor = Color.backgroundBeige.opacity(0.5)
    let thumbColor = Color.white
    let maxCycles = 120 // Maximum number of cycles

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "arrow.3.trianglepath").foregroundColor(.white)
                Text("Breath cycles")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                Spacer()
                if isUnlimited {
                    Text("∞") // Infinity symbol for unlimited
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                } else {
                    Text("\(cycles) cycles")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(width: sliderWidth, height: 3)
                        .foregroundColor(trackColor)
                    
                    Capsule()
                        .frame(width: isUnlimited ? sliderWidth : sliderWidth * CGFloat(cycles) / CGFloat(maxCycles), height: 3)
                        .foregroundColor(thumbColor)
                    
                    Circle()
                        .frame(width: thumbSize, height: thumbSize)
                        .foregroundColor(thumbColor)
                        .offset(x: isUnlimited ? sliderWidth : sliderWidth * CGFloat(cycles) / CGFloat(maxCycles) - thumbSize / 2)
                        .gesture(
                            DragGesture().onChanged { gesture in
                                if !isUnlimited {
                                    let newCycleValue = Int((gesture.location.x / sliderWidth) * CGFloat(maxCycles))
                                    cycles = min(max(newCycleValue, 1), maxCycles)
                                }
                            }
                        )
                }
                .padding(.trailing)

                Button(action: {
                    isUnlimited.toggle()
                    if isUnlimited {
                        cycles = maxCycles
                    }
                }) {
                    Image(systemName: "infinity")
                        .foregroundColor(isUnlimited ? .myTurqoise : .white)
                        .frame(width: 40, height: 40)
                        .background(isUnlimited ? Color.white : Color.clear)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

