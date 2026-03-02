import SwiftUI

struct BOLTChartView: View {
    let scores: [BOLTScore]

    var body: some View {
        GeometryReader { geo in
            let values = scores.map { $0.scoreSeconds }
            let maxVal = max(values.max() ?? 1, 10)
            let minVal: Double = 0
            let range = maxVal - minVal

            ZStack {
                // Horizontal guide lines
                ForEach([0.25, 0.5, 0.75], id: \.self) { frac in
                    Path { path in
                        let y = geo.size.height * (1 - CGFloat(frac))
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                }

                // Y-axis labels
                VStack {
                    Text(String(format: "%.0f", maxVal))
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Text(String(format: "%.0f", maxVal / 2))
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                    Text("0")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxHeight: .infinity)

                if values.count == 1 {
                    // Single point
                    let y = geo.size.height * (1 - CGFloat((values[0] - minVal) / range))
                    Circle()
                        .fill(Color.homeGoldenAccent)
                        .frame(width: 8, height: 8)
                        .position(x: geo.size.width / 2, y: y)
                } else {
                    // Line chart
                    let points = values.enumerated().map { (index, val) -> CGPoint in
                        let x = geo.size.width * CGFloat(index) / CGFloat(values.count - 1)
                        let y = geo.size.height * (1 - CGFloat((val - minVal) / range))
                        return CGPoint(x: x, y: y)
                    }

                    // Gradient fill under line
                    Path { path in
                        path.move(to: CGPoint(x: points[0].x, y: geo.size.height))
                        path.addLine(to: points[0])
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                        path.addLine(to: CGPoint(x: points.last!.x, y: geo.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.homeGoldenAccent.opacity(0.2), Color.homeGoldenAccent.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // Line
                    Path { path in
                        path.move(to: points[0])
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [.homeWarmAccent, .homeGoldenAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )

                    // Data points
                    ForEach(0..<points.count, id: \.self) { i in
                        Circle()
                            .fill(Color.homeGoldenAccent)
                            .frame(width: 6, height: 6)
                            .position(points[i])
                    }

                    // Latest value label
                    if let last = points.last, let lastVal = values.last {
                        Text(String(format: "%.1fs", lastVal))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.homeGoldenAccent)
                            .position(x: last.x, y: max(last.y - 14, 10))
                    }
                }
            }
            .padding(.leading, 24)
        }
    }
}
