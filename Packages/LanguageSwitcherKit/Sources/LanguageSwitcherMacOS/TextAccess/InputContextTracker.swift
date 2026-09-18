// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public final class InputContextTracker {
    public private(set) var generation: UInt64 = 0

    public init() {}

    public func recordInteraction() {
        generation &+= 1
    }

    public func isCurrent(_ generation: UInt64) -> Bool {
        self.generation == generation
    }
}
