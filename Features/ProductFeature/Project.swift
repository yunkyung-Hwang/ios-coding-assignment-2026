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
        .unitTests(name: "ProductFeatureTests", path: "Tests/Sources",
                   dependencies: [.target(name: "ProductFeature"),
                                  .target(name: "ProductFeatureInterface"),
                                  .core("NetworkKit")]),
    ]
)
