import CoreKit
import FavoriteKitInterface
import ProductFeatureInterface
import SwiftUI

struct ProductDetailView: View {
    @State private var viewModel: ProductDetailViewModel

    private let favoriteStore: any FavoriteStore

    init(viewModel: ProductDetailViewModel, favoriteStore: any FavoriteStore) {
        _viewModel = State(initialValue: viewModel)
        self.favoriteStore = favoriteStore
    }

    var body: some View {
        content
            // 이미지 위에 back·찜만 얹는다
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // 조회 성공 여부와 무관하게 동작한다
                    FavoriteButton(isOn: favoriteStore.ids.contains(viewModel.productID)) {
                        Task { await favoriteStore.toggle(viewModel.productID) }
                    }
                }
            }
            .task { await viewModel.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .failed(message):
            ErrorStateView(message: message) {
                Task { await viewModel.retry() }
            }
        case let .loaded(product):
            detail(product)
        }
    }

    private func detail(_ product: ProductDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 전체 폭. 상단 안전영역까지 올라간다
                ImageCarousel(urls: product.imageURLs)
                    .ignoresSafeArea(edges: .top)

                information(product)
                    .padding(.horizontal, Metrics.horizontalPadding)
                    .padding(.top, Metrics.infoTopPadding)
            }
        }
    }

    private func information(_ product: ProductDetail) -> some View {
        VStack(alignment: .leading, spacing: Metrics.textSpacing) {
            Text(product.name)
                .font(.headline)
                .foregroundStyle(.primary)
            PriceText(price: product.price, style: .detail)
            RatingReviewRow(rating: product.rating, reviewCount: product.reviewCount)
            if let description = product.description {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum Metrics {
    static let horizontalPadding: CGFloat = 20
    static let infoTopPadding: CGFloat = 20
    static let textSpacing: CGFloat = 6
}
