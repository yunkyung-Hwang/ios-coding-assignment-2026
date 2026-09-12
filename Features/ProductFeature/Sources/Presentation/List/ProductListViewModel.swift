import CoreKit
import Observation
import ProductFeatureInterface

@MainActor
@Observable
final class ProductListViewModel {
    /// 영속하지 않는다
    var layout: ProductLayout = .list

    /// 추가 조회 실패 알림. 사용자가 닫으면 nil
    var loadMoreFailure: String?

    /// 순환 참조를 끊기 위해 weak
    @ObservationIgnored weak var coordinator: (any ProductCoordinating)?

    @ObservationIgnored private let paginator: Paginator<ProductSummary>

    var state: LoadState<[ProductSummary]> { paginator.state }
    var total: Int { paginator.total }
    var hasMore: Bool { paginator.more != .exhausted }
    var isLoadingMore: Bool { paginator.more == .loading }

    init(fetchProductList: any FetchProductListUseCase) {
        paginator = Paginator(
            pageSize: Self.pageSize,
            errorMessage: ProductErrorMessage.text(for:)
        ) { offset, limit in
            try await fetchProductList.execute(offset: offset, limit: limit)
        }
    }

    func select(_ product: ProductSummary) {
        coordinator?.showDetail(id: product.id)
    }

    func onAppear() async {
        guard case .idle = paginator.state else { return }
        await paginator.loadFirst()
    }

    func retry() async {
        await paginator.loadFirst()
    }

    /// 실패해도 목록은 그대로 두고 알림만 올린다
    func loadMore() async {
        await paginator.loadMore()
        if case let .failed(message) = paginator.more {
            loadMoreFailure = message
        }
    }
}

extension ProductListViewModel {
    static let pageSize = 10
}
