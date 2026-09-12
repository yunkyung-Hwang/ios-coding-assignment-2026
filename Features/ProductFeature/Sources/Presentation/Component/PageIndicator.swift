import SwiftUI

struct PageIndicator: View {
    /// 1-based
    let current: Int
    let total: Int

    var body: some View {
        Text("\(current)/\(total)")
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, Metrics.horizontalPadding)
            .padding(.vertical, Metrics.verticalPadding)
            .background(.black.opacity(Metrics.backgroundOpacity), in: .rect(cornerRadius: Metrics.cornerRadius))
    }
}

private enum Metrics {
    static let horizontalPadding: CGFloat = 8
    static let verticalPadding: CGFloat = 4
    static let cornerRadius: CGFloat = 10
    static let backgroundOpacity: Double = 0.5
}
