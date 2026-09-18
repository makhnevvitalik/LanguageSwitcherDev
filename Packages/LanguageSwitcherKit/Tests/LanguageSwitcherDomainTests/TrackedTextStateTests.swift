// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain
import XCTest

final class TrackedTextStateTests: XCTestCase {
    func testPrintableInputStoresExactText() {
        var state = TrackedTextState()

        state.recordPrintableText("ghbdtn 👨‍👩‍👧", applicationID: "editor")

        XCTAssertEqual(state.snapshot?.applicationID, "editor")
        XCTAssertEqual(state.snapshot?.text, "ghbdtn 👨‍👩‍👧")
    }

    func testApplicationChangeStartsIndependentBuffer() {
        var state = TrackedTextState()
        state.recordPrintableText("first", applicationID: "first-editor")

        state.recordPrintableText("second", applicationID: "second-editor")

        XCTAssertEqual(state.snapshot?.applicationID, "second-editor")
        XCTAssertEqual(state.snapshot?.text, "second")
    }

    func testInputAfterLayoutSwitchBoundaryStartsIndependentBuffer() {
        var state = TrackedTextState()
        state.recordPrintableText("пибжэъёх", applicationID: "editor")

        state.invalidate()
        state.recordPrintableText("s", applicationID: "editor")

        XCTAssertEqual(state.snapshot?.text, "s")
    }

    func testBackspaceRemovesOneExtendedGraphemeCluster() {
        var state = TrackedTextState()
        state.recordPrintableText("a👨‍👩‍👧", applicationID: "editor")

        state.recordBackspace(applicationID: "editor")

        XCTAssertEqual(state.snapshot?.text, "a")
    }

    func testBackspacePastKnownBoundaryInvalidatesBuffer() {
        var state = TrackedTextState()
        state.recordPrintableText("a", applicationID: "editor")

        state.recordBackspace(applicationID: "editor")
        state.recordBackspace(applicationID: "editor")

        XCTAssertNil(state.snapshot)
    }

    func testFirstPrintableInputAfterReplacementStartsNewSegment() throws {
        var state = TrackedTextState()
        state.recordPrintableText("ghbdtn", applicationID: "editor")
        let snapshot = try XCTUnwrap(state.snapshot)
        XCTAssertTrue(state.commitReplacement("привет", expected: snapshot))

        state.recordPrintableText("!", applicationID: "editor")

        XCTAssertEqual(state.snapshot?.text, "!")
    }

    func testImmediateReplacementCanTargetConvertedTextAgain() throws {
        var state = TrackedTextState()
        state.recordPrintableText("ghbdtn", applicationID: "editor")
        XCTAssertTrue(state.commitReplacement("привет", expected: try XCTUnwrap(state.snapshot)))

        XCTAssertTrue(state.commitReplacement("ghbdtn", expected: try XCTUnwrap(state.snapshot)))

        XCTAssertEqual(state.snapshot?.text, "ghbdtn")
    }

    func testBackspaceAfterReplacementEditsConvertedSegment() throws {
        var state = TrackedTextState()
        state.recordPrintableText("ghbdtn", applicationID: "editor")
        XCTAssertTrue(state.commitReplacement("привет", expected: try XCTUnwrap(state.snapshot)))

        state.recordBackspace(applicationID: "editor")

        XCTAssertEqual(state.snapshot?.text, "приве")
    }

    func testCommitRejectsStaleSnapshot() throws {
        var state = TrackedTextState()
        state.recordPrintableText("abc", applicationID: "editor")
        let stale = try XCTUnwrap(state.snapshot)
        state.recordPrintableText("d", applicationID: "editor")

        XCTAssertFalse(state.commitReplacement("xyz", expected: stale))
        XCTAssertEqual(state.snapshot?.text, "abcd")
    }
}
