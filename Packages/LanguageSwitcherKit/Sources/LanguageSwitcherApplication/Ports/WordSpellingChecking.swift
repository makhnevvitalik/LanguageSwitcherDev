// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public protocol WordSpellingChecking: AnyObject {
    func isCorrectlySpelled(_ word: String, languageCode: String) -> Bool
}
