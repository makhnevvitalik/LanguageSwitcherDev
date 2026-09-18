// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public protocol TextConversionScopeStore: AnyObject {
    var scope: TextConversionScope { get set }
}
