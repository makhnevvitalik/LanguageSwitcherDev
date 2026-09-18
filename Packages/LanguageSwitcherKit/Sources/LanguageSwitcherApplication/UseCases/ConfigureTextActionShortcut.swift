// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public enum ConfigureTextActionShortcutResult: Equatable, Sendable {
    case updated
    case conflict(TextAction)
    case conflictWithReservedShortcut
    case invalid
}

public enum TextActionShortcutValidationResult: Equatable, Sendable {
    case valid
    case conflict(TextAction)
    case conflictWithReservedShortcut
    case invalid
}

public final class ConfigureTextActionShortcut {
    private let store: any TextActionShortcutStore

    public init(store: any TextActionShortcutStore) {
        self.store = store
    }

    public func setShortcut(
        _ shortcut: TextActionShortcut?,
        for action: TextAction,
        reservedShortcuts: [TextActionShortcut] = []
    ) -> ConfigureTextActionShortcutResult {
        guard let shortcut else {
            store.setShortcut(nil, for: action)
            return .updated
        }
        switch validateShortcut(
            shortcut,
            for: action,
            reservedShortcuts: reservedShortcuts
        ) {
        case .valid:
            store.setShortcut(shortcut, for: action)
            return .updated
        case let .conflict(action):
            return .conflict(action)
        case .conflictWithReservedShortcut:
            return .conflictWithReservedShortcut
        case .invalid:
            return .invalid
        }
    }

    public func validateShortcut(
        _ shortcut: TextActionShortcut,
        for action: TextAction,
        reservedShortcuts: [TextActionShortcut] = []
    ) -> TextActionShortcutValidationResult {
        guard shortcut.isValidGlobalShortcut else { return .invalid }
        if let chord = shortcut.classicChord,
           reservedShortcuts.contains(where: { $0.classicChord == chord }) {
            return .conflictWithReservedShortcut
        }
        if let conflict = TextAction.allCases.first(where: {
            $0 != action && store.shortcut(for: $0) == shortcut
        }) {
            return .conflict(conflict)
        }
        return .valid
    }
}
