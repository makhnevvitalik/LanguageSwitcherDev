// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation

public struct InputSource: Equatable, Identifiable, Sendable {
    public let id: String
    public let displayName: String
    public let localeIdentifier: String?
    public let supportsTextConversion: Bool

    public init(
        id: String,
        displayName: String,
        localeIdentifier: String?,
        supportsTextConversion: Bool
    ) {
        self.id = id
        self.displayName = displayName
        self.localeIdentifier = localeIdentifier
        self.supportsTextConversion = supportsTextConversion
    }
}
