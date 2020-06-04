// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "LGNConfig",
    products: [
        .library(name: "LGNConfig", targets: ["LGNConfig"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LGNConfig",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(name: "LGNConfigTests", dependencies: ["LGNConfig"]),
    ]
)
