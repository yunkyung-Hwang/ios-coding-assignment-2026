import Foundation

enum PriceFormatter {
    /// 천 단위 구분만. 통화 기호는 표시 쪽이 붙인다
    /// 로캘 고정 — 사용자 설정에 따라 구분자가 달라지지 않게
    private static let style = Decimal.FormatStyle(locale: Locale(identifier: "en_US"))

    static func string(from price: Decimal) -> String {
        price.formatted(style)
    }
}
