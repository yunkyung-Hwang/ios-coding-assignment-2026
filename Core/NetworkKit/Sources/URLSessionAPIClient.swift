import Foundation

public final class URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    public func send<Response>(_ request: Request<Response>) async throws -> Response {
        let urlRequest = try makeURLRequest(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            // 요청 진행 중 취소. 실패가 아니라 흐름 제어로 다룬다
            throw CancellationError()
        } catch {
            throw APIError.transport
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.malformed
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw APIError.server(status: http.statusCode, message: Self.serverMessage(from: data))
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.malformed
        }
    }

    private func makeURLRequest<Response>(_ request: Request<Response>) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: request.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.malformed
        }
        if !request.query.isEmpty { components.queryItems = request.query }
        guard let url = components.url else { throw APIError.malformed }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        for (field, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: field)
        }
        if let body = request.body {
            let (data, contentType) = try encode(body)
            urlRequest.httpBody = data
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }

    private func encode<Response>(_ body: Request<Response>.Body) throws -> (Data, String) {
        switch body {
        case let .json(value):
            do {
                return (try encoder.encode(value), "application/json")
            } catch {
                throw APIError.malformed
            }
        case let .form(items):
            var components = URLComponents()
            components.queryItems = items
            return (Data((components.percentEncodedQuery ?? "").utf8), "application/x-www-form-urlencoded")
        case let .data(data, contentType):
            return (data, contentType)
        }
    }

    /// 오류 응답 본문의 message 필드 추출. 없으면 nil
    private static func serverMessage(from data: Data) -> String? {
        struct ErrorBody: Decodable { let message: String }
        return try? JSONDecoder().decode(ErrorBody.self, from: data).message
    }
}
