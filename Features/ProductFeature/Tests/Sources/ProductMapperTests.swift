import Foundation
import ProductFeatureInterface
import Testing
@testable import ProductFeature

@Suite("상품 응답 변환")
struct ProductMappingTests {

    private func decodePage() throws -> ProductListResponseDTO {
        try JSONDecoder().decode(ProductListResponseDTO.self, from: Data(ProductFixture.list.utf8))
    }

    private func decodeDetail() throws -> ProductDetailDTO {
        try JSONDecoder().decode(ProductDetailDTO.self, from: Data(ProductFixture.detail.utf8))
    }

    @Test("[R-01] 목록 응답이 상품 목록으로 변환된다")
    func mapsList() throws {
        let summary = try ProductSummary(decodePage().products[0])

        #expect(summary.id == "1")
        #expect(summary.name == "Essence Mascara Lash Princess")
        #expect(summary.price == Decimal(string: "9.99"))
        #expect(summary.thumbnailURL == URL(string: "https://cdn.dummyjson.com/p/1/thumbnail.webp"))
        #expect(summary.rating == 2.56)
        #expect(summary.reviewCount == 3)
    }

    @Test("[R-01] 부가 항목이 빠져도 변환된다")
    func mapsProductWithRequiredFieldsOnly() throws {
        let dto = try JSONDecoder().decode(ProductSummaryDTO.self, from: Data(ProductFixture.minimal.utf8))

        let summary = try ProductSummary(dto)

        #expect(summary.name == "Powder Canister")
        #expect(summary.price == Decimal(string: "14.99"))
        #expect(summary.rating == nil)
        #expect(summary.reviewCount == nil)
    }

    @Test("[R-01] 이미지 주소가 잘못되면 오류로 드러난다")
    func reportsInvalidImageURL() throws {
        let dto = try JSONDecoder().decode(ProductSummaryDTO.self, from: Data(ProductFixture.brokenThumbnail.utf8))

        #expect(throws: ProductMappingError.invalidImageURL("")) {
            try ProductSummary(dto)
        }
    }

    @Test("[R-06] 상세 응답이 상세 상품으로 변환된다")
    func mapsDetail() throws {
        let detail = try ProductDetail(decodeDetail())

        #expect(detail.id == "2")
        #expect(detail.name == "Eyeshadow Palette with Mirror")
        #expect(detail.description == "거울이 달린 아이섀도 팔레트")
        #expect(detail.imageURLs == [
            URL(string: "https://cdn.dummyjson.com/p/2/1.webp"),
            URL(string: "https://cdn.dummyjson.com/p/2/2.webp"),
        ].compactMap { $0 })
    }

    @Test("[R-06] 사용 가능한 이미지가 없으면 오류로 드러난다")
    func reportsMissingImage() throws {
        let dto = try JSONDecoder().decode(
            ProductDetailDTO.self, from: Data(ProductFixture.detailWithoutImage.utf8)
        )

        #expect(throws: ProductMappingError.noImage(productID: "5")) {
            try ProductDetail(dto)
        }
    }

    @Test("[R-06] 표시하지 않는 응답 필드는 무시된다")
    func ignoresUnusedFields() throws {
        #expect(try decodePage().products.count == 2)
    }
}
