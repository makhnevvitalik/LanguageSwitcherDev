// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import XCTest
@testable import LanguageSwitcherMacOS

final class UserDefaultsKeyboardSwitchingPreferencesTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "UserDefaultsKeyboardSwitchingPreferencesTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testUsesShortcutDefaultsAndKeys() {
        let preferences = UserDefaultsKeyboardSwitchingPreferences(userDefaults: defaults)

        XCTAssertEqual(preferences.enabledShortcuts, [])

        preferences.setEnabled(true, for: .command)

        XCTAssertTrue(defaults.bool(forKey: "keyboardShortcut.command.enabled"))
    }
}
