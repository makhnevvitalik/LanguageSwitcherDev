// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public protocol TrackedTextReplacing: AnyObject {
    var isBusy: Bool { get }

    @discardableResult
    func replaceTrackedText(
        scope: TextConversionScope,
        transform: @escaping (String) -> TextTransformation?,
        completion: @escaping (TextReplacementResult) -> Void
    ) -> Bool
}
