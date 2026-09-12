import Foundation

/// 응답 타입을 함께 갖는 HTTP 요청
public struct Request<Response: Decodable & Sendable>: Sendable {

    /// 본문 인코딩은 APIClient 가 담당. 호출부는 형태만 지정
    public enum Body: Sendable {
        case json(any Encodable & Sendable)
        case form([URLQueryItem])
        case data(Data, contentType: String)
    }

    public let method: HTTPMethod
    public let path: String
    public let query: [URLQueryItem]
    public let headers: [String: String]
    public let body: Body?

    public init(
        _ path: String,
        method: HTTPMethod = .get,
        query: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Body? = nil
    ) {
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
    }
}
