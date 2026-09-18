// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import XCTest
@testable import LanguageSwitcherMacOS

final class UserDefaultsModifierTapPreferencesTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "UserDefaultsModifierTapPreferencesTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testStoresSupportedKeyboardSwitchingDuration() {
        let preferences = UserDefaultsModifierTapPreferences(userDefaults: defaults)

        XCTAssertEqual(preferences.maximumDuration, 0.2)

        preferences.maximumDuration = 0.7

        XCTAssertEqual(preferences.maximumDuration, 0.7)
        XCTAssertEqual(defaults.double(forKey: "keyboardSwitching.maximumTapDuration"), 0.7)
    }

    func testRejectsUnsupportedDuration() {
        let preferences = UserDefaultsModifierTapPreferences(userDefaults: defaults)

        preferences.maximumDuration = 0.25

        XCTAssertEqual(preferences.maximumDuration, 0.2)
    }
}
