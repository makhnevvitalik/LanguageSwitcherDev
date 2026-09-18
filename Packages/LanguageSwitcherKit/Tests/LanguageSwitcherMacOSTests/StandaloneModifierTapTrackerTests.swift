// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit
import XCTest
@testable import LanguageSwitcherMacOS

final class StandaloneModifierTapTrackerTests: XCTestCase {
    func testShortStandaloneCommandTapTriggersOnRelease() {
        var tracker = StandaloneModifierTapTracker.command(maximumTapDuration: 0.2)

        XCTAssertFalse(tracker.handle(.flagsChanged(keyCode: 55, flags: [.command], timestamp: 1.0)))
        XCTAssertTrue(tracker.handle(.flagsChanged(keyCode: 55, flags: [], timestamp: 1.1)))
    }

    func testLongCommandPressDoesNotTrigger() {
        var tracker = StandaloneModifierTapTracker.command(maximumTapDuration: 0.2)

        _ = tracker.handle(.flagsChanged(keyCode: 55, flags: [.command], timestamp: 1.0))

        XCTAssertFalse(tracker.handle(.flagsChanged(keyCode: 55, flags: [], timestamp: 1.2)))
    }

    func testCommandUsedWithKeyDoesNotTrigger() {
        var tracker = StandaloneModifierTapTracker.command(maximumTapDuration: 0.2)

        _ = tracker.handle(.flagsChanged(keyCode: 55, flags: [.command], timestamp: 1.0))
        _ = tracker.handle(.keyDown(flags: [.command]))

        XCTAssertFalse(tracker.handle(.flagsChanged(keyCode: 55, flags: [], timestamp: 1.1)))
    }

    func testCommandUsedWithMouseDoesNotTrigger() {
        var tracker = StandaloneModifierTapTracker.command(maximumTapDuration: 0.2)

        _ = tracker.handle(.flagsChanged(keyCode: 55, flags: [.command], timestamp: 1.0))
        _ = tracker.handle(.mouseDown(flags: [.command]))

        XCTAssertFalse(tracker.handle(.flagsChanged(keyCode: 55, flags: [], timestamp: 1.1)))
    }

    func testCapsLockDoesNotInvalidateFunctionGlobeTap() {
        var tracker = StandaloneModifierTapTracker.functionGlobe(maximumTapDuration: 0.2)

        _ = tracker.handle(.flagsChanged(keyCode: 63, flags: [.function, .capsLock], timestamp: 1.0))

        XCTAssertTrue(tracker.handle(.flagsChanged(keyCode: 63, flags: [.capsLock], timestamp: 1.1)))
    }
}
