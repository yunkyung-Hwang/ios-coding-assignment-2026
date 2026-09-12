import FavoriteKitInterface
import Observation

/// 찜 상태의 단일 소유자
@MainActor
@Observable
public final class DefaultFavoriteStore: FavoriteStore {
    public private(set) var ids: Set<String> = []

    @ObservationIgnored private var pendingSave: Task<Void, Never>?
    private let repository: any FavoriteRepository

    public init(repository: any FavoriteRepository) {
        self.repository = repository
    }

    /// 적재 실패 = 파일 손상. 다음 저장이 덮어써 복구하므로 빈 목록으로 시작
    public func load() async {
        ids = (try? await repository.load()) ?? []
    }

    /// 화면에 먼저 반영한 뒤 저장
    public func toggle(_ id: String) async {
        let wasFavorite = ids.contains(id)
        apply(isFavorite: !wasFavorite, to: id)
        await save(revertingTo: wasFavorite, on: id)
    }

    /// 앞선 저장이 끝난 뒤 기록 — 액터 실행 순서에 기대지 않고 호출 순서를 보장
    /// 스냅샷을 미리 뜨지 않고 기록 직전의 상태를 써서, 앞선 저장이 롤백돼도 교정된 상태로 수렴
    private func save(revertingTo wasFavorite: Bool, on id: String) async {
        let previous = pendingSave
        let task = Task { @MainActor in
            await previous?.value
            do {
                try await repository.save(ids)
            } catch {
                apply(isFavorite: wasFavorite, to: id)   // 실패한 항목만 복원
            }
        }
        pendingSave = task
        await task.value
    }

    private func apply(isFavorite: Bool, to id: String) {
        if isFavorite {
            ids.insert(id)
        } else {
            ids.remove(id)
        }
    }
}
