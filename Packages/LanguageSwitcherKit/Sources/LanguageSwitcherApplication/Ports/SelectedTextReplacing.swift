// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public protocol SelectedTextReplacing: AnyObject {
    var isBusy: Bool { get }

    @discardableResult
    func replaceSelectedText(
        transform: @escaping (String) -> TextTransformation?,
        completion: @escaping (TextReplacementResult) -> Void
    ) -> Bool
}
