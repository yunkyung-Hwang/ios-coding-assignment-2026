import SwiftUI

struct RatingReviewRow: View {
    let rating: Double?
    let reviewCount: Int?

    var body: some View {
        HStack(spacing: Metrics.itemSpacing) {
            if let rating {
                item(symbol: "star.fill", text: "\(rating)")
            }
            if let reviewCount {
                item(symbol: "ellipsis.bubble.fill", text: "\(reviewCount)")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    /// 값이 없으면 아이콘까지 생략
    private func item(symbol: String, text: String) -> some View {
        HStack(spacing: Metrics.symbolToText) {
            Image(systemName: symbol)
            Text(text)
        }
    }
}

private enum Metrics {
    static let itemSpacing: CGFloat = 8
    static let symbolToText: CGFloat = 2
}
