// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public struct InputMonitoringFeatures: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let keyboardSwitching = Self(rawValue: 1 << 0)
    public static let textShortcuts = Self(rawValue: 1 << 1)

    public var isMonitoringRequired: Bool {
        !isEmpty
    }
}

public enum InputMonitoringRequirement {
    public static func activeFeatures(
        hasKeyboardShortcuts: Bool,
        hasTextShortcuts: Bool,
        isRecordingTextShortcut: Bool
    ) -> InputMonitoringFeatures {
        var features: InputMonitoringFeatures = []
        if hasKeyboardShortcuts {
            features.insert(.keyboardSwitching)
        }
        if hasTextShortcuts, !isRecordingTextShortcut {
            features.insert(.textShortcuts)
        }
        return features
    }

}
