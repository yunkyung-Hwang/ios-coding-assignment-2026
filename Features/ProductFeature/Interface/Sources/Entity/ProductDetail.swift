import Foundation

/// 상세 화면에 표시할 상품
public struct ProductDetail: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let price: Decimal
    public let imageURLs: [URL]

    public let rating: Double?
    public let reviewCount: Int?
    public let description: String?

    public init(
        id: String,
        name: String,
        price: Decimal,
        imageURLs: [URL],
        rating: Double? = nil,
        reviewCount: Int? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.imageURLs = imageURLs
        self.rating = rating
        self.reviewCount = reviewCount
        self.description = description
    }
}
