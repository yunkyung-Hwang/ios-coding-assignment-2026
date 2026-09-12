/// 상품 상세 조회
public protocol FetchProductDetailUseCase: Sendable {
    func execute(id: String) async throws -> ProductDetail
}
