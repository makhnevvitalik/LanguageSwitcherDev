// swift-tools-version: 5.9
// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import PackageDescription

let package = Package(
    name: "LanguageSwitcherDevEdition",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LanguageSwitcherDevEdition",
            targets: ["LanguageSwitcherDevEdition"]
        )
    ],
    dependencies: [
        .package(path: "../LanguageSwitcherKit")
    ],
    targets: [
        .target(
            name: "LanguageSwitcherDevEdition",
            dependencies: [
                .product(name: "LanguageSwitcherEdition", package: "LanguageSwitcherKit"),
                .product(name: "LanguageSwitcherApplication", package: "LanguageSwitcherKit"),
                .product(name: "LanguageSwitcherMacOS", package: "LanguageSwitcherKit")
            ],
            linkerSettings: [
                .linkedFramework("ApplicationServices")
            ]
        ),
        .testTarget(
            name: "LanguageSwitcherDevEditionTests",
            dependencies: [
                "LanguageSwitcherDevEdition",
                .product(name: "LanguageSwitcherApplication", package: "LanguageSwitcherKit"),
                .product(name: "LanguageSwitcherMacOS", package: "LanguageSwitcherKit")
            ]
        )
    ]
)
