import Observation

/// 페이지 단위 목록 로딩 상태 관리
/// 첫 로드(state)와 추가 로드(more)를 분리 — "목록은 떠 있고 추가 로딩 중" 표현용
@MainActor @Observable
public final class Paginator<Item: Sendable> {

    public enum More: Equatable, Sendable {
        /// 더 불러올 항목 없음
        case exhausted
        case available
        case loading
        case failed(String)
    }

    public private(set) var state: LoadState<[Item]> = .idle
    public private(set) var more: More = .exhausted

    /// 서버가 알려준 전체 개수. 첫 로드 전에는 0
    public private(set) var total = 0

    public var items: [Item] { state.value ?? [] }

    private var nextOffset = 0
    private let pageSize: Int
    private let fetch: @Sendable (_ offset: Int, _ limit: Int) async throws -> Paginated<Item>
    private let errorMessage: @Sendable (Error) -> String

    /// - Parameter errorMessage: 오류를 화면 문구로 변환. 도메인별 매핑은 호출부가 담당
    public init(
        pageSize: Int,
        errorMessage: @escaping @Sendable (Error) -> String = { String(describing: $0) },
        fetch: @escaping @Sendable (_ offset: Int, _ limit: Int) async throws -> Paginated<Item>
    ) {
        self.pageSize = pageSize
        self.errorMessage = errorMessage
        self.fetch = fetch
    }

    public func loadFirst() async {
        guard !isBusy else { return }
        state = .loading
        more = .exhausted
        do {
            let page = try await fetch(0, pageSize)
            state = .loaded(page.items)
            total = page.total
            nextOffset = page.nextOffset
            more = page.hasMore ? .available : .exhausted
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed(errorMessage(error))
        }
    }

    public func loadMore() async {
        guard let current = state.value else { return }
        guard more == .available || isRetryable else { return }
        more = .loading
        do {
            let page = try await fetch(nextOffset, pageSize)
            state = .loaded(current + page.items)
            nextOffset = page.nextOffset
            more = page.hasMore ? .available : .exhausted
        } catch is CancellationError {
            more = .available
        } catch {
            more = .failed(errorMessage(error))   // 기존 목록은 유지
        }
    }

    private var isBusy: Bool {
        state.isLoading || more == .loading
    }

    private var isRetryable: Bool {
        if case .failed = more { return true }
        return false
    }
}
