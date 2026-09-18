// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherDomain

public struct LanguageAwareLayoutConversion: Equatable, Sendable {
    public let text: String
    public let targetInputSourceID: String

    public init(text: String, targetInputSourceID: String) {
        self.text = text
        self.targetInputSourceID = targetInputSourceID
    }
}

public enum LexiconLanguageResolver {
    public static func languageCode(for localeIdentifier: String?) -> String? {
        guard let localeIdentifier, !localeIdentifier.isEmpty else { return nil }
        let normalized = localeIdentifier
            .replacingOccurrences(of: "-", with: "_")
            .lowercased()
        if normalized == "pt_br" || normalized.hasPrefix("pt_br_") {
            return "pt_br"
        }
        return normalized.split(separator: "_").first.map(String.init)
    }
}

public protocol AutomaticLayoutConverting: AnyObject {
    func convert(
        _ text: String,
        current: InputSource,
        availableInputSources: [InputSource]
    ) -> LanguageAwareLayoutConversion?
}

public final class LanguageAwareLayoutConverter: AutomaticLayoutConverting {
    private let keyboardLayoutProvider: any KeyboardLayoutProvider
    private let frequencyProvider: any WordFrequencyProviding
    private let spellingChecker: any WordSpellingChecking

    public init(
        keyboardLayoutProvider: any KeyboardLayoutProvider,
        frequencyProvider: any WordFrequencyProviding,
        spellingChecker: any WordSpellingChecking
    ) {
        self.keyboardLayoutProvider = keyboardLayoutProvider
        self.frequencyProvider = frequencyProvider
        self.spellingChecker = spellingChecker
    }

    public func convert(
        _ text: String,
        current: InputSource,
        availableInputSources: [InputSource]
    ) -> LanguageAwareLayoutConversion? {
        let lexiconInputSources = availableInputSources.filter {
            guard $0.supportsTextConversion,
                  let languageCode = LexiconLanguageResolver.languageCode(
                      for: $0.localeIdentifier
                  ) else {
                return false
            }
            return frequencyProvider.supports(languageCode: languageCode)
        }
        let sourceCharacters = Dictionary(uniqueKeysWithValues: lexiconInputSources.compactMap {
            inputSource -> (String, Set<Character>)? in
            guard let characters = keyboardLayoutProvider.characters(
                inputSourceID: inputSource.id
            ) else {
                return nil
            }
            return (inputSource.id, characters)
        })
        let supportedInputSources = lexiconInputSources.filter {
            sourceCharacters[$0.id] != nil
        }
        guard supportedInputSources.count > 1 else { return nil }

        var convertedText = ""
        var lastChangedInputSourceID: String?

        for fragment in fragments(in: text) {
            guard !fragment.isWhitespace else {
                convertedText += fragment.text
                continue
            }

            let conversion = conversion(
                for: fragment.text,
                current: current,
                availableInputSources: supportedInputSources,
                sourceCharacters: sourceCharacters
            )
            let result = conversion?.text ?? fragment.text
            convertedText += result
            if result != fragment.text, let conversion {
                lastChangedInputSourceID = conversion.targetInputSourceID
            }
        }

        guard convertedText != text, let lastChangedInputSourceID else { return nil }
        return LanguageAwareLayoutConversion(
            text: convertedText,
            targetInputSourceID: lastChangedInputSourceID
        )
    }

    private func conversion(
        for fragment: String,
        current: InputSource,
        availableInputSources: [InputSource],
        sourceCharacters: [String: Set<Character>]
    ) -> FragmentConversion? {
        let orderedSources = currentFirst(current, in: availableInputSources)
        var candidates: [LayoutConversionCandidate] = []

        for source in orderedSources {
            guard let sourceCharacterSet = sourceCharacters[source.id] else { continue }
            candidates.append(
                candidate(
                    text: fragment,
                    inputSource: source,
                    characterCoverageScore: fragment.reduce(into: 0) { count, character in
                        if sourceCharacterSet.contains(character) {
                            count += 1
                        }
                    }
                )
            )
        }

        guard let sourceCandidate = LayoutConversionCandidateSelector.best(in: candidates),
              let target = InputSourceCycle.next(
                  after: sourceCandidate.inputSourceID,
                  in: availableInputSources
              ), let map = keyboardLayoutProvider.map(
                  from: sourceCandidate.inputSourceID,
                  to: target.id
              ) else {
            return nil
        }
        return FragmentConversion(
            text: KeyboardLayoutConverter.convert(fragment, using: map),
            targetInputSourceID: target.id
        )
    }

    private func candidate(
        text: String,
        inputSource: InputSource,
        characterCoverageScore: Int
    ) -> LayoutConversionCandidate {
        let languageCode = LexiconLanguageResolver.languageCode(for: inputSource.localeIdentifier)
        guard let languageCode,
              frequencyProvider.supports(languageCode: languageCode),
              let word = lexicalWord(in: text, localeIdentifier: inputSource.localeIdentifier) else {
            return LayoutConversionCandidate(
                inputSourceID: inputSource.id,
                characterCoverageScore: characterCoverageScore,
                spellingScore: 0,
                frequencyScore: 0
            )
        }

        return LayoutConversionCandidate(
            inputSourceID: inputSource.id,
            characterCoverageScore: characterCoverageScore,
            spellingScore: spellingChecker.isCorrectlySpelled(
                word,
                languageCode: languageCode
            ) ? 1 : 0,
            frequencyScore: frequencyProvider.normalizedFrequency(
                of: word,
                languageCode: languageCode
            ) ?? 0
        )
    }

    private func currentFirst(
        _ current: InputSource,
        in inputSources: [InputSource]
    ) -> [InputSource] {
        guard let currentIndex = inputSources.firstIndex(where: { $0.id == current.id }),
              currentIndex != inputSources.startIndex else {
            return inputSources
        }
        var result = inputSources
        result.insert(result.remove(at: currentIndex), at: result.startIndex)
        return result
    }

    private func lexicalWord(in text: String, localeIdentifier: String?) -> String? {
        let joiners = CharacterSet(charactersIn: "'’‘ʼ-‐‑‒–—―")
        var scalars = text.unicodeScalars.filter {
            CharacterSet.alphanumerics.contains($0) || joiners.contains($0)
        }
        while let first = scalars.first, joiners.contains(first) {
            scalars.removeFirst()
        }
        while let last = scalars.last, joiners.contains(last) {
            scalars.removeLast()
        }
        guard !scalars.isEmpty else { return nil }
        return String(String.UnicodeScalarView(scalars)).lowercased(
            with: Locale(identifier: localeIdentifier ?? "en")
        )
    }

    private func fragments(in text: String) -> [TextFragment] {
        var fragments: [TextFragment] = []
        var current = ""
        var currentIsWhitespace: Bool?

        for character in text {
            let isWhitespace = character.isWhitespace
            if let currentIsWhitespace, currentIsWhitespace != isWhitespace {
                fragments.append(TextFragment(text: current, isWhitespace: currentIsWhitespace))
                current = ""
            }
            current += String(character)
            currentIsWhitespace = isWhitespace
        }
        if let currentIsWhitespace {
            fragments.append(TextFragment(text: current, isWhitespace: currentIsWhitespace))
        }
        return fragments
    }
}

private struct TextFragment {
    let text: String
    let isWhitespace: Bool
}

private struct FragmentConversion {
    let text: String
    let targetInputSourceID: String
}
