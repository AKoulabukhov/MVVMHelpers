// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MVVMHelpers",
    products: [
        .library(
            name: "MVVMHelpers",
            targets: ["MVVMHelpers"]),
    ],
    targets: [
        .target(
            name: "MVVMHelpers",
            dependencies: []),
        .testTarget(
            name: "MVVMHelpersTests",
            dependencies: ["MVVMHelpers"]),
    ]
)
