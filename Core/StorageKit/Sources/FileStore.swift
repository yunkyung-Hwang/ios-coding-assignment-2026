import Foundation

/// JSON 파일 기반 저장소
/// actor — 동시 쓰기로 인한 파일 손상 방지 목적의 직렬화
public actor FileStore {
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// - Parameter directory: 기본값은 앱 지원 디렉터리. 테스트는 임시 경로 주입
    public init(directory: URL? = nil) {
        self.directory = directory ?? FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    public func save<Value: Encodable>(_ value: Value, to fileName: String) throws {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try encoder.encode(value)
            try data.write(to: directory.appending(path: fileName), options: .atomic)
        } catch {
            throw StorageError.write(error.localizedDescription)
        }
    }

    /// 파일 부재 시 nil. 저장 이력 없음과 읽기 실패를 구분하기 위함
    public func load<Value: Decodable>(_ type: Value.Type, from fileName: String) throws -> Value? {
        let url = directory.appending(path: fileName)
        // path() 는 기본이 퍼센트 인코딩. 공백·비ASCII·예약문자가 든 경로는 조회 실패
        guard FileManager.default.fileExists(atPath: url.path(percentEncoded: false)) else { return nil }
        do {
            return try decoder.decode(Value.self, from: Data(contentsOf: url))
        } catch {
            throw StorageError.read(error.localizedDescription)
        }
    }
}
