import Testing
@testable import CoreKit

private struct Item: Sendable, Equatable { let id: Int }
private struct FetchFailure: Error {}

/// 지정한 총 건수를 페이지 단위로 잘라주는 가짜 서버
private final class FakeServer: @unchecked Sendable {
    let total: Int
    private(set) var callCount = 0
    var failNext = false

    init(total: Int) { self.total = total }

    func fetch(offset: Int, limit: Int) async throws -> Paginated<Item> {
        callCount += 1
        if failNext {
            failNext = false
            throw FetchFailure()
        }
        let end = min(offset + limit, total)
        let items = (offset ..< max(offset, end)).map { Item(id: $0) }
        return Paginated(items: items, total: total, offset: offset)
    }
}

@Suite("페이지네이션")
struct PaginatorTests {

    @MainActor
    @Test("첫 페이지를 불러오면 전체 개수를 알게 된다")
    func exposesTotal() async {
        let server = FakeServer(total: 194)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }

        await paginator.loadFirst()

        #expect(paginator.total == 194)
    }

    @MainActor
    @Test("첫 페이지를 불러오면 더보기가 활성화된다")
    func loadsFirstPage() async {
        let server = FakeServer(total: 194)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }
        await paginator.loadFirst()
        #expect(paginator.items.count == 50)
        #expect(paginator.more == .available)
    }

    @MainActor
    @Test("더보기를 반복하면 전체를 불러온 뒤 소진된다")
    func loadsUntilExhausted() async {
        let server = FakeServer(total: 194)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }
        await paginator.loadFirst()
        var taps = 0
        while paginator.more == .available {
            await paginator.loadMore()
            taps += 1
        }
        #expect(paginator.items.count == 194)
        #expect(taps == 3)
        #expect(server.callCount == 4)
        #expect(Set(paginator.items.map(\.id)).count == 194)   // 중복 없음
    }

    @MainActor
    @Test("첫 로드 전에는 더보기가 동작하지 않는다")
    func ignoresLoadMoreBeforeFirst() async {
        let server = FakeServer(total: 194)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }
        await paginator.loadMore()
        #expect(server.callCount == 0)
        #expect(paginator.items.isEmpty)
    }

    @MainActor
    @Test("더보기가 실패해도 이미 불러온 목록은 유지된다")
    func keepsItemsOnFailure() async {
        let server = FakeServer(total: 194)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }
        await paginator.loadFirst()
        server.failNext = true
        await paginator.loadMore()

        guard case .failed = paginator.more else {
            Issue.record("실패 상태여야 한다")
            return
        }
        #expect(paginator.items.count == 50)
    }

    @MainActor
    @Test("더보기 실패 후 재시도하면 이어서 불러온다")
    func retriesAfterFailure() async {
        let server = FakeServer(total: 194)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }
        await paginator.loadFirst()
        server.failNext = true
        await paginator.loadMore()
        await paginator.loadMore()
        #expect(paginator.items.count == 100)
        #expect(paginator.more == .available)
    }

    @MainActor
    @Test("결과가 없으면 빈 목록으로 로드된다")
    func emptyResult() async {
        let server = FakeServer(total: 0)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }
        await paginator.loadFirst()
        #expect(paginator.state == .loaded([]))
        #expect(paginator.items.isEmpty)
        #expect(paginator.more == .exhausted)
    }

    @MainActor
    @Test("마지막 페이지를 정확히 채우면 더 이상 요청하지 않는다")
    func exactPageBoundary() async {
        let server = FakeServer(total: 100)
        let paginator = Paginator<Item>(pageSize: 50) { try await server.fetch(offset: $0, limit: $1) }
        await paginator.loadFirst()
        await paginator.loadMore()
        #expect(paginator.items.count == 100)
        #expect(paginator.more == .exhausted)
        #expect(server.callCount == 2)
    }
}
