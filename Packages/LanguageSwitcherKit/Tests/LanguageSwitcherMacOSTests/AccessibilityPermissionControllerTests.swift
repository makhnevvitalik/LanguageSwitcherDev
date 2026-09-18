// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import XCTest
@testable import LanguageSwitcherMacOS

final class AccessibilityPermissionControllerTests: XCTestCase {
    func testOpensAccessibilitySettingsPane() {
        var openedURL: URL?
        let controller = AccessibilityPermissionController(
            isAllowed: { false },
            openURL: {
                openedURL = $0
                return true
            }
        )

        XCTAssertTrue(controller.openSettings())
        XCTAssertEqual(
            openedURL?.absoluteString,
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        )
    }
}
