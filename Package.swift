// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HAMT",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .library(name: "HAMT", targets: ["HAMT"]),
        .executable(name: "HAMTFuzz", targets: ["HAMTFuzz"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "HAMT", dependencies: [], path: "HAMT"),
        .testTarget(name: "HAMTTests", dependencies: ["HAMT"], path: "HAMTTests"),
        .testTarget(name: "PD5UnitTests", dependencies: ["HAMT"], path: "PD5UnitTests"),
        .target(name: "HAMTFuzz", dependencies: ["HAMT"], path: "HAMTFuzz"),
    ]
)

