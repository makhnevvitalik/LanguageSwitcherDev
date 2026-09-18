// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain
import XCTest

final class TrackedTextScopeResolverTests: XCTestCase {
    func testTypedTextUsesWholeBuffer() {
        XCTAssertEqual(
            TrackedTextScopeResolver.resolve(text: "hello ghbdtn", scope: .typedText),
            TrackedTextReplacementSlice(
                untouchedPrefix: "",
                textToTransform: "hello ghbdtn",
                trailingText: ""
            )
        )
    }

    func testLastWordIncludesPunctuationAndPreservesTrailingWhitespace() {
        XCTAssertEqual(
            TrackedTextScopeResolver.resolve(text: "hello ghbdtn./  ", scope: .lastWord),
            TrackedTextReplacementSlice(
                untouchedPrefix: "hello ",
                textToTransform: "ghbdtn./",
                trailingText: "  "
            )
        )
    }

    func testLastWordUsesTabAsBoundary() {
        XCTAssertEqual(
            TrackedTextScopeResolver.resolve(text: "first\tsecond", scope: .lastWord),
            TrackedTextReplacementSlice(
                untouchedPrefix: "first\t",
                textToTransform: "second",
                trailingText: ""
            )
        )
    }

    func testLastWordRejectsWhitespaceOnlyBuffer() {
        XCTAssertNil(TrackedTextScopeResolver.resolve(text: " \t ", scope: .lastWord))
    }

    func testSelectionOnlyNeverUsesTrackedText() {
        XCTAssertNil(TrackedTextScopeResolver.resolve(text: "text", scope: .selectionOnly))
    }

    func testReplacementSliceCountsExtendedGraphemeClusters() {
        let slice = TrackedTextReplacementSlice(
            untouchedPrefix: "",
            textToTransform: "👨‍👩‍👧é",
            trailingText: " "
        )

        XCTAssertEqual(slice.deletedCharacterCount, 3)
        XCTAssertEqual(slice.complete(with: "ok"), "ok ")
    }
}
