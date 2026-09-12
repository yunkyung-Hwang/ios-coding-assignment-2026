import Observation

/// 찜 상태 공유 지점
@MainActor
public protocol FavoriteStore: AnyObject, Observable {
    var ids: Set<String> { get }

    /// 영속 상태를 메모리로 적재
    func load() async
    func toggle(_ id: String) async
}
