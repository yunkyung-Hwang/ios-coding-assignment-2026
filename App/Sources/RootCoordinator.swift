import Observation
import ProductFeatureInterface
import SwiftUI

/// NavigationStack 의 path 를 소유한다. View 를 만들지 않는다
@MainActor
@Observable
final class RootCoordinator: ProductCoordinating {
    var path: [ProductRoute] = []

    func showDetail(id: String) {
        path.append(.detail(id: id))
    }
}
