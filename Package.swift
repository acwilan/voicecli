// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "voicecli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "voicecli", targets: ["voicecli"])
    ],
    targets: [
        .executableTarget(
            name: "voicecli"
        ),
    ]
)
