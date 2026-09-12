import Foundation
import Testing
@testable import ProductFeature

@Suite("가격 표시")
struct PriceFormatterTests {

    @Test("[R-01] 천 단위를 구분한다")
    func groupsThousands() {
        #expect(PriceFormatter.string(from: Decimal(string: "36999.99")!) == "36,999.99")
    }

    @Test("[R-01] 천 단위 미만은 구분자가 없다")
    func keepsSmallAmount() {
        #expect(PriceFormatter.string(from: Decimal(string: "9.99")!) == "9.99")
    }

    @Test("[R-01] 통화 기호나 단위를 붙이지 않는다")
    func omitsCurrencySymbol() {
        let text = PriceFormatter.string(from: Decimal(string: "1234")!)

        #expect(text == "1,234")
    }
}
