/// 상품 화면 간 이동 요청
/// 구현은 NavigationStack 을 소유한 호스트가 맡는다
@MainActor
public protocol ProductCoordinating: AnyObject {
    func showDetail(id: String)
}
