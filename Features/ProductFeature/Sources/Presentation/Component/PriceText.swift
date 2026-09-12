import SwiftUI

struct PriceText: View {
    enum Style {
        case list
        case detail
    }

    let price: Decimal
    let style: Style

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("$")
                .font(symbolFont)
            Text(PriceFormatter.string(from: price))
                .font(amountFont)
        }
        .foregroundStyle(.primary)
    }

    private var amountFont: Font {
        switch style {
        case .list: .body.bold()
        case .detail: .title3.weight(.bold)
        }
    }

    /// 금액과 한 단계 차이를 유지한다
    private var symbolFont: Font {
        switch style {
        case .list: .callout.weight(.medium)
        case .detail: .body.bold()
        }
    }
}
