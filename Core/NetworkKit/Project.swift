import ProjectDescription
import ProjectDescriptionHelpers

// Core — 도메인을 모르는 인프라
let project = Project(
    name: "NetworkKit",
    options: Module.options,
    targets: [
        .library(name: "NetworkKit", path: "Sources"),
        .unitTests(name: "NetworkKitTests", path: "Tests/Sources",
                   dependencies: [.target(name: "NetworkKit")]),
    ]
)
