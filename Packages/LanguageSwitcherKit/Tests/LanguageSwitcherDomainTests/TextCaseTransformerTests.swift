// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherDomain
import XCTest

final class TextCaseTransformerTests: XCTestCase {
    private let locale = Locale(identifier: "ru_RU")

    func testUppercaseAndLowercasePreserveNonLetters() {
        XCTAssertEqual(
            TextCaseTransformer.transform("Hello, мир! 42", action: .uppercase, locale: locale),
            "HELLO, МИР! 42"
        )
        XCTAssertEqual(
            TextCaseTransformer.transform("Hello, МИР! 42", action: .lowercase, locale: locale),
            "hello, мир! 42"
        )
    }

    func testCapitalizeWordsLowersRemainingLetters() {
        XCTAssertEqual(
            TextCaseTransformer.transform("hELLO мИР\nnew СТРОКА", action: .capitalizeWords, locale: locale),
            "Hello Мир\nNew Строка"
        )
    }

    func testInvertCaseHandlesLatinCyrillicAndExtendedGraphemes() {
        XCTAssertEqual(
            TextCaseTransformer.transform("AbЯя éÉ 👨‍👩‍👧", action: .invertCase, locale: locale),
            "aBяЯ Éé 👨‍👩‍👧"
        )
    }

    func testLocaleAffectsCaseMapping() {
        let turkish = Locale(identifier: "tr_TR")

        XCTAssertEqual(
            TextCaseTransformer.transform("iı", action: .uppercase, locale: turkish),
            "İI"
        )
        XCTAssertEqual(
            TextCaseTransformer.transform("Iİ", action: .lowercase, locale: turkish),
            "ıi"
        )
    }

}
