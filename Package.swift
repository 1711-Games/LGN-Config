// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "lgn-config",
    products: [
        .library(name: "LGNConfig", targets: ["LGNConfig"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "LGNConfig", dependencies: []),
        .testTarget(name: "LGNConfigTests", dependencies: ["LGNConfig"]),
    ]
)
