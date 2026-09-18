// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

struct TextShortcutInputContextPolicy {
    private let shortcuts: [TextActionShortcut]

    init(shortcuts: [TextAction: TextActionShortcut]) {
        self.shortcuts = Array(shortcuts.values)
    }

    func shouldPreserveContext(for event: TextShortcutInputEvent) -> Bool {
        guard case let .keyDown(
            .function(functionKey),
            activeModifiers,
            _,
            isRepeat
        ) = event,
              !isRepeat else {
            return false
        }
        let key = TextShortcutKey.function(functionKey)
        return shortcuts.contains { shortcut in
            switch shortcut {
            case let .once(chord), let .repeatTwice(chord):
                return chord == TextShortcutChord(
                    modifiers: activeModifiers,
                    functionKey: functionKey
                )
            case let .holdAndTapTwice(heldModifiers, tapKey):
                return tapKey == key && heldModifiers == activeModifiers
            }
        }
    }
}
