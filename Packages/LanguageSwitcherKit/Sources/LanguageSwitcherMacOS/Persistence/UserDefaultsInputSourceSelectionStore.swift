// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherApplication

public final class UserDefaultsInputSourceSelectionStore: InputSourceSelectionStore {
    private enum Keys {
        static let excludedInputSourceIDs = "inputSources.excludedIDs"
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var excludedInputSourceIDs: Set<String> {
        get {
            Set(userDefaults.stringArray(forKey: Keys.excludedInputSourceIDs) ?? [])
        }
        set {
            userDefaults.set(newValue.sorted(), forKey: Keys.excludedInputSourceIDs)
        }
    }
}
