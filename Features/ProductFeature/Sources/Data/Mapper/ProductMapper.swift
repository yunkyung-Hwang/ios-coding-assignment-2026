import Foundation
import ProductFeatureInterface

extension ProductSummary {
    init(_ dto: ProductSummaryDTO) throws {
        self.init(
            id: String(dto.id),
            name: dto.title,
            price: dto.price,
            thumbnailURL: try requiredImageURL(dto.thumbnail),
            rating: dto.rating,
            reviewCount: dto.reviews?.count
        )
    }
}

extension ProductDetail {
    init(_ dto: ProductDetailDTO) throws {
        let imageURLs = dto.images.compactMap(URL.init(string:))
        guard !imageURLs.isEmpty else {
            throw ProductMappingError.noImage(productID: String(dto.id))
        }
        self.init(
            id: String(dto.id),
            name: dto.title,
            price: dto.price,
            imageURLs: imageURLs,
            rating: dto.rating,
            reviewCount: dto.reviews?.count,
            description: dto.description
        )
    }
}

private func requiredImageURL(_ text: String) throws -> URL {
    guard let url = URL(string: text) else {
        throw ProductMappingError.invalidImageURL(text)
    }
    return url
}
