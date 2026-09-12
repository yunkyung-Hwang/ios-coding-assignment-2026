import FavoriteKitInterface
import NetworkKit
import ProductFeatureInterface
import SwiftUI

/// 모듈의 유일한 공개 심볼
/// 내부 조립을 감추고 화면만 돌려준다
@MainActor
public struct ProductAssembly {
    private let client: any APIClient
    private let favoriteStore: any FavoriteStore

    public init(client: any APIClient, favoriteStore: any FavoriteStore) {
        self.client = client
        self.favoriteStore = favoriteStore
    }

    public func list(coordinator: any ProductCoordinating) -> some View {
        let viewModel = ProductListViewModel(fetchProductList: fetchProductList)
        viewModel.coordinator = coordinator
        return ProductListView(viewModel: viewModel, favoriteStore: favoriteStore)
    }

    public func detail(id: String) -> some View {
        ProductDetailView(
            viewModel: ProductDetailViewModel(productID: id, fetchProductDetail: fetchProductDetail),
            favoriteStore: favoriteStore
        )
    }

    private var repository: any ProductRepository {
        RemoteProductRepository(client: client)
    }

    private var fetchProductList: any FetchProductListUseCase {
        DefaultFetchProductListUseCase(repository: repository)
    }

    private var fetchProductDetail: any FetchProductDetailUseCase {
        DefaultFetchProductDetailUseCase(repository: repository)
    }
}
