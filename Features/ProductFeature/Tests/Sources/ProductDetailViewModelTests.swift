import Foundation
import NetworkKit
import ProductFeatureInterface
import Testing
@testable import ProductFeature

private func makeDetail(_ id: String) -> ProductDetail {
    ProductDetail(
        id: id,
        name: "상품 \(id)",
        price: 1,
        imageURLs: [URL(string: "https://example.com/\(id).webp")!]
    )
}

private struct StubFetchProductDetail: FetchProductDetailUseCase {
    let result: @Sendable (String) async throws -> ProductDetail

    func execute(id: String) async throws -> ProductDetail {
        try await result(id)
    }
}

@MainActor
private func makeViewModel(
    productID: String = "7",
    _ result: @escaping @Sendable (String) async throws -> ProductDetail
) -> ProductDetailViewModel {
    ProductDetailViewModel(
        productID: productID,
        fetchProductDetail: StubFetchProductDetail(result: result)
    )
}

@Suite("상품 상세")
struct ProductDetailTests {

    @Suite("화면에 들어오면")
    @MainActor
    struct OnAppear {

        @Test("[R-06] 선택한 상품 ID 로 조회한다")
        func fetchesByProductID() async {
            let recorder = IDRecorder()
            let viewModel = makeViewModel(productID: "42") { id in
                await recorder.record(id)
                return makeDetail(id)
            }

            await viewModel.onAppear()

            #expect(await recorder.ids == ["42"])
        }

        @Test("[R-06] 조회한 상품을 표시 상태로 바꾼다")
        func exposesLoadedProduct() async {
            let viewModel = makeViewModel { makeDetail($0) }

            await viewModel.onAppear()

            #expect(viewModel.state.value?.id == "7")
        }

        @Test("[R-06] 이미 불러왔으면 다시 요청하지 않는다")
        func skipsWhenAlreadyLoaded() async {
            let recorder = IDRecorder()
            let viewModel = makeViewModel { id in
                await recorder.record(id)
                return makeDetail(id)
            }
            await viewModel.onAppear()

            await viewModel.onAppear()

            #expect(await recorder.ids.count == 1)
        }
    }

    @Suite("조회에 실패하면")
    @MainActor
    struct LoadFailure {

        @Test("[R-06] 서버가 보낸 메시지를 그대로 보여준다")
        func showsServerMessage() async {
            let viewModel = makeViewModel { _ in
                throw APIError.server(status: 404, message: "Product with id '7' not found")
            }

            await viewModel.onAppear()

            #expect(viewModel.state == .failed("Product with id '7' not found"))
        }

        @Test("[R-06] 취소는 실패가 아니라 요청 전으로 되돌린다")
        func treatsCancellationAsIdle() async {
            let viewModel = makeViewModel { _ in throw CancellationError() }

            await viewModel.onAppear()

            #expect(viewModel.state == .idle)
        }

        @Test("[R-06] 재시도하면 다시 불러온다")
        func retriesAfterFailure() async {
            let shouldFail = FailureFlag()
            let viewModel = makeViewModel { id in
                if await shouldFail.isOn {
                    await shouldFail.turnOff()
                    throw APIError.transport
                }
                return makeDetail(id)
            }
            await viewModel.onAppear()

            await viewModel.retry()

            #expect(viewModel.state.value?.id == "7")
        }
    }
}

private actor IDRecorder {
    private(set) var ids: [String] = []

    func record(_ id: String) { ids.append(id) }
}

private actor FailureFlag {
    private(set) var isOn = true

    func turnOff() { isOn = false }
}
