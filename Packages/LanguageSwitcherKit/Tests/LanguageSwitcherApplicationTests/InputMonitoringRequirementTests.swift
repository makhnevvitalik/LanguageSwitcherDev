// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherApplication
import XCTest

final class InputMonitoringRequirementTests: XCTestCase {
    func testNoShortcutsDoNotRequireMonitoring() {
        let features = InputMonitoringRequirement.activeFeatures(
            hasKeyboardShortcuts: false,
            hasTextShortcuts: false,
            isRecordingTextShortcut: false
        )

        XCTAssertFalse(features.isMonitoringRequired)
    }

    func testAnyShortcutRequiresMonitoring() {
        let keyboardFeatures = InputMonitoringRequirement.activeFeatures(
            hasKeyboardShortcuts: true,
            hasTextShortcuts: false,
            isRecordingTextShortcut: false
        )
        let textFeatures = InputMonitoringRequirement.activeFeatures(
            hasKeyboardShortcuts: false,
            hasTextShortcuts: true,
            isRecordingTextShortcut: false
        )

        XCTAssertTrue(keyboardFeatures.isMonitoringRequired)
        XCTAssertTrue(textFeatures.isMonitoringRequired)
    }

    func testRecordingTextShortcutKeepsKeyboardSwitchingMonitoringOnly() {
        let features = InputMonitoringRequirement.activeFeatures(
            hasKeyboardShortcuts: true,
            hasTextShortcuts: true,
            isRecordingTextShortcut: true
        )

        XCTAssertTrue(features.contains(.keyboardSwitching))
        XCTAssertFalse(features.contains(.textShortcuts))
        XCTAssertTrue(features.isMonitoringRequired)
    }

    func testRecordingWithoutKeyboardShortcutsDoesNotRequireMonitoring() {
        let features = InputMonitoringRequirement.activeFeatures(
            hasKeyboardShortcuts: false,
            hasTextShortcuts: true,
            isRecordingTextShortcut: true
        )

        XCTAssertFalse(features.isMonitoringRequired)
    }
}
