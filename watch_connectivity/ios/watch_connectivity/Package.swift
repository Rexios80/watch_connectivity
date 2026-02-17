// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "watch_connectivity",
    platforms: [
      .iOS("9.3")
    ],
    products: [
        .library(name: "watch-connectivity", targets: ["watch_connectivity"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "watch_connectivity",
            dependencies: [],
            resources: [
                // TODO: If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
