// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public struct TextTransformation: Equatable, Sendable {
    public let text: String
    public let targetInputSourceID: String?

    public init(text: String, targetInputSourceID: String? = nil) {
        self.text = text
        self.targetInputSourceID = targetInputSourceID
    }
}

public enum TextReplacementResult: Equatable, Sendable {
    case replaced(TextTransformation)
    case noText
    case unchanged
    case clipboardChanged
    case contextChanged
    case unavailable
    case failed
}
