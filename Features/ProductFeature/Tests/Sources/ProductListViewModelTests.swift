import CoreKit
import Foundation
import NetworkKit
import ProductFeatureInterface
import Testing
@testable import ProductFeature

private func makeSummary(_ id: Int) -> ProductSummary {
    ProductSummary(
        id: String(id),
        name: "상품 \(id)",
        price: Decimal(id),
        thumbnailURL: URL(string: "https://example.com/\(id).webp")!
    )
}

/// 조회 결과를 제어하는 대역
private struct StubFetchProductList: FetchProductListUseCase {
    let result: @Sendable (Int, Int) async throws -> Paginated<ProductSummary>

    func execute(offset: Int, limit: Int) async throws -> Paginated<ProductSummary> {
        try await result(offset, limit)
    }
}

@MainActor
private func makeViewModel(
    _ result: @escaping @Sendable (Int, Int) async throws -> Paginated<ProductSummary>
) -> ProductListViewModel {
    ProductListViewModel(fetchProductList: StubFetchProductList(result: result))
}

@Suite("상품 목록")
struct ProductListTests {

    @Suite("화면에 들어오면")
    @MainActor
    struct OnAppear {

        @Test("[R-01] 첫 페이지를 불러온다")
        func loadsFirstPage() async {
            let viewModel = makeViewModel { _, _ in
                Paginated(items: [makeSummary(1), makeSummary(2)], total: 194, offset: 0)
            }

            await viewModel.onAppear()

            #expect(viewModel.state.value?.count == 2)
            #expect(viewModel.total == 194)
        }

        @Test("[R-01] 페이지 크기만큼 요청한다")
        func requestsPageSize() async {
            let recorder = RequestRecorder()
            let viewModel = makeViewModel { offset, limit in
                await recorder.record(offset: offset, limit: limit)
                return Paginated(items: [], total: 0, offset: offset)
            }

            await viewModel.onAppear()

            #expect(await recorder.offsets == [0])
            #expect(await recorder.limits == [ProductListViewModel.pageSize])
        }

        @Test("[R-01] 이미 불러왔으면 다시 요청하지 않는다")
        func skipsWhenAlreadyLoaded() async {
            let recorder = RequestRecorder()
            let viewModel = makeViewModel { offset, limit in
                await recorder.record(offset: offset, limit: limit)
                return Paginated(items: [makeSummary(1)], total: 1, offset: 0)
            }
            await viewModel.onAppear()

            await viewModel.onAppear()

            #expect(await recorder.offsets.count == 1)
        }
    }

    @Suite("조회에 실패하면")
    @MainActor
    struct LoadFailure {

        @Test("[R-01] 연결 실패는 조치 가능한 문구로 드러난다")
        func showsTransportMessage() async {
            let viewModel = makeViewModel { _, _ in throw APIError.transport }

            await viewModel.onAppear()

            #expect(viewModel.state == .failed("네트워크에 연결할 수 없습니다"))
        }

        @Test("[R-01] 서버가 보낸 메시지를 그대로 보여준다")
        func showsServerMessage() async {
            let viewModel = makeViewModel { _, _ in
                throw APIError.server(status: 404, message: "Product not found")
            }

            await viewModel.onAppear()

            #expect(viewModel.state == .failed("Product not found"))
        }

        @Test("[R-01] 메시지가 없는 서버 오류는 상태 코드를 보여준다")
        func showsStatusCode() async {
            let viewModel = makeViewModel { _, _ in throw APIError.server(status: 500, message: nil) }

            await viewModel.onAppear()

            #expect(viewModel.state == .failed("서버 오류가 발생했습니다 (500)"))
        }

        @Test("[R-01] 취소는 실패가 아니라 요청 전으로 되돌린다")
        func treatsCancellationAsIdle() async {
            let viewModel = makeViewModel { _, _ in throw CancellationError() }

            await viewModel.onAppear()

            #expect(viewModel.state == .idle)
        }

        @Test("[R-01] 재시도하면 다시 불러온다")
        func retriesAfterFailure() async {
            let shouldFail = FailureSwitch()
            let viewModel = makeViewModel { _, _ in
                if await shouldFail.isOn {
                    await shouldFail.turnOff()
                    throw APIError.transport
                }
                return Paginated(items: [makeSummary(1)], total: 1, offset: 0)
            }
            await viewModel.onAppear()

            await viewModel.retry()

            #expect(viewModel.state.value?.count == 1)
        }
    }

    @Suite("레이아웃을 전환하면")
    @MainActor
    struct LayoutToggle {

        @Test("[R-07] 1열과 2열이 번갈아 바뀐다")
        func togglesBetweenColumns() {
            var layout = ProductLayout.list

            layout.toggle()
            #expect(layout == .grid)

            layout.toggle()
            #expect(layout == .list)
        }

        @Test("[R-07] 열 개수가 레이아웃을 따른다")
        func columnCountFollowsLayout() {
            #expect(ProductLayout.list.columns.count == 1)
            #expect(ProductLayout.grid.columns.count == 2)
        }

        @Test("[R-07] 버튼은 전환 대상을 가리킨다")
        func symbolPointsToTarget() {
            #expect(ProductLayout.list.toggleSymbol == "square.grid.2x2")
            #expect(ProductLayout.grid.toggleSymbol == "list.bullet")
        }

        @Test("[R-07] 전환해도 목록이 유지된다")
        func keepsProductsAcrossToggle() async {
            let viewModel = makeViewModel { _, _ in
                Paginated(items: [makeSummary(1), makeSummary(2)], total: 2, offset: 0)
            }
            await viewModel.onAppear()

            viewModel.layout.toggle()

            #expect(viewModel.state.value?.count == 2)
        }
    }
}

private actor RequestRecorder {
    private(set) var offsets: [Int] = []
    private(set) var limits: [Int] = []

    func record(offset: Int, limit: Int) {
        offsets.append(offset)
        limits.append(limit)
    }
}

private actor FailureSwitch {
    private(set) var isOn = true

    func turnOff() { isOn = false }
}
