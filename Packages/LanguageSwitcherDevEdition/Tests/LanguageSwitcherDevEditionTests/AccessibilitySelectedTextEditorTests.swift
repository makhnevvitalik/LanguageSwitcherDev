// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherApplication
import LanguageSwitcherMacOS
@testable import LanguageSwitcherDevEdition
import XCTest

final class AccessibilitySelectedTextEditorTests: XCTestCase {
    func testDevIdentityUsesSeparateProductAndRepository() {
        XCTAssertEqual(DevEdition.identity.brandName, "Language Switcher")
        XCTAssertEqual(DevEdition.identity.editionName, "Developer Edition")
        XCTAssertEqual(DevEdition.identity.productName, "Language Switcher Dev")
        XCTAssertEqual(
            DevEdition.identity.bundleIdentifier,
            "com.makhnevvitalik.LanguageSwitcherDev"
        )
        XCTAssertEqual(
            DevEdition.identity.repositoryURL.absoluteString,
            "https://github.com/makhnevvitalik/LanguageSwitcherDev"
        )
        XCTAssertEqual(
            DevEdition.identity.latestReleaseURL.absoluteString,
            "https://github.com/makhnevvitalik/LanguageSwitcherDev/releases/latest"
        )
        XCTAssertEqual(
            DevEdition.identity.latestReleaseAPIURL.absoluteString,
            "https://api.github.com/repos/makhnevvitalik/LanguageSwitcherDev/releases/latest"
        )
    }

    func testReadsAccessibleSelectionAndTypesTransformation() {
        let access = FakeAXAccess(readResult: .selection("hello"))
        let eventReplacer = FakeEventReplacer()
        let editor = AccessibilitySelectedTextEditor(
            access: access,
            eventReplacer: eventReplacer
        )
        var result: TextReplacementResult?

        XCTAssertTrue(editor.replaceSelectedText(
            transform: { TextTransformation(text: $0.uppercased()) },
            completion: { result = $0 }
        ))

        XCTAssertEqual(eventReplacer.replacements, ["HELLO"])
        XCTAssertEqual(result, .replaced(TextTransformation(text: "HELLO")))
        XCTAssertFalse(editor.isBusy)
    }

    func testUnsupportedAccessibilityDoesNotTypeText() {
        let eventReplacer = FakeEventReplacer()
        let editor = AccessibilitySelectedTextEditor(
            access: FakeAXAccess(readResult: .unsupported),
            eventReplacer: eventReplacer
        )
        var result: TextReplacementResult?

        XCTAssertTrue(editor.replaceSelectedText(
            transform: { TextTransformation(text: $0.uppercased()) },
            completion: { result = $0 }
        ))

        XCTAssertEqual(result, .failed)
        XCTAssertTrue(eventReplacer.replacements.isEmpty)
    }

    func testEmptyAccessibilitySelectionDoesNotTypeText() {
        let eventReplacer = FakeEventReplacer()
        let editor = AccessibilitySelectedTextEditor(
            access: FakeAXAccess(readResult: .noText),
            eventReplacer: eventReplacer
        )
        var result: TextReplacementResult?

        XCTAssertTrue(editor.replaceSelectedText(
            transform: { TextTransformation(text: $0.uppercased()) },
            completion: { result = $0 }
        ))

        XCTAssertEqual(result, .noText)
        XCTAssertTrue(eventReplacer.replacements.isEmpty)
    }

    func testUnchangedTransformationDoesNotTypeText() {
        let eventReplacer = FakeEventReplacer()
        let editor = AccessibilitySelectedTextEditor(
            access: FakeAXAccess(readResult: .selection("hello")),
            eventReplacer: eventReplacer
        )
        var result: TextReplacementResult?

        XCTAssertTrue(editor.replaceSelectedText(
            transform: { _ in nil },
            completion: { result = $0 }
        ))

        XCTAssertEqual(result, .unchanged)
        XCTAssertTrue(eventReplacer.replacements.isEmpty)
    }

    func testFailedEventTypingReportsFailure() {
        let eventReplacer = FakeEventReplacer(completionResult: false)
        let editor = AccessibilitySelectedTextEditor(
            access: FakeAXAccess(readResult: .selection("hello")),
            eventReplacer: eventReplacer
        )
        var result: TextReplacementResult?

        XCTAssertTrue(editor.replaceSelectedText(
            transform: { TextTransformation(text: $0.uppercased()) },
            completion: { result = $0 }
        ))

        XCTAssertEqual(eventReplacer.replacements, ["HELLO"])
        XCTAssertEqual(result, .failed)
    }

    func testRejectsSecondOperationWhileEventTypingIsActive() {
        let eventReplacer = FakeEventReplacer(completesImmediately: false)
        let editor = AccessibilitySelectedTextEditor(
            access: FakeAXAccess(readResult: .selection("hello")),
            eventReplacer: eventReplacer
        )

        XCTAssertTrue(editor.replaceSelectedText(
            transform: { TextTransformation(text: $0.uppercased()) },
            completion: { _ in }
        ))
        XCTAssertFalse(editor.replaceSelectedText(
            transform: { TextTransformation(text: $0) },
            completion: { _ in }
        ))
    }
}

private final class FakeAXAccess: AXSelectedTextReading {
    let readResult: AXSelectedTextReadResult

    init(readResult: AXSelectedTextReadResult) {
        self.readResult = readResult
    }

    func readSelection() -> AXSelectedTextReadResult {
        readResult
    }
}

private final class FakeEventReplacer: SelectedTextEventReplacing {
    private let completionResult: Bool
    private let completesImmediately: Bool

    private(set) var isBusy = false
    private(set) var replacements: [String] = []

    init(completionResult: Bool = true, completesImmediately: Bool = true) {
        self.completionResult = completionResult
        self.completesImmediately = completesImmediately
    }

    func replaceSelection(
        with text: String,
        completion: @escaping (Bool) -> Void
    ) -> Bool {
        guard !isBusy else { return false }
        isBusy = true
        replacements.append(text)
        guard completesImmediately else { return true }
        isBusy = false
        completion(completionResult)
        return true
    }
}
