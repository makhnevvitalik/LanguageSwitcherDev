// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Carbon
@testable import LanguageSwitcherMacOS
import XCTest

final class KeyboardLayoutKeyGroupTests: XCTestCase {
    func testRecognizesKeypadKeys() {
        XCTAssertTrue(KeyboardLayoutKeyGroup.isKeypad(65))
        XCTAssertTrue(KeyboardLayoutKeyGroup.isKeypad(75))
        XCTAssertTrue(KeyboardLayoutKeyGroup.isKeypad(82))
        XCTAssertTrue(KeyboardLayoutKeyGroup.isKeypad(92))
    }

    func testKeepsMainPunctuationInMainGroup() {
        XCTAssertFalse(KeyboardLayoutKeyGroup.isKeypad(43))
        XCTAssertFalse(KeyboardLayoutKeyGroup.isKeypad(44))
        XCTAssertFalse(KeyboardLayoutKeyGroup.isKeypad(47))
    }

    func testConversionModifierStatesExcludeCapsLock() {
        XCTAssertEqual(
            TISKeyboardLayoutProvider.conversionModifierStates,
            [0, UInt32(shiftKey)]
        )
        XCTAssertFalse(
            TISKeyboardLayoutProvider.conversionModifierStates.contains(UInt32(alphaLock))
        )
    }

    func testConversionModifierStatesExcludeOptionCombinations() {
        XCTAssertEqual(
            TISKeyboardLayoutProvider.conversionModifierStates,
            [0, UInt32(shiftKey)]
        )
        XCTAssertFalse(
            TISKeyboardLayoutProvider.conversionModifierStates.contains(UInt32(optionKey))
        )
        XCTAssertFalse(
            TISKeyboardLayoutProvider.conversionModifierStates.contains(
                UInt32(shiftKey | optionKey)
            )
        )
    }
}
