// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public struct InputSourceActivationResult: Equatable, Sendable {
    public let requestedInputSourceID: String
    public let activeInputSourceID: String?
    public let succeeded: Bool

    public init(
        requestedInputSourceID: String,
        activeInputSourceID: String?,
        succeeded: Bool
    ) {
        self.requestedInputSourceID = requestedInputSourceID
        self.activeInputSourceID = activeInputSourceID
        self.succeeded = succeeded
    }
}

public protocol InputSourceActivating: AnyObject {
    func activateInputSource(
        id: String,
        completion: @escaping (InputSourceActivationResult) -> Void
    )
}
