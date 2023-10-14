import SwiftUI


struct Summary: View {
    let elapsedTime: Int
    @State private var animationProgress: CGFloat = 0.0
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            
            ConfettiAnimation()
            
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            HStack { // Added this HStack
                VStack(alignment: .leading) {
                    Text("Summary")
                        .font(.custom("Inter-Variable", size: 30))
                        .padding(.top)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("Duration: \(elapsedTime) seconds")
                            .font(.custom("Inter-Variable", size: 20))
                            .padding(16)
                            .background(
                                Color.gray.opacity(0.2)
                                    .cornerRadius(8)
                            )
                        Spacer()
                    }
                    .padding(.bottom, 16)
                    
                    HStack {
                        Spacer()
                        // Animated Circle
                        CircleSegment(progress: animationProgress)
                            .stroke(Color.deepGreen, lineWidth: 15)
                            .frame(width: 200, height: 200)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 2.0)) {
                                    animationProgress = 1.0
                                }
                            }
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Dismiss")
                            .font(.custom("Inter-Variable", size: 20))
                            .padding()
                            .background(Color.deepGreen)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                }
                .padding()
                .padding(.bottom, 16)
                
                Spacer() // This Spacer will push the VStack to the left
            }
        }
        
    }
}

struct CircleSegment: Shape, Animatable {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.5
        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: -90 + Double(360 * progress))
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

