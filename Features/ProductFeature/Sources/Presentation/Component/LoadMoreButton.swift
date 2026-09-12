import SwiftUI

struct LoadMoreButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                // 프레임은 그대로 두고 내용만 교체한다
                if isLoading {
                    ProgressView()
                } else {
                    HStack(spacing: Metrics.textToSymbol) {
                        Text("더 보기")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "plus")
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: Metrics.height)
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .stroke(Color(.separator))
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .disabled(isLoading)
    }
}

private enum Metrics {
    static let height: CGFloat = 56
    static let cornerRadius: CGFloat = 8
    static let textToSymbol: CGFloat = 4
}
