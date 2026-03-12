// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeaturamaTester",
    platforms: [.iOS(.v17), .macOS(.v14)],
    dependencies: [
        .package(path: "../../../sdks/swift/FeaturamaSdk"),
    ],
    targets: [
        .executableTarget(
            name: "FeaturamaTester",
            dependencies: [
                .product(name: "FeaturamaSdk", package: "FeaturamaSdk"),
            ],
            path: "Sources"
        ),
    ]
)
