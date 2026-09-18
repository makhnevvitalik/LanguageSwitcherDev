// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation

public enum TextCaseTransformer {
    public static func transform(
        _ text: String,
        action: TextCaseAction,
        locale: Locale
    ) -> String {
        switch action {
        case .uppercase:
            text.uppercased(with: locale)
        case .lowercase:
            text.lowercased(with: locale)
        case .capitalizeWords:
            text.capitalized(with: locale)
        case .invertCase:
            invertCase(text, locale: locale)
        }
    }

    private static func invertCase(_ text: String, locale: Locale) -> String {
        text.reduce(into: "") { result, character in
            let value = String(character)
            let lowercase = value.lowercased(with: locale)
            let uppercase = value.uppercased(with: locale)

            if value == lowercase, value != uppercase {
                result += uppercase
            } else if value == uppercase, value != lowercase {
                result += lowercase
            } else {
                result += value
            }
        }
    }
}
