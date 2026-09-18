// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public protocol InputSourceSelectionStore: AnyObject {
    var excludedInputSourceIDs: Set<String> { get set }
}
