import CoreKit

/// 상품 목록 조회
public protocol FetchProductListUseCase: Sendable {
    func execute(offset: Int, limit: Int) async throws -> Paginated<ProductSummary>
}
