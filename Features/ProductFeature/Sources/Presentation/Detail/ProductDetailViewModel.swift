import CoreKit
import NetworkKit
import Observation
import ProductFeatureInterface

@MainActor
@Observable
final class ProductDetailViewModel {
    private(set) var state: LoadState<ProductDetail> = .idle

    let productID: String

    @ObservationIgnored private let fetchProductDetail: any FetchProductDetailUseCase

    init(productID: String, fetchProductDetail: any FetchProductDetailUseCase) {
        self.productID = productID
        self.fetchProductDetail = fetchProductDetail
    }

    func onAppear() async {
        guard case .idle = state else { return }
        await load()
    }

    func retry() async {
        await load()
    }

    private func load() async {
        state = .loading
        do {
            state = .loaded(try await fetchProductDetail.execute(id: productID))
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed(ProductErrorMessage.text(for: error))
        }
    }
}
