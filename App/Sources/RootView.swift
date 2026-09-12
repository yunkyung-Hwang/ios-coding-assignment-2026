import ProductFeatureInterface
import SwiftUI

struct RootView: View {
    @State private var coordinator = RootCoordinator()

    private let root: CompositionRoot

    init(root: CompositionRoot) {
        self.root = root
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root.productAssembly
                .list(coordinator: coordinator)
                .navigationDestination(for: ProductRoute.self) { route in
                    switch route {
                    case let .detail(id):
                        root.productAssembly.detail(id: id)
                    }
                }
        }
        // 저장된 찜을 화면이 뜨기 전에 올린다
        .task { await root.favoriteStore.load() }
    }
}
