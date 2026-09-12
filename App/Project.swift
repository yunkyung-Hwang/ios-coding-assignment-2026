import ProjectDescription
import ProjectDescriptionHelpers

// Composition Root — 구현을 아는 유일한 곳
let project = Project(
    name: "App",
    options: Module.options,
    targets: [
        .app(name: "App", path: "Sources",
             infoPlist: "App/Resources/Info.plist",
             resources: ["Resources/Assets.xcassets"],
             dependencies: [.feature("ProductFeature"),
                            .feature("ProductFeature", target: "ProductFeatureInterface"),
                            .domain("FavoriteKit"),
                            .domain("FavoriteKit", target: "FavoriteKitInterface"),
                            .core("NetworkKit")]),   // APIClient 생성. baseURL 은 호스트가 안다
    ]
)
