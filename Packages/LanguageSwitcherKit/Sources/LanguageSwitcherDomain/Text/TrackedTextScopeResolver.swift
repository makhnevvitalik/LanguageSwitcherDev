// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public struct TrackedTextReplacementSlice: Equatable, Sendable {
    public let untouchedPrefix: String
    public let textToTransform: String
    public let trailingText: String

    public init(
        untouchedPrefix: String,
        textToTransform: String,
        trailingText: String
    ) {
        self.untouchedPrefix = untouchedPrefix
        self.textToTransform = textToTransform
        self.trailingText = trailingText
    }

    public var deletedCharacterCount: Int {
        textToTransform.count + trailingText.count
    }

    public func complete(with transformedText: String) -> String {
        untouchedPrefix + transformedText + trailingText
    }
}

public enum TrackedTextScopeResolver {
    public static func resolve(
        text: String,
        scope: TextConversionScope
    ) -> TrackedTextReplacementSlice? {
        guard !text.isEmpty else { return nil }

        switch scope {
        case .typedText:
            return TrackedTextReplacementSlice(
                untouchedPrefix: "",
                textToTransform: text,
                trailingText: ""
            )

        case .lastWord:
            return resolveLastWord(in: text)

        case .selectionOnly:
            return nil
        }
    }

    private static func resolveLastWord(
        in text: String
    ) -> TrackedTextReplacementSlice? {
        var contentEnd = text.endIndex
        while contentEnd > text.startIndex {
            let previous = text.index(before: contentEnd)
            guard text[previous].isWhitespace else { break }
            contentEnd = previous
        }
        guard contentEnd > text.startIndex else { return nil }

        var wordStart = contentEnd
        while wordStart > text.startIndex {
            let previous = text.index(before: wordStart)
            guard !text[previous].isWhitespace else { break }
            wordStart = previous
        }

        return TrackedTextReplacementSlice(
            untouchedPrefix: String(text[..<wordStart]),
            textToTransform: String(text[wordStart..<contentEnd]),
            trailingText: String(text[contentEnd...])
        )
    }
}
