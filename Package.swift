// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "StackApp",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "StackApp",
            path: "Sources/StackApp",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
