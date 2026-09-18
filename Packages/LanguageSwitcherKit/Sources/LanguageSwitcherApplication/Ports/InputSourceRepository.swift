// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public protocol InputSourceRepository: AnyObject {
    func availableInputSources() -> [InputSource]
    func currentInputSourceID() -> String?
    func selectInputSource(id: String) -> Bool
}
