/// 페이지 단위 조회 결과
public struct Paginated<Item: Sendable>: Sendable {
    public let items: [Item]
    public let total: Int
    public let offset: Int

    public init(items: [Item], total: Int, offset: Int) {
        self.items = items
        self.total = total
        self.offset = offset
    }

    public var hasMore: Bool { nextOffset < total }
    public var nextOffset: Int { offset + items.count }
}

extension Paginated: Equatable where Item: Equatable {}
