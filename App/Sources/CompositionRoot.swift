import FavoriteKit
import FavoriteKitInterface
import Foundation
import NetworkKit
import ProductFeature

/// 구현체를 아는 유일한 곳
/// 호스트가 API 호스트를 알고, Feature 는 경로만 안다
@MainActor
struct CompositionRoot {
    let favoriteStore: any FavoriteStore
    let productAssembly: ProductAssembly

    init() {
        let client = URLSessionAPIClient(baseURL: Self.baseURL)
        let favoriteStore = FavoriteAssembly.makeStore()
        self.favoriteStore = favoriteStore
        productAssembly = ProductAssembly(client: client, favoriteStore: favoriteStore)
    }

    private static let baseURL = URL(string: "https://dummyjson.com")!
}
