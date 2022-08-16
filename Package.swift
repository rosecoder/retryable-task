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
    dependencies: [],
    targets: [
        .target(name: "RetryableTask"),
        .testTarget(name: "RetryableTaskTests", dependencies: ["RetryableTask"]),
    ]
)
