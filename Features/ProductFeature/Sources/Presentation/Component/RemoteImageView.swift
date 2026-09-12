import SwiftUI

/// 원격 이미지
/// 로딩·실패를 구분하지 않고 같은 배경을 보인다
struct RemoteImageView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color(.secondarySystemFill)
        }
        .clipped()
    }
}
