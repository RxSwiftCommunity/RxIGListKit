// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxIGListKit",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "RxIGListKit",
            targets: ["RxIGListKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/Instagram/IGListKit.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "RxIGListKit",
            dependencies: ["RxSwift", "IGListKit"],
            path: "./RxIGListKit"
        )
    ]
)
