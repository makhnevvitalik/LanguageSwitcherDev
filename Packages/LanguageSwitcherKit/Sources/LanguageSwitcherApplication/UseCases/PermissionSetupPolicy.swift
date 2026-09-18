// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public enum TextShortcutPermissionSetupStep: Equatable, Sendable {
    case inputMonitoring
    case accessibility
    case complete
}

public enum TextShortcutPermissionSetup {
    public static func nextStep(
        inputMonitoringAllowed: Bool,
        accessibilityAllowed: Bool
    ) -> TextShortcutPermissionSetupStep {
        if !inputMonitoringAllowed {
            return .inputMonitoring
        }
        if !accessibilityAllowed {
            return .accessibility
        }
        return .complete
    }
}
