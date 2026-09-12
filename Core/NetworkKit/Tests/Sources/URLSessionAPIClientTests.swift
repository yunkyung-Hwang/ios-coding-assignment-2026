import Foundation
import Testing
@testable import NetworkKit

private struct Sample: Decodable, Sendable, Equatable {
    let id: Int
    let title: String
}

private func makeClient() -> URLSessionAPIClient {
    URLSessionAPIClient(
        baseURL: URL(string: "https://example.com")!,
        session: MockURLProtocol.makeSession()
    )
}

@Suite("API 클라이언트", .serialized)
struct URLSessionAPIClientTests {

    @Test("200 응답을 디코딩한다")
    func decodesSuccess() async throws {
        MockURLProtocol.respond(status: 200, body: #"{"id":1,"title":"사과"}"#)
        let result: Sample = try await makeClient().send(Request("/items/1"))
        #expect(result == Sample(id: 1, title: "사과"))
    }

    @Test("404 응답 본문의 message 를 담아 server 오류를 던진다")
    func extractsServerMessage() async {
        MockURLProtocol.respond(status: 404, body: #"{"message":"Product with id '99999' not found"}"#)
        await #expect(throws: APIError.server(status: 404, message: "Product with id '99999' not found")) {
            let _: Sample = try await makeClient().send(Request("/items/99999"))
        }
    }

    @Test("message 가 없는 오류 응답은 message 없이 server 오류가 된다")
    func statusWithoutMessage() async {
        MockURLProtocol.respond(status: 500, body: "<html>오류</html>")
        await #expect(throws: APIError.server(status: 500, message: nil)) {
            let _: Sample = try await makeClient().send(Request("/items/1"))
        }
    }

    @Test("연결 실패는 transport 오류가 된다")
    func transportFailure() async {
        MockURLProtocol.fail(URLError(.notConnectedToInternet))
        await #expect(throws: APIError.self) {
            let _: Sample = try await makeClient().send(Request("/items/1"))
        }
    }

    @Test("스키마가 맞지 않으면 malformed 오류가 된다")
    func decodingFailure() async {
        MockURLProtocol.respond(status: 200, body: #"{"id":"문자열"}"#)
        await #expect(throws: APIError.self) {
            let _: Sample = try await makeClient().send(Request("/items/1"))
        }
    }

    @Test("요청 진행 중 취소는 CancellationError 로 드러난다")
    func cancellationDuringRequest() async {
        MockURLProtocol.handler = { request in
            Thread.sleep(forTimeInterval: 0.3)
            let response = HTTPURLResponse(
                url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, Data(#"{"id":1,"title":"사과"}"#.utf8))
        }
        let client = makeClient()

        let task = Task { let _: Sample = try await client.send(Request("/items/1")) }
        try? await Task.sleep(nanoseconds: 80_000_000)
        task.cancel()

        await #expect(throws: CancellationError.self) { try await task.value }
    }

    @Test("헤더를 요청에 실어 보낸다")
    func sendsHeaders() async throws {
        nonisolated(unsafe) var captured: [String: String]?
        MockURLProtocol.handler = { request in
            captured = request.allHTTPHeaderFields
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(#"{"id":1,"title":"a"}"#.utf8))
        }
        let _: Sample = try await makeClient()
            .send(Request("/items", headers: ["X-Trace": "abc"]))
        #expect(captured?["X-Trace"] == "abc")
    }

    @Test("JSON 본문을 인코딩하고 Content-Type 을 설정한다")
    func encodesJSONBody() async throws {
        struct Payload: Encodable, Sendable { let name: String }
        nonisolated(unsafe) var capturedBody: Data?
        nonisolated(unsafe) var capturedType: String?
        MockURLProtocol.handler = { request in
            capturedBody = request.httpBodyStream.map { stream in
                stream.open()
                defer { stream.close() }
                var data = Data()
                var buffer = [UInt8](repeating: 0, count: 1024)
                while stream.hasBytesAvailable {
                    let read = stream.read(&buffer, maxLength: buffer.count)
                    if read <= 0 { break }
                    data.append(buffer, count: read)
                }
                return data
            }
            capturedType = request.value(forHTTPHeaderField: "Content-Type")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(#"{"id":1,"title":"a"}"#.utf8))
        }
        let _: Sample = try await makeClient()
            .send(Request("/items", method: .post, body: .json(Payload(name: "사과"))))
        #expect(capturedType == "application/json")
        #expect(capturedBody.map { String(decoding: $0, as: UTF8.self) } == #"{"name":"사과"}"#)
    }

    @Test("쿼리를 URL 에 붙인다")
    func buildsQuery() async throws {
        nonisolated(unsafe) var captured: URL?
        MockURLProtocol.handler = { request in
            captured = request.url
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(#"{"id":1,"title":"a"}"#.utf8))
        }
        let _: Sample = try await makeClient().send(Request("/items", query: [
            URLQueryItem(name: "skip", value: "0"),
            URLQueryItem(name: "limit", value: "50"),
        ]))
        #expect(captured?.query == "skip=0&limit=50")
    }

    @Test("값 없는 키도 쿼리에 포함한다")
    func supportsValuelessKey() async throws {
        nonisolated(unsafe) var captured: URL?
        MockURLProtocol.handler = { request in
            captured = request.url
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(#"{"id":1,"title":"a"}"#.utf8))
        }
        let _: Sample = try await makeClient()
            .send(Request("/items", query: [URLQueryItem(name: "debug", value: nil)]))
        #expect(captured?.query == "debug")
    }
}
