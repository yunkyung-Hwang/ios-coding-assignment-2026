import CoreKit
import Foundation
import ProductFeatureInterface
import Testing
@testable import ProductFeature

/// 이동 요청을 기록하는 대역
@MainActor
private final class SpyCoordinator: ProductCoordinating {
    private(set) var shownIDs: [String] = []

    func showDetail(id: String) {
        shownIDs.append(id)
    }
}

@Suite("상품 화면 전환")
@MainActor
struct ProductNavigationTests {

    private func makeViewModel() -> ProductListViewModel {
        ProductListViewModel(fetchProductList: StubUseCase())
    }

    private struct StubUseCase: FetchProductListUseCase {
        func execute(offset: Int, limit: Int) async throws -> Paginated<ProductSummary> {
            Paginated(items: [], total: 0, offset: offset)
        }
    }

    private func makeProduct(_ id: String) -> ProductSummary {
        ProductSummary(
            id: id,
            name: "상품",
            price: 1,
            thumbnailURL: URL(string: "https://example.com/\(id).webp")!
        )
    }

    @Test("[R-02] 상품을 선택하면 상세 이동을 요청한다")
    func requestsDetail() {
        let coordinator = SpyCoordinator()
        let viewModel = makeViewModel()
        viewModel.coordinator = coordinator

        viewModel.select(makeProduct("7"))

        #expect(coordinator.shownIDs == ["7"])
    }

    @Test("[R-02] 이동 대상이 없어도 선택이 실패하지 않는다")
    func toleratesMissingCoordinator() {
        let viewModel = makeViewModel()

        viewModel.select(makeProduct("7"))

        #expect(viewModel.coordinator == nil)
    }
}
