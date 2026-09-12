enum ProductMappingError: Error, Equatable {
    /// 목록 — 썸네일 주소를 URL 로 만들 수 없음
    case invalidImageURL(String)
    /// 상세 — 사용 가능한 이미지가 하나도 없음
    case noImage(productID: String)
}
