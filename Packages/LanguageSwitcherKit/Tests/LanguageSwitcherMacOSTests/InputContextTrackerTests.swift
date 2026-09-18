// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

@testable import LanguageSwitcherMacOS
import XCTest

final class InputContextTrackerTests: XCTestCase {
    func testRecordedInteractionInvalidatesPreviousGeneration() {
        let tracker = InputContextTracker()
        let original = tracker.generation

        tracker.recordInteraction()

        XCTAssertFalse(tracker.isCurrent(original))
        XCTAssertTrue(tracker.isCurrent(tracker.generation))
    }
}
