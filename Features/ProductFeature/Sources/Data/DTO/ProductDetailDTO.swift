import Foundation

/// 상세 응답
/// thumbnail 은 images[0] 의 축소판이라 선언하지 않음
struct ProductDetailDTO: Decodable, Sendable {
    struct Review: Decodable, Sendable {}

    let id: Int
    let title: String
    let price: Decimal
    let images: [String]

    let rating: Double?
    let reviews: [Review]?
    let description: String?
}
