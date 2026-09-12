import ProjectDescription
import ProjectDescriptionHelpers

// Core — 도메인을 모르는 인프라
let project = Project(
    name: "CoreKit",
    options: Module.options,
    targets: [
        .library(name: "CoreKit", path: "Sources"),
        .unitTests(name: "CoreKitTests", path: "Tests/Sources",
                   dependencies: [.target(name: "CoreKit")]),
    ]
)
