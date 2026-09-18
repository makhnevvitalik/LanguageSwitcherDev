// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import XCTest
@testable import LanguageSwitcherMacOS

final class UserDefaultsInputSourceSelectionStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "UserDefaultsInputSourceSelectionStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testDefaultsToNoExcludedInputSources() {
        let store = UserDefaultsInputSourceSelectionStore(userDefaults: defaults)

        XCTAssertEqual(store.excludedInputSourceIDs, [])
    }

    func testPersistsExcludedInputSourceIDsAcrossInstances() {
        let firstStore = UserDefaultsInputSourceSelectionStore(userDefaults: defaults)
        firstStore.excludedInputSourceIDs = ["english", "german"]

        let secondStore = UserDefaultsInputSourceSelectionStore(userDefaults: defaults)

        XCTAssertEqual(secondStore.excludedInputSourceIDs, ["english", "german"])
    }
}
