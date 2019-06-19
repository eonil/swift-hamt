// swift-tools-version:4.0

//
//  Package.swift
//  HAMT
//
//  Created by Henry on 2019/06/20.
//

import Foundation
import PackageDescription

let package = Package(
    name: "HAMT",
    products: [
        .library(name: "HAMT", targets: ["HAMT"]),
    ],
//    dependencies: [
//        .package(url: "https://github.com/apple/example-package-fisheryates.git", from: "2.0.0"),
//        .package(url: "https://github.com/apple/example-package-playingcard.git", from: "3.0.0"),
//    ],
    targets: [
        .target(
            name: "HAMT",
            dependencies: [],
            path: "HAMT"),
        .testTarget(
            name: "PD5UnitTests",
            dependencies: ["HAMT"],
            path: "PD5UnitTests"),
    ]
)
