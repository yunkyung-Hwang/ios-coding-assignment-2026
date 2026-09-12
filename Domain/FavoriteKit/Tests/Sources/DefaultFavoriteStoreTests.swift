import FavoriteKitInterface
import Observation
import Testing
@testable import FavoriteKit

private struct StubFailure: Error {}

/// 저장 동작을 제어하는 대역
private actor StubFavoriteRepository: FavoriteRepository {
    private var stored: Set<String>
    private var failsLoad: Bool
    private var failsFirstSave: Bool

    init(stored: Set<String> = [], failsLoad: Bool = false, failsFirstSave: Bool = false) {
        self.stored = stored
        self.failsLoad = failsLoad
        self.failsFirstSave = failsFirstSave
    }

    func storedIds() -> Set<String> { stored }

    func load() async throws -> Set<String> {
        guard !failsLoad else { throw StubFailure() }
        return stored
    }

    func save(_ ids: Set<String>) async throws {
        let fails = failsFirstSave
        failsFirstSave = false
        guard !fails else { throw StubFailure() }
        stored = ids
    }
}

@Suite("찜")
struct FavoriteTests {

    @Suite("앱을 처음 실행하면")
    @MainActor
    struct FirstLaunch {
        let store = DefaultFavoriteStore(
            repository: FileFavoriteRepository(directory: makeTempDirectory())
        )

        @Test("[R-04] 찜 목록이 비어 있다")
        func startsEmpty() async {
            await store.load()

            #expect(store.ids.isEmpty)
        }
    }

    @Suite("상품을 찜하면")
    @MainActor
    struct Favoriting {
        let directory = makeTempDirectory()

        @Test("[R-03] 찜 목록에 추가된다")
        func addsToFavorites() async {
            let store = DefaultFavoriteStore(repository: FileFavoriteRepository(directory: directory))

            await store.toggle("1")

            #expect(store.ids == ["1"])
        }

        @Test("[R-04] 앱을 다시 실행해도 유지된다")
        func survivesRelaunch() async {
            let store = DefaultFavoriteStore(repository: FileFavoriteRepository(directory: directory))
            await store.toggle("1")

            let relaunched = DefaultFavoriteStore(repository: FileFavoriteRepository(directory: directory))
            await relaunched.load()

            #expect(relaunched.ids == ["1"])
        }
    }

    @Suite("찜한 상품을 다시 토글하면")
    @MainActor
    struct Unfavoriting {
        let directory = makeTempDirectory()

        @Test("[R-03] 찜이 해제된다")
        func removesFromFavorites() async {
            let store = DefaultFavoriteStore(repository: FileFavoriteRepository(directory: directory))
            await store.toggle("1")

            await store.toggle("1")

            #expect(store.ids.isEmpty)
        }

        @Test("[R-04] 앱을 다시 실행해도 해제 상태가 유지된다")
        func survivesRelaunch() async {
            let store = DefaultFavoriteStore(repository: FileFavoriteRepository(directory: directory))
            await store.toggle("1")
            await store.toggle("1")

            let relaunched = DefaultFavoriteStore(repository: FileFavoriteRepository(directory: directory))
            await relaunched.load()

            #expect(relaunched.ids.isEmpty)
        }
    }

    @Suite("저장에 실패하면")
    @MainActor
    struct SaveFailure {

        @Test("[R-03] 찜 상태가 되돌아간다")
        func revertsToggle() async {
            let store = DefaultFavoriteStore(repository: StubFavoriteRepository(failsFirstSave: true))

            await store.toggle("1")

            #expect(store.ids.isEmpty)
        }

        @Test("[R-03] 동시에 토글하면 실패한 항목만 되돌아간다")
        func revertsOnlyFailedToggle() async {
            let store = DefaultFavoriteStore(repository: StubFavoriteRepository(failsFirstSave: true))

            async let first: Void = store.toggle("1")
            async let second: Void = store.toggle("2")
            _ = await (first, second)

            // 어느 쪽이 먼저 저장될지는 보장되지 않는다. 실패한 하나만 빠지는 것이 불변식
            #expect(store.ids.count == 1)
        }

        @Test("[R-04] 앞선 저장이 실패해도 마지막 저장이 현재 상태를 기록한다")
        func lastSaveRecordsCurrentState() async {
            let repository = StubFavoriteRepository(failsFirstSave: true)
            let store = DefaultFavoriteStore(repository: repository)

            async let first: Void = store.toggle("1")
            async let second: Void = store.toggle("2")
            _ = await (first, second)

            let stored = await repository.storedIds()
            #expect(stored == store.ids)
        }
    }

    @Suite("저장된 찜을 읽지 못하면")
    @MainActor
    struct LoadFailure {

        @Test("[R-04] 이후 찜 변경이 저장소를 대체한다")
        func replacesStorageOnNextSave() async {
            let repository = StubFavoriteRepository(stored: ["1", "2"], failsLoad: true)
            let store = DefaultFavoriteStore(repository: repository)
            await store.load()

            await store.toggle("3")

            let stored = await repository.storedIds()
            #expect(stored == ["3"])
        }
    }
}

/// 저장이 겹치는지 관측하는 대역
/// 액터는 await 지점에서 재진입을 허용하므로, 직렬화가 없으면 동시 진입이 드러난다
private actor OverlapTrackingRepository: FavoriteRepository {
    private(set) var maxConcurrent = 0
    private var current = 0

    func load() async throws -> Set<String> { [] }

    func save(_ ids: Set<String>) async throws {
        current += 1
        maxConcurrent = max(maxConcurrent, current)
        await Task.yield()          // 다른 저장이 끼어들 틈
        current -= 1
    }
}

/// onChange 는 격리되지 않은 클로저. 통지는 MainActor 의 프로퍼티 변경 중에만 발생
@MainActor
private final class ChangeFlag {
    var isNotified = false
}

@Suite("찜 저장 직렬화")
@MainActor
struct FavoriteStoreSerializationTests {

    @Test("[R-04] 여러 번 토글해도 저장이 겹치지 않는다")
    func savesDoNotOverlap() async {
        let repository = OverlapTrackingRepository()
        let store = DefaultFavoriteStore(repository: repository)

        await withTaskGroup(of: Void.self) { group in
            for id in 1 ... 10 {
                group.addTask { await store.toggle("\(id)") }
            }
        }

        #expect(await repository.maxConcurrent == 1)
    }
}

@Suite("찜 상태 관찰")
@MainActor
struct FavoriteStoreObservationTests {

    @Test("프로토콜 타입으로 주입해도 변경이 통지된다")
    func notifiesThroughProtocol() async {
        let store: any FavoriteStore = DefaultFavoriteStore(
            repository: FileFavoriteRepository(directory: makeTempDirectory())
        )
        let flag = ChangeFlag()
        withObservationTracking {
            _ = store.ids
        } onChange: {
            MainActor.assumeIsolated { flag.isNotified = true }
        }

        await store.toggle("1")

        #expect(flag.isNotified)
    }
}
