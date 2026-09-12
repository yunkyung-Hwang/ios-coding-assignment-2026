import CoreKit
import NetworkKit
import ProductFeatureInterface

struct RemoteProductRepository: ProductRepository {
    private let client: any APIClient

    init(client: any APIClient) {
        self.client = client
    }

    func products(offset: Int, limit: Int) async throws -> Paginated<ProductSummary> {
        let response = try await client.send(ProductEndpoint.list(skip: offset, limit: limit))
        return Paginated(
            items: try response.products.map(ProductSummary.init),
            total: response.total,
            offset: response.skip   // 서버가 적용한 값. 요청값과 다를 수 있음
        )
    }

    func product(id: String) async throws -> ProductDetail {
        let dto = try await client.send(ProductEndpoint.detail(id: id))
        return try ProductDetail(dto)
    }
}
