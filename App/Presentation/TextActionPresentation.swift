// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

@MainActor
extension TextAction {
    init?(identifier: String) {
        guard let action = TextAction.allCases.first(where: { $0.identifier == identifier }) else {
            return nil
        }
        self = action
    }

    var title: String {
        switch self {
        case .convertToNextLayout: localized("Convert Layout")
        case .changeCase(.uppercase): localized("Uppercase")
        case .changeCase(.lowercase): localized("Lowercase")
        case .changeCase(.capitalizeWords): localized("Capitalize Words")
        case .changeCase(.invertCase): localized("Invert Case")
        }
    }

    var example: String {
        switch self {
        case .convertToNextLayout: "ghbdtn → привет"
        case .changeCase(.uppercase): "Hello → HELLO"
        case .changeCase(.lowercase): "Hello → hello"
        case .changeCase(.capitalizeWords): "hello world → Hello World"
        case .changeCase(.invertCase): "Hello → hELLO"
        }
    }
}
