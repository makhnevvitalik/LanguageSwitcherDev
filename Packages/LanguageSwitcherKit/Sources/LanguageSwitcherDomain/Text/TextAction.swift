// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public enum TextCaseAction: String, CaseIterable, Hashable, Sendable {
    case uppercase
    case lowercase
    case capitalizeWords
    case invertCase
}

public enum TextAction: Equatable, Hashable, Sendable {
    case convertToNextLayout
    case changeCase(TextCaseAction)

    public static let allCases: [TextAction] = [
        .convertToNextLayout,
        .changeCase(.uppercase),
        .changeCase(.lowercase),
        .changeCase(.capitalizeWords),
        .changeCase(.invertCase)
    ]

    public var identifier: String {
        switch self {
        case .convertToNextLayout:
            "convertToNextLayout"
        case let .changeCase(action):
            action.rawValue
        }
    }
}
