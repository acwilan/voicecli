// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "voicecli",
    platforms: [.macOS(.v13)],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "voicecli",
            dependencies: [],
            swiftSettings: [.unsafeFlags(["-parse-as-library"])]
        ),
    ]
)
