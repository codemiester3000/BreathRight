import SwiftUI

struct Summary: View {
    let elapsedTime: Int
    @State private var animationProgress: CGFloat = 0.0
    
    @Environment(\.presentationMode) var presentationMode
    
    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return "\(minutes) min \(seconds) sec"
    }
    
    var body: some View {
        ZStack {
            
            ConfettiAnimation()
            
            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                VStack(alignment: .leading) {
                    
                    HStack {
                        Text("Great Work!")
                            .font(.custom("Inter-Variable", size: 30))
                            .padding(.top)
                        Spacer()
                        Image("TinyIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        ZStack {
                            // Animated Circle
                            CircleSegment(progress: animationProgress)
                                .stroke(Color.deepGreen, lineWidth: 10)
                                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 3.0)) {
                                        animationProgress = 1.0
                                    }
                                }
                            
                            // Elapsed time text in the center of the circle
                            Text("\(formattedTime)")
                                .font(.custom("Inter-Variable", size: 20))
                                .padding(16)
                                .background(
                                    Color.gray.opacity(0.2)
                                        .cornerRadius(8)
                                )
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
                
                Spacer()
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
