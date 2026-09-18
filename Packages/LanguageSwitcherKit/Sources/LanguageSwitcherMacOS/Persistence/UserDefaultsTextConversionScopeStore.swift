// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherApplication
import LanguageSwitcherDomain

public final class UserDefaultsTextConversionScopeStore: TextConversionScopeStore {
    private enum Keys {
        static let scope = "textTools.conversionScope"
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var scope: TextConversionScope {
        get {
            guard let value = userDefaults.string(forKey: Keys.scope),
                  let scope = TextConversionScope(rawValue: value) else {
                return .typedText
            }
            return scope
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.scope)
        }
    }
}
