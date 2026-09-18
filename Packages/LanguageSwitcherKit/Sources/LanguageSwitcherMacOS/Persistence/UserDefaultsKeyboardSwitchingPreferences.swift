// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation

public final class UserDefaultsKeyboardSwitchingPreferences {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var enabledShortcuts: [ModifierShortcut] {
        ModifierShortcut.allCases.filter(isEnabled)
    }

    public func isEnabled(_ shortcut: ModifierShortcut) -> Bool {
        guard userDefaults.object(forKey: shortcut.userDefaultsKey) != nil else {
            return false
        }
        return userDefaults.bool(forKey: shortcut.userDefaultsKey)
    }

    public func setEnabled(_ isEnabled: Bool, for shortcut: ModifierShortcut) {
        userDefaults.set(isEnabled, forKey: shortcut.userDefaultsKey)
    }
}
