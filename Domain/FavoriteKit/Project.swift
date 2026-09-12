import ProjectDescription
import ProjectDescriptionHelpers

// Domain — 화면 없이 도메인을 소유. Product 를 모르고 Set<String> 만 다룬다
let project = Project(
    name: "FavoriteKit",
    options: Module.options,
    targets: [
        .library(name: "FavoriteKitInterface", path: "Interface/Sources"),
        .library(name: "FavoriteKit", path: "Sources",
                 dependencies: [.target(name: "FavoriteKitInterface"),
                                .core("StorageKit")]),
        .library(name: "FavoriteKitTesting", path: "Testing/Sources",
                 dependencies: [.target(name: "FavoriteKitInterface")]),
        .unitTests(name: "FavoriteKitTests", path: "Tests/Sources",
                   dependencies: [.target(name: "FavoriteKit"),
                                  .target(name: "FavoriteKitInterface"),
                                  .target(name: "FavoriteKitTesting")]),
    ]
)
