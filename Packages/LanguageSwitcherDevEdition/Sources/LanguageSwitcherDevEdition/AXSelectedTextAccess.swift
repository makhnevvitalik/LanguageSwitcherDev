// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

enum AXSelectedTextReadResult: Equatable {
    case selection(String)
    case noText
    case unsupported
}

protocol AXSelectedTextReading: AnyObject {
    func readSelection() -> AXSelectedTextReadResult
}
