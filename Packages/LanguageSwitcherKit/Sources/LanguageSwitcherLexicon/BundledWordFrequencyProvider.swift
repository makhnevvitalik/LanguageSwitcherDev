// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherApplication

public final class BundledWordFrequencyProvider: WordFrequencyProviding {
    private struct FrequencyEntry {
        let word: String
        let score: Double
    }

    private struct FrequencyTable {
        let entries: [FrequencyEntry]

        subscript(word: String) -> Double? {
            var lowerBound = entries.startIndex
            var upperBound = entries.endIndex
            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                let candidate = entries[middle]
                if candidate.word < word {
                    lowerBound = middle + 1
                } else if candidate.word > word {
                    upperBound = middle
                } else {
                    return candidate.score
                }
            }
            return nil
        }
    }

    private let resourceDirectory: URL
    private let lock = NSLock()
    private var cachedFrequencies: [String: FrequencyTable] = [:]

    public convenience init() {
        self.init(resourceDirectory: Bundle.module.resourceURL!)
    }

    public init(resourceDirectory: URL) {
        self.resourceDirectory = resourceDirectory
    }

    public func supports(languageCode: String) -> Bool {
        FileManager.default.fileExists(atPath: resourceURL(for: languageCode).path)
    }

    public func prepare(languageCodes: [String]) {
        for languageCode in Set(languageCodes.map { $0.lowercased() })
            where supports(languageCode: languageCode) {
            _ = frequencies(languageCode: languageCode)
        }
    }

    public func normalizedFrequency(of word: String, languageCode: String) -> Double? {
        let languageCode = languageCode.lowercased()
        guard supports(languageCode: languageCode) else { return nil }
        let normalizedWord = Self.normalize(word, languageCode: languageCode)

        return frequencies(languageCode: languageCode)[normalizedWord]
    }

    private func frequencies(languageCode: String) -> FrequencyTable {
        lock.lock()
        if let cached = cachedFrequencies[languageCode] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        let frequencies = loadFrequencies(languageCode: languageCode)

        lock.lock()
        defer { lock.unlock() }
        if let cached = cachedFrequencies[languageCode] {
            return cached
        }
        cachedFrequencies[languageCode] = frequencies
        return frequencies
    }

    private func loadFrequencies(languageCode: String) -> FrequencyTable {
        guard let contents = try? String(
            contentsOf: resourceURL(for: languageCode),
            encoding: .utf8
        ) else {
            return FrequencyTable(entries: [])
        }
        let words = contents.split(whereSeparator: \Character.isNewline)
        guard !words.isEmpty else { return FrequencyTable(entries: []) }

        var entries = words.enumerated().map { index, word in
            FrequencyEntry(
                word: Self.normalize(String(word), languageCode: languageCode),
                score: Double(words.count - index) / Double(words.count)
            )
        }
        entries.sort { lhs, rhs in
            lhs.word == rhs.word ? lhs.score > rhs.score : lhs.word < rhs.word
        }

        var uniqueCount = 0
        for entry in entries {
            if uniqueCount == 0 || entries[uniqueCount - 1].word != entry.word {
                entries[uniqueCount] = entry
                uniqueCount += 1
            }
        }
        entries.removeLast(entries.count - uniqueCount)
        return FrequencyTable(entries: entries)
    }

    private func resourceURL(for languageCode: String) -> URL {
        resourceDirectory.appendingPathComponent("\(languageCode.lowercased()).txt")
    }

    private static func normalize(_ word: String, languageCode: String) -> String {
        let localeIdentifier = languageCode.replacingOccurrences(of: "_", with: "-")
        return word
            .precomposedStringWithCanonicalMapping
            .lowercased(with: Locale(identifier: localeIdentifier))
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "‘", with: "'")
            .replacingOccurrences(of: "ʼ", with: "'")
            .replacingOccurrences(of: "‐", with: "-")
            .replacingOccurrences(of: "‑", with: "-")
            .replacingOccurrences(of: "‒", with: "-")
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .replacingOccurrences(of: "―", with: "-")
    }
}
