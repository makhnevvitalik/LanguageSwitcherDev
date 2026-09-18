// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public enum KeyboardLayoutConverter {
    public static func convert(_ text: String, using map: KeyboardLayoutMap) -> String {
        text.reduce(into: "") { result, character in
            result += map.replacement(for: character) ?? String(character)
        }
    }
}
