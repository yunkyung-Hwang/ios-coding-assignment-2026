import Foundation

/// 목록 응답의 상품
struct ProductSummaryDTO: Decodable, Sendable {
    /// 개수만 사용. 항목 내용은 표시 대상 아님
    struct Review: Decodable, Sendable {}

    let id: Int
    let title: String
    let price: Decimal
    let thumbnail: String

    let rating: Double?
    let reviews: [Review]?
}
