/// 요청 실패 원인
/// 사용자 문구는 화면 계층이 만든다
public enum APIError: Error, Sendable, Equatable {
    /// 연결 실패·타임아웃
    case transport
    /// 2xx 외 응답. message 는 응답 본문에서 추출
    case server(status: Int, message: String?)
    /// 요청을 만들지 못했거나 응답을 해석하지 못함
    case malformed
}
