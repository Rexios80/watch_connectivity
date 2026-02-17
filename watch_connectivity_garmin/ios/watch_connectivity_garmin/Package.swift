// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "watch_connectivity_garmin",
    platforms: [
      .iOS("13.0")
    ],
    products: [
        .library(name: "watch-connectivity-garmin", targets: ["watch_connectivity_garmin"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "ConnectIQ",
            path: "ConnectIQ.xcframework"
        ),
        .target(
            name: "watch_connectivity_garmin",
            dependencies: [
                .target(name: "ConnectIQ")
            ],
            resources: [
                // TODO: If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
