// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public protocol WordFrequencyProviding: AnyObject {
    func supports(languageCode: String) -> Bool
    func normalizedFrequency(of word: String, languageCode: String) -> Double?
}
