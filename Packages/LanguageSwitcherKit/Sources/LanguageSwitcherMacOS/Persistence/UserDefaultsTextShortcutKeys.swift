// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherDomain

enum UserDefaultsTextShortcutKeys {
    static let maximumMultiPressInterval = "textShortcut.maximumMultiPressInterval"

    static func shortcut(for action: TextAction) -> String {
        "textActionShortcut.\(action.identifier)"
    }
}
