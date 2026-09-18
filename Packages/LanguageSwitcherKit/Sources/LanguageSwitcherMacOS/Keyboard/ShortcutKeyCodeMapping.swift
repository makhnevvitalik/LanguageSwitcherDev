// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public extension ShortcutModifier {
    init?(keyCode: UInt16) {
        switch keyCode {
        case 56, 60: self = .shift
        case 59, 62: self = .control
        case 58, 61: self = .option
        case 54, 55: self = .command
        default: return nil
        }
    }
}

public extension ShortcutFunctionKey {
    init?(keyCode: UInt16) {
        guard let number = Self.numberByKeyCode[keyCode] else { return nil }
        self.init(rawValue: number)
    }

    private static let numberByKeyCode: [UInt16: Int] = [
        122: 1, 120: 2, 99: 3, 118: 4, 96: 5,
        97: 6, 98: 7, 100: 8, 101: 9, 109: 10,
        103: 11, 111: 12, 105: 13, 107: 14, 113: 15,
        106: 16, 64: 17, 79: 18, 80: 19, 90: 20
    ]
}
