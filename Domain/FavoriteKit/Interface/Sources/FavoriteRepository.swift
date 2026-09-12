/// 찜 ID 집합 영속화
public protocol FavoriteRepository: Sendable {
    /// 저장 이력이 없으면 빈 집합
    func load() async throws -> Set<String>
    func save(_ ids: Set<String>) async throws
}
