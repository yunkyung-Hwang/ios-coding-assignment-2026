import ProjectDescription
import ProjectDescriptionHelpers

// Features — 화면을 가진 모듈. 다른 Feature·Domain 은 Interface 만 거친다
let project = Project(
    name: "ProductFeature",
    options: Module.options,
    targets: [
        .library(name: "ProductFeatureInterface", path: "Interface/Sources",
                 dependencies: [.core("CoreKit")]),
        .library(name: "ProductFeature", path: "Sources",
                 dependencies: [.target(name: "ProductFeatureInterface"),
                                .domain("FavoriteKit", target: "FavoriteKitInterface"),  // 구현이 아닌 계약에만 의존
                                .core("NetworkKit"),
                                .core("CoreKit")]),
        .library(name: "ProductFeatureTesting", path: "Testing/Sources",
                 dependencies: [.target(name: "ProductFeatureInterface")]),
        .unitTests(name: "ProductFeatureTests", path: "Tests/Sources",
                   dependencies: [.target(name: "ProductFeature"),
                                  .target(name: "ProductFeatureInterface"),
                                  .target(name: "ProductFeatureTesting"),
                                  .core("NetworkKit"),
                                  .domain("FavoriteKit", target: "FavoriteKitTesting")]),
        .app(name: "ProductFeatureDemo", path: "Demo/Sources",
             infoPlist: "App/Resources/DemoInfo.plist",
             dependencies: [.target(name: "ProductFeature"),
                            .target(name: "ProductFeatureTesting"),
                            .domain("FavoriteKit", target: "FavoriteKitTesting")]),
    ]
)
