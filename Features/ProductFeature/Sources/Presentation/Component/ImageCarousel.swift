import SwiftUI

struct ImageCarousel: View {
    let urls: [URL]

    @State private var index = 0

    var body: some View {
        TabView(selection: $index) {
            ForEach(Array(urls.enumerated()), id: \.offset) { offset, url in
                RemoteImageView(url: url)
                    .tag(offset)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .aspectRatio(Metrics.aspectRatio, contentMode: .fit)
        .overlay(alignment: .bottomTrailing) {
            // 1장이어도 노출한다
            PageIndicator(current: index + 1, total: urls.count)
                .padding(Metrics.indicatorInset)
        }
    }
}

private enum Metrics {
    static let aspectRatio: CGFloat = 1
    static let indicatorInset: CGFloat = 16
}
