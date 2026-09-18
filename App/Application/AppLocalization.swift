// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherLocalization

@MainActor
enum AppLocalization {
    private(set) static var localizer = AppLocalizer(language: .english)

    static func configure(language: AppLanguage) {
        localizer = AppLocalizer(language: language)
    }
}

@MainActor
func localized(_ key: String) -> String {
    AppLocalization.localizer.text(key)
}

@MainActor
func localizedFormat(_ key: String, _ arguments: CVarArg...) -> String {
    AppLocalization.localizer.format(key, arguments: arguments)
}
