// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "krest",
    products: [
        // .library(
        //     name: "Krest6",
        //     targets: ["Krest6"]
        // ),
        .library(
            name: "KrestCoreAddons",
            type: .dynamic,
            targets: ["KCoreAddons"]
        ),
    ],
    targets: [
        .target(
            name: "Krest"
        ),
        .target(
            name: "KCoreAddons",
            dependencies: ["Qt"],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
                .unsafeFlags([
                    "-I../blusher/.build/debug/Modules",
                    "-L../blusher/.build/debug",
                    "-lBlusher",
                ]),
                .interoperabilityMode(.Cxx),
            ]
        ),
        .systemLibrary(
            name: "Qt",
            pkgConfig: "Qt6Core"
        ),
        .testTarget(
            name: "KrestTests",
            dependencies: ["Krest", "Qt", "KCoreAddons"],
            swiftSettings: [
                .unsafeFlags([
                    "-I../blusher/.build/debug/Modules",
                    "-L../blusher/.build/debug",
                    "-lBlusher",
                ]),
                .interoperabilityMode(.Cxx)
            ]
        ),
    ]
)
