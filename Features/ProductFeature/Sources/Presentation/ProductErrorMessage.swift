import NetworkKit

/// 오류를 화면 문구로 옮긴다
/// NetworkKit 은 종류만 전달하고 문구는 화면 계층이 만든다
enum ProductErrorMessage {
    static func text(for error: Error) -> String {
        switch error {
        case APIError.transport:
            "네트워크에 연결할 수 없습니다"
        case let APIError.server(_, message?):
            message
        case let APIError.server(status, nil):
            "서버 오류가 발생했습니다 (\(status))"
        default:
            "잠시 후 다시 시도해 주세요"
        }
    }
}
