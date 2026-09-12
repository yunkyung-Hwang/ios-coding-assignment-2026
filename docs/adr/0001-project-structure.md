# ADR-0001: 프로젝트 구성

상태: 채택

## 맥락
- 초기 프로젝트 직접 구성
- clone 후 추가 작업 없이 빌드·실행 가능해야 함
- 다수 모듈 구성 예정

## 결정
- Tuist 로 생성, 생성물(.xcodeproj/.xcworkspace) 커밋
- 전 모듈 `.staticFramework`, 앱만 `.app`
- iOS Deployment Target 17.0

## 근거
- 모듈 다수 시 project.pbxproj 수작업 관리는 충돌·누락 발생
- 생성물 커밋 → Tuist 미설치 환경에서도 clone 후 즉시 빌드
- 라이브러리 타겟에 `GENERATE_INFOPLIST_FILE=YES` 지정 → 빌드 시점 자동 생성으로 `Derived/` 미생성
  - Tuist 기본값(`infoPlist: .default`)은 `Derived/InfoPlists/*.plist` 를 만들고 프로젝트가 이를 참조
  - 해당 경로를 gitignore 하면 빌드 입력 누락으로 실패
- iOS 17.0 은 Observation 최소 버전

## 기각한 대안
- **SPM 단독** — 리소스 처리·빌드 설정 제어가 제한적이고 앱 타겟 구성 불가
- **순정 .xcodeproj** — 다수 모듈에서 프로젝트 파일 수작업 관리 부담, 설정 누락이 드러나지 않음
- **dynamic framework** — 실행 시 모듈 수만큼 dyld 로딩 비용. App Extension·위젯이 없어 공유 이점 없음
- **mergeable libraries** — 개발 중 증분 빌드 이점이 있으나 모듈 규모가 작아 체감 이득 없음
- **Derived/ 함께 커밋** — 생성물을 두 종류 커밋하게 되고 diff 노이즈 증가

## 트레이드오프
- 생성물 커밋으로 diff 에 프로젝트 파일 변경 혼입
