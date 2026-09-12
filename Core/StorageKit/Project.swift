import ProjectDescription
import ProjectDescriptionHelpers

// Core — 도메인을 모르는 인프라
let project = Project(
    name: "StorageKit",
    options: Module.options,
    targets: [
        .library(name: "StorageKit", path: "Sources"),
        .unitTests(name: "StorageKitTests", path: "Tests/Sources",
                   dependencies: [.target(name: "StorageKit")]),
    ]
)
