// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public enum InputSourceSelectionPolicy {
    public static func isSelected(
        _ inputSource: InputSource,
        excludedIDs: Set<String>
    ) -> Bool {
        !excludedIDs.contains(inputSource.id)
    }

    public static func selected(
        from inputSources: [InputSource],
        excludedIDs: Set<String>
    ) -> [InputSource] {
        inputSources.filter { isSelected($0, excludedIDs: excludedIDs) }
    }

    public static func selectedForTextConversion(
        from inputSources: [InputSource],
        excludedIDs: Set<String>
    ) -> [InputSource] {
        selected(from: inputSources, excludedIDs: excludedIDs).filter(\.supportsTextConversion)
    }
}
