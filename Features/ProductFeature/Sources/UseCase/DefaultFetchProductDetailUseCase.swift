import ProductFeatureInterface

struct DefaultFetchProductDetailUseCase: FetchProductDetailUseCase {
    private let repository: any ProductRepository

    init(repository: any ProductRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> ProductDetail {
        try await repository.product(id: id)
    }
}
