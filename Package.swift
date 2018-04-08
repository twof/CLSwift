// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "CLSwift",
    dependencies: [],
    targets: [
        .target(name: "CLSwift", dependencies: []),
        .testTarget(name: "CLSwiftTests", dependencies: ["CLSwift"]),
        ]
)
