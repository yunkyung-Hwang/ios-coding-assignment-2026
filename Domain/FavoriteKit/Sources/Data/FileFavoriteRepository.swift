import FavoriteKitInterface
import Foundation
import StorageKit

/// JSON 파일 기반 찜 저장소
public struct FileFavoriteRepository: FavoriteRepository {
    private static let fileName = "favorites.json"

    private let store: FileStore

    /// - Parameter directory: 기본값은 앱 지원 디렉터리. 테스트는 임시 경로 주입
    public init(directory: URL? = nil) {
        store = FileStore(directory: directory)
    }

    public func load() async throws -> Set<String> {
        try await store.load(Set<String>.self, from: Self.fileName) ?? []
    }

    public func save(_ ids: Set<String>) async throws {
        try await store.save(ids, to: Self.fileName)
    }
}
