// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public protocol KeyboardLayoutProvider: AnyObject {
    func characters(inputSourceID: String) -> Set<Character>?
    func map(from sourceInputSourceID: String, to targetInputSourceID: String) -> KeyboardLayoutMap?
}
