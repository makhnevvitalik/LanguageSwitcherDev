// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public protocol TextActionShortcutStore: AnyObject {
    func shortcut(for action: TextAction) -> TextActionShortcut?
    func setShortcut(_ shortcut: TextActionShortcut?, for action: TextAction)
}
