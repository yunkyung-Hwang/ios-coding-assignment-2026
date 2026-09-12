import ProjectDescription

public enum Module {
    public static let organization = "com.yunkyung.assignment"
    public static let deploymentTarget: DeploymentTargets = .iOS("17.0")

    /// 리소스 접근자 자동 생성 비활성.
    /// 활성 시 Derived/Sources/ 에 코드가 생성되고 프로젝트가 이를 참조 →
    /// 해당 경로를 gitignore 하면 clone 후 빌드 실패
    public static let options: Project.Options = .options(
        automaticSchemesOptions: .disabled,   // 스킴은 Workspace 에 명시 정의
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    )

    /// 라이브러리 타겟 공통 설정
    /// GENERATE_INFOPLIST_FILE — Info.plist 를 빌드 시점 생성. Derived/ 미생성 목적
    static let librarySettings: SettingsDictionary = [
        "SWIFT_VERSION": "6.0",
        "GENERATE_INFOPLIST_FILE": "YES",
    ]

    static let appSettings: SettingsDictionary = [
        "SWIFT_VERSION": "6.0",
    ]
}

public extension Target {
    static func library(
        name: String,
        path: String,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "\(Module.organization).\(name.lowercased())",
            deploymentTargets: Module.deploymentTarget,
            infoPlist: nil,
            sources: ["\(path)/**"],
            dependencies: dependencies,
            settings: .settings(base: Module.librarySettings)
        )
    }

    static func unitTests(
        name: String,
        path: String,
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(Module.organization).\(name.lowercased())",
            deploymentTargets: Module.deploymentTarget,
            infoPlist: nil,
            sources: ["\(path)/**"],
            dependencies: dependencies,
            settings: .settings(base: Module.librarySettings)
        )
    }

    static func app(
        name: String,
        path: String,
        infoPlist: String,
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: "\(Module.organization)\(name == "App" ? "" : ".\(name.lowercased())")",
            deploymentTargets: Module.deploymentTarget,
            infoPlist: .file(path: .relativeToRoot(infoPlist)),
            sources: ["\(path)/**"],
            resources: resources,
            dependencies: dependencies,
            settings: .settings(base: Module.appSettings)
        )
    }
}


// 계층 규칙
//   Features → Domain → Core   (역방향 의존 금지)
//   Feature 간 참조는 Interface 모듈만 거친다
//   테스트 타겟도 import 하는 모듈을 직접 선언한다
public extension TargetDependency {
    static func core(_ name: String) -> TargetDependency {
        .project(target: name, path: .relativeToRoot("Core/\(name)"))
    }

    static func domain(_ module: String, target: String? = nil) -> TargetDependency {
        .project(target: target ?? module, path: .relativeToRoot("Domain/\(module)"))
    }

    static func feature(_ module: String, target: String? = nil) -> TargetDependency {
        .project(target: target ?? module, path: .relativeToRoot("Features/\(module)"))
    }
}
