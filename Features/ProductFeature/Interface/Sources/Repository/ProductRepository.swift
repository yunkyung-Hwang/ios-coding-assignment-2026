import CoreKit

/// 상품 조회
public protocol ProductRepository: Sendable {
    func products(offset: Int, limit: Int) async throws -> Paginated<ProductSummary>
    func product(id: String) async throws -> ProductDetail
}
