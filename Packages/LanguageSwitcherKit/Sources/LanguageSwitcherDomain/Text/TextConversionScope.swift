// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public enum TextConversionScope: String, CaseIterable, Sendable {
    case typedText
    case lastWord
    case selectionOnly
}
