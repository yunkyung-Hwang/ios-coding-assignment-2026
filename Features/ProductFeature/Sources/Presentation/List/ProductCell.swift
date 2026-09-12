import ProductFeatureInterface
import SwiftUI

struct ProductCell: View {
    let product: ProductSummary
    let layout: ProductLayout
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    var body: some View {
        switch layout {
        case .list: listBody
        case .grid: gridBody
        }
    }

    private var listBody: some View {
        HStack(alignment: .top, spacing: Metrics.imageToText) {
            thumbnail
                .frame(width: Metrics.thumbnailSize, height: Metrics.thumbnailSize)
            information
            // 없으면 텍스트 열 폭이 내용 길이에 맞춰 줄어든다
            Spacer(minLength: 0)
        }
    }

    private var gridBody: some View {
        VStack(alignment: .leading, spacing: Metrics.textSpacing) {
            thumbnail
                .aspectRatio(1, contentMode: .fit)
                .padding(.bottom, Metrics.imageToTitle - Metrics.textSpacing)
            information
        }
    }

    private var thumbnail: some View {
        RemoteImageView(url: product.thumbnailURL)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius))
            .overlay(alignment: .bottomTrailing) {
                FavoriteButton(isOn: isFavorite, action: toggleFavorite)
            }
    }

    private var information: some View {
        VStack(alignment: .leading, spacing: Metrics.textSpacing) {
            Text(product.name)
                .font(.footnote)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .truncationMode(.tail)
            PriceText(price: product.price, style: .list)
            RatingReviewRow(rating: product.rating, reviewCount: product.reviewCount)
        }
    }
}

private enum Metrics {
    static let thumbnailSize: CGFloat = 120
    static let cornerRadius: CGFloat = 8
    static let imageToText: CGFloat = 12
    static let imageToTitle: CGFloat = 8
    static let textSpacing: CGFloat = 6
}
