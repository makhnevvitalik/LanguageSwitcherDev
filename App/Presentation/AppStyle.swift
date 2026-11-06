// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit

@MainActor
enum AppStyle {
    enum Font {
        static let appName = NSFont.systemFont(ofSize: 16, weight: .semibold)
        static let appEdition = NSFont.systemFont(ofSize: 13, weight: .medium)
        static let windowTitle = NSFont.systemFont(ofSize: 20, weight: .semibold)
        static let sectionHeading = NSFont.systemFont(ofSize: 13, weight: .medium)
        static let fieldLabel = sectionHeading
        static let body = NSFont.systemFont(ofSize: 13)
        static let emphasizedBody = NSFont.systemFont(ofSize: 13, weight: .medium)
        static let secondary = NSFont.systemFont(ofSize: 12)
        // Choose text size by its place in the UI, independently of button styling.
        static let control = body
        static let status = secondary
        static let secondaryAction = secondary
        static let metadata = secondary
        static let compactControl = NSFont.systemFont(ofSize: 12, weight: .medium)
        static let monospacedBody = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        static let example = monospacedBody
        static let shortcut = NSFont.monospacedSystemFont(ofSize: 16, weight: .medium)
    }

    enum Layout {
        static let windowInset: CGFloat = 24
        static let windowTopInset: CGFloat = 20
    }

    enum AboutLayout {
        static let width: CGFloat = 400
        static let height: CGFloat = 216
        static let iconSize: CGFloat = 56
        static let headerSpacing: CGFloat = 14
        static let contentSpacing: CGFloat = 8
        static let actionSpacing: CGFloat = 12
        static let statusHeight: CGFloat = 16
        static let statusFooterSpacing: CGFloat = 6
        static let updateButtonWidth: CGFloat = 170
        static let bottomInset: CGFloat = 16
    }

    enum Color {
        static let activeControl = NSColor.controlAccentColor
        static let inactiveControl = NSColor.tertiaryLabelColor.withAlphaComponent(0.45)
    }
}
