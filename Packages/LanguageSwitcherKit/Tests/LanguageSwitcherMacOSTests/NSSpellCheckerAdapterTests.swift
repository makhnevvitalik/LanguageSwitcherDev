// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit
@testable import LanguageSwitcherMacOS
import XCTest

final class NSSpellCheckerAdapterTests: XCTestCase {
    func testRecognizesKnownEnglishWordWhenDictionaryIsAvailable() throws {
        guard NSSpellChecker.shared.availableLanguages.contains(where: {
            $0 == "en" || $0.hasPrefix("en_") || $0.hasPrefix("en-")
        }) else {
            throw XCTSkip("The system has no English spelling dictionary")
        }

        XCTAssertTrue(NSSpellCheckerAdapter().isCorrectlySpelled("hello", languageCode: "en"))
    }

    func testUnsupportedLanguageReturnsFalse() {
        XCTAssertFalse(
            NSSpellCheckerAdapter().isCorrectlySpelled(
                "word",
                languageCode: "unsupported_language"
            )
        )
    }
}
