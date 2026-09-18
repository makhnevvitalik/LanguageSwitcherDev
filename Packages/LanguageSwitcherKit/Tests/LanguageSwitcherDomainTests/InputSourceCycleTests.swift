// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import XCTest
@testable import LanguageSwitcherDomain

final class InputSourceCycleTests: XCTestCase {
    private let english = InputSource(
        id: "com.apple.keylayout.ABC",
        displayName: "ABC",
        localeIdentifier: "en_US",
        supportsTextConversion: true
    )
    private let russian = InputSource(
        id: "com.apple.keylayout.Russian",
        displayName: "Russian",
        localeIdentifier: "ru_RU",
        supportsTextConversion: true
    )
    private let german = InputSource(
        id: "com.apple.keylayout.German",
        displayName: "German",
        localeIdentifier: "de_DE",
        supportsTextConversion: true
    )

    func testReturnsNextInputSourceInProvidedOrder() {
        let result = InputSourceCycle.next(after: english.id, in: [english, russian, german])

        XCTAssertEqual(result, russian)
    }

    func testWrapsAfterLastInputSource() {
        let result = InputSourceCycle.next(after: german.id, in: [english, russian, german])

        XCTAssertEqual(result, english)
    }

    func testStartsWithFirstWhenCurrentSourceIsOutsideSelection() {
        let result = InputSourceCycle.next(after: "missing", in: [english, russian])

        XCTAssertEqual(result, english)
    }

    func testRequiresAtLeastTwoSelectedInputSources() {
        XCTAssertNil(InputSourceCycle.next(after: english.id, in: [english]))
        XCTAssertNil(InputSourceCycle.next(after: nil, in: []))
    }
}
