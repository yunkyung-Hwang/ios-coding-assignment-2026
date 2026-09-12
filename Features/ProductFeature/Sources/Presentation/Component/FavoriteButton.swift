import SwiftUI

struct FavoriteButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isOn ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tertiary))
                .frame(width: Metrics.touchSize, height: Metrics.touchSize)
                .contentShape(Rectangle())
        }
        // 없으면 Image 가 accentColor 로 칠해진다
        .buttonStyle(.plain)
    }
}

private enum Metrics {
    /// 셀 안에서도 줄이지 않는다
    static let touchSize: CGFloat = 44
}
