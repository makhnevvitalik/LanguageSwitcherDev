// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherEdition

public enum DevEdition {
    public static let identity = AppIdentity(
        brandName: "Language Switcher",
        editionName: "Developer Edition",
        productName: "Language Switcher Dev",
        bundleIdentifier: "com.makhnevvitalik.LanguageSwitcherDev",
        repositoryURL: URL(
            string: "https://github.com/makhnevvitalik/LanguageSwitcherDev"
        )!,
        latestReleaseURL: URL(
            string: "https://github.com/makhnevvitalik/"
                + "LanguageSwitcherDev/releases/latest"
        )!,
        latestReleaseAPIURL: URL(
            string: "https://api.github.com/repos/"
                + "makhnevvitalik/LanguageSwitcherDev/releases/latest"
        )!
    )
}
