import SwiftUI

struct StreakBannerView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        HStack(spacing: 0) {
            // Streak
            HStack(spacing: 6) {
                Image(systemName: dataManager.currentStreak > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 14))
                    .foregroundColor(dataManager.currentStreak > 0 ? .orange : .white.opacity(0.4))
                Text("\(dataManager.currentStreak)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("day streak")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Level
            HStack(spacing: 6) {
                let level = GamificationConstants.levelFor(xp: dataManager.currentXP)
                Text("Lv.\(level.number)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.homeWarmAccent)
                Text(level.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                // Mini XP bar
                let progress = GamificationConstants.xpProgressInLevel(xp: dataManager.currentXP)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [.homeWarmAccent, .homeGoldenAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 40 * CGFloat(progress.fraction), height: 4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
    }
}
