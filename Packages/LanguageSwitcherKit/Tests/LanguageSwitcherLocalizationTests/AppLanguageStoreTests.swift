// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import XCTest
@testable import LanguageSwitcherLocalization

final class AppLanguageStoreTests: XCTestCase {
    func testFirstLaunchUsesRussianSystemLanguageAndPersistsIt() {
        let defaults = makeDefaults()

        let store = AppLanguageStore(
            userDefaults: defaults,
            preferredLanguages: { ["ru-RU", "en-US"] }
        )

        XCTAssertEqual(store.selectedLanguage, .russian)
        XCTAssertEqual(defaults.string(forKey: AppLanguageStore.userDefaultsKey), "ru")
    }

    func testFirstLaunchFallsBackToEnglishForUnsupportedSystemLanguage() {
        let defaults = makeDefaults()

        let store = AppLanguageStore(
            userDefaults: defaults,
            preferredLanguages: { ["de-DE"] }
        )

        XCTAssertEqual(store.selectedLanguage, .english)
        XCTAssertEqual(defaults.string(forKey: AppLanguageStore.userDefaultsKey), "en")
    }

    func testPersistedChoiceOverridesCurrentSystemLanguage() {
        let defaults = makeDefaults()
        defaults.set("en", forKey: AppLanguageStore.userDefaultsKey)

        let store = AppLanguageStore(
            userDefaults: defaults,
            preferredLanguages: { ["ru-RU"] }
        )

        XCTAssertEqual(store.selectedLanguage, .english)
    }

    func testSelectingLanguagePersistsIt() {
        let defaults = makeDefaults()
        let store = AppLanguageStore(
            userDefaults: defaults,
            preferredLanguages: { ["en-US"] }
        )

        store.select(.russian)

        XCTAssertEqual(store.selectedLanguage, .russian)
        XCTAssertEqual(defaults.string(forKey: AppLanguageStore.userDefaultsKey), "ru")
    }

    func testInvalidPersistedLanguageIsReplacedUsingSystemLanguage() {
        let defaults = makeDefaults()
        defaults.set("unsupported", forKey: AppLanguageStore.userDefaultsKey)

        let store = AppLanguageStore(
            userDefaults: defaults,
            preferredLanguages: { ["ru"] }
        )

        XCTAssertEqual(store.selectedLanguage, .russian)
        XCTAssertEqual(defaults.string(forKey: AppLanguageStore.userDefaultsKey), "ru")
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "AppLanguageStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        addTeardownBlock {
            defaults.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }
}
