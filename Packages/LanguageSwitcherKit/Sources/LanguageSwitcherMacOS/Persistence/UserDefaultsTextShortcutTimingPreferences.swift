// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation

public final class UserDefaultsTextShortcutTimingPreferences {
    public static let intervalOptions = (2...10).map { Double($0) / 10 }
    public static let defaultInterval: TimeInterval = 0.3

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var maximumMultiPressInterval: TimeInterval {
        get {
            guard userDefaults.object(
                forKey: UserDefaultsTextShortcutKeys.maximumMultiPressInterval
            ) != nil else {
                return Self.defaultInterval
            }
            let stored = userDefaults.double(
                forKey: UserDefaultsTextShortcutKeys.maximumMultiPressInterval
            )
            return Self.intervalOptions.contains(stored) ? stored : Self.defaultInterval
        }
        set {
            guard Self.intervalOptions.contains(newValue) else { return }
            userDefaults.set(
                newValue,
                forKey: UserDefaultsTextShortcutKeys.maximumMultiPressInterval
            )
        }
    }
}
