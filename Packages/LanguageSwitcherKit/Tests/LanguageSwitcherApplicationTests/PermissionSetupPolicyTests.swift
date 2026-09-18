// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherApplication
import XCTest

final class PermissionSetupPolicyTests: XCTestCase {
    func testTextShortcutSetupRequestsInputMonitoringFirst() {
        XCTAssertEqual(
            TextShortcutPermissionSetup.nextStep(
                inputMonitoringAllowed: false,
                accessibilityAllowed: false
            ),
            .inputMonitoring
        )
    }

    func testTextShortcutSetupRequestsAccessibilityAfterInputMonitoring() {
        XCTAssertEqual(
            TextShortcutPermissionSetup.nextStep(
                inputMonitoringAllowed: true,
                accessibilityAllowed: false
            ),
            .accessibility
        )
    }

    func testTextShortcutSetupCompletesAfterBothPermissions() {
        XCTAssertEqual(
            TextShortcutPermissionSetup.nextStep(
                inputMonitoringAllowed: true,
                accessibilityAllowed: true
            ),
            .complete
        )
    }
}
