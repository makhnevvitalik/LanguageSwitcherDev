// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherApplication

protocol InputSourceActivationScheduling: AnyObject {
    var now: TimeInterval { get }
    func schedule(after delay: TimeInterval, _ action: @escaping () -> Void)
}

final class DispatchInputSourceActivationScheduler: InputSourceActivationScheduling {
    var now: TimeInterval { ProcessInfo.processInfo.systemUptime }

    func schedule(after delay: TimeInterval, _ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
    }
}

public final class VerifiedInputSourceActivator: InputSourceActivating {
    private let repository: any InputSourceRepository
    private let scheduler: any InputSourceActivationScheduling
    private let retryInterval: TimeInterval
    private let timeout: TimeInterval
    private let diagnostics: ((String) -> Void)?

    public convenience init(
        repository: any InputSourceRepository,
        diagnostics: ((String) -> Void)? = nil
    ) {
        self.init(
            repository: repository,
            scheduler: DispatchInputSourceActivationScheduler(),
            retryInterval: 0.02,
            timeout: 0.20,
            diagnostics: diagnostics
        )
    }

    init(
        repository: any InputSourceRepository,
        scheduler: any InputSourceActivationScheduling,
        retryInterval: TimeInterval,
        timeout: TimeInterval,
        diagnostics: ((String) -> Void)? = nil
    ) {
        self.repository = repository
        self.scheduler = scheduler
        self.retryInterval = retryInterval
        self.timeout = timeout
        self.diagnostics = diagnostics
    }

    public func activateInputSource(
        id: String,
        completion: @escaping (InputSourceActivationResult) -> Void
    ) {
        if Thread.isMainThread {
            beginActivation(id: id, completion: completion)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.beginActivation(id: id, completion: completion)
            }
        }
    }

    private func beginActivation(
        id: String,
        completion: @escaping (InputSourceActivationResult) -> Void
    ) {
        let sourceID = repository.currentInputSourceID()
        let requestAccepted = repository.selectInputSource(id: id)
        guard requestAccepted else {
            finish(
                sourceID: sourceID,
                targetID: id,
                activeID: repository.currentInputSourceID(),
                succeeded: false,
                completion: completion
            )
            return
        }

        verify(
            sourceID: sourceID,
            targetID: id,
            deadline: scheduler.now + timeout,
            completion: completion
        )
    }

    private func verify(
        sourceID: String?,
        targetID: String,
        deadline: TimeInterval,
        completion: @escaping (InputSourceActivationResult) -> Void
    ) {
        let activeID = repository.currentInputSourceID()
        if activeID == targetID {
            finish(
                sourceID: sourceID,
                targetID: targetID,
                activeID: activeID,
                succeeded: true,
                completion: completion
            )
            return
        }
        guard scheduler.now < deadline else {
            finish(
                sourceID: sourceID,
                targetID: targetID,
                activeID: activeID,
                succeeded: false,
                completion: completion
            )
            return
        }

        scheduler.schedule(after: retryInterval) { [weak self] in
            self?.verify(
                sourceID: sourceID,
                targetID: targetID,
                deadline: deadline,
                completion: completion
            )
        }
    }

    private func finish(
        sourceID: String?,
        targetID: String,
        activeID: String?,
        succeeded: Bool,
        completion: (InputSourceActivationResult) -> Void
    ) {
        diagnostics?(
            "sourceInputSourceID=\(sourceID ?? "none") "
                + "targetInputSourceID=\(targetID) "
                + "activeInputSourceIDAfterSelection=\(activeID ?? "none") "
                + "selectionSucceeded=\(succeeded)"
        )
        completion(
            InputSourceActivationResult(
                requestedInputSourceID: targetID,
                activeInputSourceID: activeID,
                succeeded: succeeded
            )
        )
    }
}
