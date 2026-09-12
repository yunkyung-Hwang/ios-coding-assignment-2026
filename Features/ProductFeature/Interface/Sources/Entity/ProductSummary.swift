import Foundation

/// 목록에 표시할 상품
public struct ProductSummary: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let thumbnailURL: URL

    public let rating: Double?
    public let reviewCount: Int?

    public init(
        id: String,
        name: String,
        price: Decimal,
        thumbnailURL: URL,
        rating: Double? = nil,
        reviewCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.thumbnailURL = thumbnailURL
        self.rating = rating
        self.reviewCount = reviewCount
    }
}
