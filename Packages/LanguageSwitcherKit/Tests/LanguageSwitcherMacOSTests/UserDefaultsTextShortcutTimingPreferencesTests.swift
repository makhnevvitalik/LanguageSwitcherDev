// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
@testable import LanguageSwitcherMacOS
import XCTest

final class UserDefaultsTextShortcutTimingPreferencesTests: XCTestCase {
    func testDefaultsToPointFourSecondsAndPersistsSelectedInterval() {
        let suiteName = "UserDefaultsTextShortcutTimingPreferencesTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let preferences = UserDefaultsTextShortcutTimingPreferences(userDefaults: defaults)

        XCTAssertEqual(preferences.maximumMultiPressInterval, 0.3)

        preferences.maximumMultiPressInterval = 0.7

        XCTAssertEqual(
            UserDefaultsTextShortcutTimingPreferences(userDefaults: defaults)
                .maximumMultiPressInterval,
            0.7
        )
    }
}
