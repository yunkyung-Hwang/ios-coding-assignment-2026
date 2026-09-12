import Testing
@testable import FavoriteKit

@Suite("찜 저장소")
struct FileFavoriteRepositoryTests {

    @Test("[R-04] 저장한 찜 목록을 다시 읽으면 같다")
    func saveAndLoad() async throws {
        let repository = FileFavoriteRepository(directory: makeTempDirectory())
        try await repository.save(["1", "3"])
        let loaded = try await repository.load()
        #expect(loaded == ["1", "3"])
    }

    @Test("저장 이력이 없으면 빈 집합이다")
    func loadWithoutHistory() async throws {
        let repository = FileFavoriteRepository(directory: makeTempDirectory())
        let loaded = try await repository.load()
        #expect(loaded.isEmpty)
    }
}
