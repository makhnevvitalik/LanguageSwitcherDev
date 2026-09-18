// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit

public enum FunctionGlobeTrackingAvailability: Equatable {
    case available
    case unavailable(FunctionGlobeTrackingIssue)
}

public enum FunctionGlobeTrackingIssue: Equatable {
    case cannotReadSystemSetting
    case systemActionEnabled
}

public final class FunctionGlobeSystemBehaviorController {
    private enum Constants {
        static let domain = "com.apple.HIToolbox" as CFString
        static let usageTypeKey = "AppleFnUsageType" as CFString
        static let doNothingUsageType = 0
        static let settingsURLs = [
            "x-apple.systempreferences:com.apple.Keyboard-Settings.extension",
            "x-apple.systempreferences:com.apple.preference.keyboard",
            "x-apple.systempreferences:"
        ]
    }

    public init() {}

    public func trackingAvailability() -> FunctionGlobeTrackingAvailability {
        guard let usageType = readUsageType() else {
            return .unavailable(.cannotReadSystemSetting)
        }
        guard usageType == Constants.doNothingUsageType else {
            return .unavailable(.systemActionEnabled)
        }
        return .available
    }

    @discardableResult
    public func openKeyboardSettings() -> Bool {
        for value in Constants.settingsURLs {
            if let url = URL(string: value), NSWorkspace.shared.open(url) {
                return true
            }
        }
        return false
    }

    private func readUsageType() -> Int? {
        guard let value = CFPreferencesCopyAppValue(Constants.usageTypeKey, Constants.domain) else {
            return nil
        }
        if let value = value as? Int {
            return value
        }
        return (value as? NSNumber)?.intValue
    }
}
