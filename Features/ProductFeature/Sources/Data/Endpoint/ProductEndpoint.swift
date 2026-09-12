import Foundation
import NetworkKit

/// DummyJSON 상품 API
enum ProductEndpoint {
    static func list(skip: Int, limit: Int) -> Request<ProductListResponseDTO> {
        Request(
            "products",
            query: [
                URLQueryItem(name: "skip", value: String(skip)),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        )
    }

    static func detail(id: String) -> Request<ProductDetailDTO> {
        Request("products/\(id)")
    }
}
