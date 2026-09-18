// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit

protocol FrontmostApplicationProviding: AnyObject {
    var applicationID: String? { get }
}

final class FrontmostApplicationProvider: FrontmostApplicationProviding {
    var applicationID: String? {
        guard let application = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        return application.bundleIdentifier ?? "pid:\(application.processIdentifier)"
    }
}
