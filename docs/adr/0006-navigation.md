# ADR-0006: 네비게이션

상태: 채택

## 맥락
- 목록에서 상세로 이동 필요 (R-02)
- SwiftUI 에 정립된 Coordinator 형태가 없음

## 결정
- `NavigationStack` 은 **App 이 소유**
- Feature 는 `ProductRoute` 와 `ProductCoordinating` 프로토콜만 공개
- Coordinator 는 path 만 관리하고 View 를 만들지 않음
- ViewModel 이 `ProductCoordinating` 을 `weak` 으로 보유

## 근거
- Feature 가 `NavigationStack` 을 가지면 "자신이 루트" 를 전제하게 되고,
  다른 화면에서 push 될 때 스택이 중첩되어 동작이 깨짐
- 호스트가 스택을 소유하면 같은 Feature 를 다른 스택 위에도 그대로 배치 가능
- Coordinator 가 상태만 가지므로 View 없이 path 검증으로 테스트 가능
- `weak` 보유로 ViewModel ↔ Coordinator 순환 참조를 끊음
- Feature 간 이동이 생기면 App 이 Route 를 감싸는 상위 타입을 정의.
  Feature 는 변경 없음

## 기각한 대안
- **Feature 가 스택 소유** — 중첩 push 에서 동작이 깨짐
- **Coordinator 에 View 팩토리** — 테스트에 SwiftUI 의존이 유입
- **화면이 path 를 직접 조작** — 이동 규칙이 View 에 흩어져 검증 지점이 사라짐

## 트레이드오프
- App 이 Feature 의 Route 어휘를 알아야 함. Composition Root 의 역할로 수용
