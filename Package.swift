// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "RetryableTask",
    platforms: [
       .macOS("12.0"),
    ],
    products: [
        .library(name: "RetryableTask", targets: ["RetryableTask"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/neallester/swift-log-testing.git", from: "0.0.0")
    ],
    targets: [
        .target(name: "RetryableTask", dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "RetryableTaskTests", dependencies: [
            "RetryableTask",
            .product(name: "SwiftLogTesting", package: "swift-log-testing"),
        ]),
    ]
)
