// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

@testable import LanguageSwitcherMacOS
import XCTest

final class TrackedTextBufferTests: XCTestCase {
    func testStoresExactTextForCurrentApplication() {
        let buffer = TrackedTextBuffer()

        buffer.recordPrintableText(
            "hello",
            keyCode: 4,
            eventFlags: 0x20000,
            applicationID: "editor"
        )

        XCTAssertEqual(buffer.snapshot(for: "editor")?.text, "hello")
        XCTAssertEqual(
            buffer.snapshot(for: "editor")?.inputs,
            Array("hello").map {
                TrackedKeyInput(text: String($0), keyCode: 4, eventFlags: 0x20000)
            }
        )
        XCTAssertNil(buffer.snapshot(for: "other"))
    }

    func testReplacementRejectsMismatchedTextAndInputs() throws {
        let buffer = TrackedTextBuffer()
        buffer.recordPrintableText("abc", applicationID: "editor")
        let snapshot = try XCTUnwrap(buffer.snapshot(for: "editor"))

        XCTAssertFalse(buffer.commitReplacement(
            "xyz",
            inputs: [TrackedKeyInput(text: "x", keyCode: 7, eventFlags: 0)],
            expected: snapshot
        ))
        XCTAssertEqual(buffer.snapshot(for: "editor")?.text, "abc")
    }

    func testInputAfterReplacementStartsNewPhysicalSequence() throws {
        let buffer = TrackedTextBuffer()
        buffer.recordPrintableText("abc", keyCode: 0, applicationID: "editor")
        let snapshot = try XCTUnwrap(buffer.snapshot(for: "editor"))
        let replacement = Array("xyz").map {
            TrackedKeyInput(text: String($0), keyCode: 7, eventFlags: 0)
        }
        XCTAssertTrue(buffer.commitReplacement("xyz", inputs: replacement, expected: snapshot))

        buffer.recordPrintableText("s", keyCode: 1, applicationID: "editor")

        XCTAssertEqual(buffer.snapshot(for: "editor")?.text, "s")
        XCTAssertEqual(buffer.snapshot(for: "editor")?.inputs.map(\.keyCode), [1])
    }

    func testCommitRequiresExactSnapshot() throws {
        let buffer = TrackedTextBuffer()
        buffer.recordPrintableText("abc", applicationID: "editor")
        let stale = try XCTUnwrap(buffer.snapshot(for: "editor"))
        buffer.recordPrintableText("d", applicationID: "editor")

        XCTAssertFalse(buffer.commitReplacement(
            "xyz",
            inputs: Array("xyz").map {
                TrackedKeyInput(text: String($0), keyCode: 0, eventFlags: 0)
            },
            expected: stale
        ))
        XCTAssertEqual(buffer.snapshot(for: "editor")?.text, "abcd")
    }

    func testInvalidateDiscardsSnapshot() {
        let buffer = TrackedTextBuffer()
        buffer.recordPrintableText("text", applicationID: "editor")

        buffer.invalidate()

        XCTAssertNil(buffer.snapshot(for: "editor"))
    }
}
