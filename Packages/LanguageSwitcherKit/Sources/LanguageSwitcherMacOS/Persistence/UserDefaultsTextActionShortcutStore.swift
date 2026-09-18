// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherApplication
import LanguageSwitcherDomain

public final class UserDefaultsTextActionShortcutStore: TextActionShortcutStore {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func shortcut(for action: TextAction) -> TextActionShortcut? {
        guard let data = userDefaults.data(forKey: key(for: action)) else {
            return nil
        }
        return try? decoder.decode(TextActionShortcut.self, from: data)
    }

    public func setShortcut(_ shortcut: TextActionShortcut?, for action: TextAction) {
        guard let shortcut else {
            userDefaults.removeObject(forKey: key(for: action))
            return
        }
        guard let data = try? encoder.encode(shortcut) else {
            return
        }
        userDefaults.set(data, forKey: key(for: action))
    }

    private func key(for action: TextAction) -> String {
        UserDefaultsTextShortcutKeys.shortcut(for: action)
    }
}
