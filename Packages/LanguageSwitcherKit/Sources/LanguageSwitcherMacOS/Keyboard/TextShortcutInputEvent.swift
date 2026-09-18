// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherDomain

enum TextShortcutInputEvent: Equatable {
    case keyDown(
        TextShortcutKey,
        activeModifiers: KeyModifiers,
        timestamp: TimeInterval,
        isRepeat: Bool
    )
    case keyUp(
        TextShortcutKey,
        activeModifiers: KeyModifiers,
        timestamp: TimeInterval
    )
    case unrelatedInput

}
