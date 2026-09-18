// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import AppKit
import LanguageSwitcherApplication

public final class NSSpellCheckerAdapter: WordSpellingChecking {
    private let spellChecker: NSSpellChecker

    public init(spellChecker: NSSpellChecker = .shared) {
        self.spellChecker = spellChecker
    }

    public func prepare(languageCodes: [String]) {
        for languageCode in Set(languageCodes) {
            _ = isCorrectlySpelled("warmup", languageCode: languageCode)
        }
    }

    public func isCorrectlySpelled(_ word: String, languageCode: String) -> Bool {
        guard !word.isEmpty,
              let language = spellingLanguage(for: languageCode) else {
            return false
        }
        var wordCount = 0
        let misspelledRange = spellChecker.checkSpelling(
            of: word,
            startingAt: 0,
            language: language,
            wrap: false,
            inSpellDocumentWithTag: 0,
            wordCount: &wordCount
        )
        return misspelledRange.location == NSNotFound
    }

    private func spellingLanguage(for languageCode: String) -> String? {
        let requested = languageCode.replacingOccurrences(of: "_", with: "-").lowercased()
        let base = requested.split(separator: "-").first.map(String.init) ?? requested
        let languages = spellChecker.availableLanguages

        if let exact = languages.first(where: {
            $0.replacingOccurrences(of: "_", with: "-").lowercased() == requested
        }) {
            return exact
        }
        return languages.first(where: {
            let normalized = $0.replacingOccurrences(of: "_", with: "-").lowercased()
            return normalized == base || normalized.hasPrefix("\(base)-")
        })
    }
}
