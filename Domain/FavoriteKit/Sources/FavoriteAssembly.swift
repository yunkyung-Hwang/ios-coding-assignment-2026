import FavoriteKitInterface
import Foundation

/// 찜 공유 상태를 만든다
/// 인스턴스 하나를 모든 화면이 공유해야 목록·상세가 어긋나지 않는다
@MainActor
public enum FavoriteAssembly {
    public static func makeStore(directory: URL? = nil) -> any FavoriteStore {
        DefaultFavoriteStore(repository: FileFavoriteRepository(directory: directory))
    }
}
