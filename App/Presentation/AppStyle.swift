// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit

@MainActor
enum AppStyle {
    enum Font {
        static let menuBrand = NSFont.systemFont(ofSize: 16, weight: .semibold)
        static let menuEdition = NSFont.systemFont(ofSize: 10, weight: .medium)
        static let aboutTitle = NSFont.systemFont(ofSize: 23, weight: .semibold)
        static let windowTitle = NSFont.systemFont(ofSize: 20, weight: .semibold)
        static let dialogHeading = NSFont.systemFont(ofSize: 14, weight: .semibold)
        static let sectionHeading = NSFont.systemFont(ofSize: 12, weight: .medium)
        static let fieldLabel = NSFont.systemFont(ofSize: 12, weight: .medium)
        static let body = NSFont.systemFont(ofSize: 13)
        static let emphasizedBody = NSFont.systemFont(ofSize: 13, weight: .medium)
        static let control = NSFont.systemFont(ofSize: 12)
        static let status = NSFont.systemFont(ofSize: 12)
        static let caption = NSFont.systemFont(ofSize: 11)
        static let emphasizedCaption = NSFont.systemFont(ofSize: 11, weight: .medium)
        static let detail = NSFont.systemFont(ofSize: 10)
        static let example = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        static let shortcut = NSFont.monospacedSystemFont(ofSize: 16, weight: .medium)
    }

    enum Color {
        static let activeControl = NSColor.controlAccentColor
        static let inactiveControl = NSColor.tertiaryLabelColor.withAlphaComponent(0.45)
        static let disabledControl = NSColor.quaternaryLabelColor
    }
}
