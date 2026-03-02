import SwiftUI

struct AchievementBadgeView: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.homeGoldenAccent.opacity(0.15) : Color.white.opacity(0.04))
                    .frame(width: 48, height: 48)

                if isUnlocked {
                    Circle()
                        .stroke(Color.homeGoldenAccent.opacity(0.4), lineWidth: 1)
                        .frame(width: 48, height: 48)
                }

                Image(systemName: achievement.icon)
                    .font(.system(size: 18))
                    .foregroundColor(isUnlocked ? .homeGoldenAccent : .white.opacity(0.15))
            }

            Text(achievement.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(isUnlocked ? .white.opacity(0.8) : .white.opacity(0.2))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}
