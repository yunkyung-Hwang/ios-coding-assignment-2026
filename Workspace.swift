import ProjectDescription

// 모듈마다 Project 를 두고 워크스페이스가 수집한다.
// 스킴은 여러 프로젝트의 타겟을 묶으므로 워크스페이스 수준에 정의한다.
let workspace = Workspace(
    name: "Assignment",
    projects: [
        "App",
        "Features/ProductFeature",
        "Domain/FavoriteKit",
        "Core/CoreKit",
        "Core/NetworkKit",
        "Core/StorageKit",
    ],
    schemes: [
        // 앱 실행 + 전 모듈 유닛 테스트. CI 와 make test 가 사용
        .scheme(
            name: "App",
            shared: true,
            buildAction: .buildAction(targets: [.project(path: "App", target: "App")]),
            testAction: .targets([
                .testableTarget(target: .project(path: "Core/CoreKit", target: "CoreKitTests")),
                .testableTarget(target: .project(path: "Core/NetworkKit", target: "NetworkKitTests")),
                .testableTarget(target: .project(path: "Core/StorageKit", target: "StorageKitTests")),
                .testableTarget(target: .project(path: "Domain/FavoriteKit", target: "FavoriteKitTests")),
                .testableTarget(target: .project(path: "Features/ProductFeature", target: "ProductFeatureTests")),
            ]),
            runAction: .runAction(executable: .project(path: "App", target: "App"))
        ),
        // 모듈 단독 실행
        .scheme(
            name: "ProductFeatureDemo",
            shared: true,
            buildAction: .buildAction(targets: [.project(path: "Features/ProductFeature", target: "ProductFeatureDemo")]),
            runAction: .runAction(executable: .project(path: "Features/ProductFeature", target: "ProductFeatureDemo"))
        ),
    ]
)
