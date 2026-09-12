import Foundation
import Testing
@testable import StorageKit

/// 테스트별 고유 디렉터리. 상호 간섭 방지
private func makeTempDirectory() -> URL {
    FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
}

@Suite("파일 저장소")
struct FileStoreTests {

    @Test("저장한 값을 그대로 읽는다")
    func saveAndLoad() async throws {
        let store = FileStore(directory: makeTempDirectory())
        try await store.save(Set(["1", "2"]), to: "ids.json")
        let loaded = try await store.load(Set<String>.self, from: "ids.json")
        #expect(loaded == ["1", "2"])
    }

    /// path() 가 퍼센트 인코딩하는 세 부류. 앱 지원 디렉터리 경로에 공백이 들어 있어 실사용 경로가 여기 해당
    @Test("퍼센트 인코딩 대상 문자가 든 경로에서도 저장한 값을 읽는다", arguments: [
        "Application Support",   // 공백
        "한글폴더",                // 비ASCII
        "tag#1",                 // URL 예약문자
    ])
    func readsBackFromPathNeedingEncoding(directoryName: String) async throws {
        // UUID 는 별도 상위 경로로 분리. 부류별 문자 하나만 남긴다
        let directory = makeTempDirectory().appending(path: directoryName)
        let store = FileStore(directory: directory)

        try await store.save(Set(["5"]), to: "ids.json")

        let loaded = try await store.load(Set<String>.self, from: "ids.json")
        #expect(loaded == ["5"])
    }

    @Test("저장한 적 없는 파일은 nil 을 반환한다")
    func loadMissingFile() async throws {
        let store = FileStore(directory: makeTempDirectory())
        let loaded = try await store.load(Set<String>.self, from: "없는파일.json")
        #expect(loaded == nil)
    }

    @Test("같은 파일에 다시 저장하면 이전 값을 대체한다")
    func overwrite() async throws {
        let store = FileStore(directory: makeTempDirectory())
        try await store.save(Set(["1"]), to: "ids.json")
        try await store.save(Set(["2", "3"]), to: "ids.json")
        let loaded = try await store.load(Set<String>.self, from: "ids.json")
        #expect(loaded == ["2", "3"])
    }

    @Test("동시에 저장해도 파일이 손상되지 않는다")
    func concurrentWrites() async throws {
        let store = FileStore(directory: makeTempDirectory())
        await withTaskGroup(of: Void.self) { group in
            for index in 0 ..< 50 {
                group.addTask { try? await store.save(Set(["\(index)"]), to: "ids.json") }
            }
        }
        let loaded = try await store.load(Set<String>.self, from: "ids.json")
        #expect(loaded?.count == 1)   // 마지막 쓰기 하나만 남는다
    }
}
