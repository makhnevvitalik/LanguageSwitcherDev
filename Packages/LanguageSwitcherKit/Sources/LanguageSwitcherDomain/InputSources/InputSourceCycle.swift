// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public enum InputSourceCycle {
    public static func next(after currentID: String?, in inputSources: [InputSource]) -> InputSource? {
        guard inputSources.count >= 2 else {
            return nil
        }

        guard let currentID,
              let currentIndex = inputSources.firstIndex(where: { $0.id == currentID }) else {
            return inputSources.first
        }

        return inputSources[(currentIndex + 1) % inputSources.count]
    }
}
