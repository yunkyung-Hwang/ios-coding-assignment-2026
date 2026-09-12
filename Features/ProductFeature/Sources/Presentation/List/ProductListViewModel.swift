import CoreKit
import NetworkKit
import Observation
import ProductFeatureInterface

@MainActor
@Observable
final class ProductListViewModel {
    private(set) var state: LoadState<[ProductSummary]> = .idle
    private(set) var total = 0

    /// 영속하지 않는다
    var layout: ProductLayout = .list

    @ObservationIgnored private let fetchProductList: any FetchProductListUseCase

    init(fetchProductList: any FetchProductListUseCase) {
        self.fetchProductList = fetchProductList
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
            let page = try await fetchProductList.execute(offset: 0, limit: Self.pageSize)
            total = page.total
            state = .loaded(page.items)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed(Self.message(for: error))
        }
    }

    /// 오류 문구는 화면 계층이 만든다. NetworkKit 은 종류만 전달
    private static func message(for error: Error) -> String {
        switch error {
        case APIError.transport:
            "네트워크에 연결할 수 없습니다"
        case let APIError.server(_, message?):
            message
        case let APIError.server(status, nil):
            "서버 오류가 발생했습니다 (\(status))"
        default:
            "잠시 후 다시 시도해 주세요"
        }
    }
}

extension ProductListViewModel {
    static let pageSize = 10
}
