// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherDomain
import LanguageSwitcherMacOS
import XCTest

final class UserDefaultsTextConversionScopeStoreTests: XCTestCase {
    func testDefaultsToTypedText() {
        let defaults = makeDefaults()

        XCTAssertEqual(
            UserDefaultsTextConversionScopeStore(userDefaults: defaults).scope,
            .typedText
        )
    }

    func testPersistsSelectedScope() {
        let defaults = makeDefaults()
        let store = UserDefaultsTextConversionScopeStore(userDefaults: defaults)

        store.scope = .lastWord

        XCTAssertEqual(
            UserDefaultsTextConversionScopeStore(userDefaults: defaults).scope,
            .lastWord
        )
    }

    func testFallsBackToDefaultForUnknownStoredValue() {
        let defaults = makeDefaults()
        defaults.set("unknown", forKey: "textTools.conversionScope")

        XCTAssertEqual(
            UserDefaultsTextConversionScopeStore(userDefaults: defaults).scope,
            .typedText
        )
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "UserDefaultsTextConversionScopeStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
