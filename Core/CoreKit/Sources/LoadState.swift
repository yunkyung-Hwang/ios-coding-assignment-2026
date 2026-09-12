/// 비동기 로딩의 화면 상태
public enum LoadState<Value: Sendable>: Sendable {
    /// 요청 전. 취소 시 복귀 지점
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

extension LoadState: Equatable where Value: Equatable {}

public extension LoadState {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: Value? {
        if case let .loaded(value) = self { return value }
        return nil
    }
}
