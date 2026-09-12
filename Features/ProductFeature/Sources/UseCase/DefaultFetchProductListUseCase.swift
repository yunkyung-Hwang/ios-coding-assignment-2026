import CoreKit
import ProductFeatureInterface

struct DefaultFetchProductListUseCase: FetchProductListUseCase {
    private let repository: any ProductRepository

    init(repository: any ProductRepository) {
        self.repository = repository
    }

    func execute(offset: Int, limit: Int) async throws -> Paginated<ProductSummary> {
        try await repository.products(offset: offset, limit: limit)
    }
}
