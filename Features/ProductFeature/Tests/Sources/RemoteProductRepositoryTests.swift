import Foundation
import NetworkKit
import Testing
@testable import ProductFeature

/// 보낸 요청을 기록하고 고정 응답을 돌려주는 대역
private actor StubAPIClient: APIClient {
    private(set) var paths: [String] = []
    private(set) var queries: [[URLQueryItem]] = []

    private let json: Data

    init(json: String) {
        self.json = Data(json.utf8)
    }

    func send<Response>(_ request: Request<Response>) async throws -> Response {
        paths.append(request.path)
        queries.append(request.query)
        return try JSONDecoder().decode(Response.self, from: json)
    }
}

@Suite("상품 원격 저장소")
struct RemoteProductRepositoryTests {

    @Test("[R-01] 오프셋과 개수가 skip·limit 로 전달된다")
    func sendsPagingQuery() async throws {
        let client = StubAPIClient(json: ProductFixture.list)
        let repository = RemoteProductRepository(client: client)

        _ = try await repository.products(offset: 30, limit: 20)

        #expect(await client.paths == ["products"])
        #expect(await client.queries.first == [
            URLQueryItem(name: "skip", value: "30"),
            URLQueryItem(name: "limit", value: "20"),
        ])
    }

    @Test("[R-01] 응답의 total 과 skip 이 페이지 정보가 된다")
    func mapsPageInfo() async throws {
        let repository = RemoteProductRepository(client: StubAPIClient(json: ProductFixture.list))

        let page = try await repository.products(offset: 0, limit: 2)

        #expect(page.items.count == 2)
        #expect(page.total == 194)
        #expect(page.offset == 30)   // 요청값이 아니라 서버 응답값
        #expect(page.hasMore)
    }

    @Test("[R-06] 상품 ID 가 경로에 포함된다")
    func sendsDetailPath() async throws {
        let client = StubAPIClient(json: ProductFixture.detail)
        let repository = RemoteProductRepository(client: client)

        let detail = try await repository.product(id: "2")

        #expect(await client.paths == ["products/2"])
        #expect(detail.id == "2")
    }
}
