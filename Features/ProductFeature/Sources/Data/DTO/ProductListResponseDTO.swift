/// 목록 응답 껍데기
struct ProductListResponseDTO: Decodable, Sendable {
    let products: [ProductSummaryDTO]
    let total: Int
    let skip: Int
}
