import Foundation

/// 테스트별 고유 디렉터리. 상호 간섭 방지
func makeTempDirectory() -> URL {
    FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
}
