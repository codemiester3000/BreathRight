import SwiftUI

struct BoxBreathInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            Text("What is Box Breathing?")
                .font(.custom("Inter-Variable", size: 22))
                .fontWeight(.bold)
            
            Text("Box breathing is a powerful stress-relieving technique. It involves inhaling, holding, exhaling, and holding the breath again, each for an equal count.")
                .font(.custom("Inter-Variable", size: 16))
                .padding(.bottom, 20)
            
            Text("Benefits:")
                .font(.custom("Inter-Variable", size: 18))
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                    Text("Reduces stress and anxiety.")
                }
                HStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                    Text("Improves focus and concentration.")
                }
                HStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                    Text("Helps in emotional regulation.")
                }
                HStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                    Text("Lowers blood pressure.")
                }
                HStack(spacing: 15) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                    Text("Enhances overall well-being.")
                }
            }
            .font(.custom("Inter-Variable", size: 16))
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
