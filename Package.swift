// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FeaturamaSdk",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "FeaturamaSdk",
            targets: ["FeaturamaSdk"]
        ),
    ],
    targets: [
        .target(
            name: "FeaturamaSdk"
        ),
        .testTarget(
            name: "FeaturamaSdkTests",
            dependencies: ["FeaturamaSdk"]
        ),
    ]
)
