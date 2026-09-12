import SwiftUI

enum ProductLayout: CaseIterable {
    case list
    case grid

    /// 배열 길이만 바꿔 1열·2열을 전환한다
    /// alignment .top — 행 높이가 아니라 셀 내부를 위로 정렬해 title 길이 차이를 그대로 둔다
    var columns: [GridItem] {
        switch self {
        case .list:
            [GridItem(.flexible(), spacing: 0, alignment: .top)]
        case .grid:
            Array(repeating: GridItem(.flexible(), spacing: Metrics.columnSpacing, alignment: .top), count: 2)
        }
    }

    /// 현재 상태가 아니라 전환 대상을 가리킨다
    var toggleSymbol: String {
        switch self {
        case .list: "square.grid.2x2"
        case .grid: "list.bullet"
        }
    }

    mutating func toggle() {
        self = self == .list ? .grid : .list
    }
}

private enum Metrics {
    static let columnSpacing: CGFloat = 12
}
