// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherDomain

public enum InputSourceSwitchResult: Equatable {
    case switched(InputSource)
    case unavailable
    case failed
}

public final class SwitchToNextInputSource {
    private let repository: any InputSourceRepository
    private let selectionStore: any InputSourceSelectionStore
    private let activator: any InputSourceActivating

    public init(
        repository: any InputSourceRepository,
        selectionStore: any InputSourceSelectionStore,
        activator: any InputSourceActivating
    ) {
        self.repository = repository
        self.selectionStore = selectionStore
        self.activator = activator
    }

    public func execute(completion: @escaping (InputSourceSwitchResult) -> Void) {
        let excludedIDs = selectionStore.excludedInputSourceIDs
        let inputSources = InputSourceSelectionPolicy.selected(
            from: repository.availableInputSources(),
            excludedIDs: excludedIDs
        )

        guard let nextSource = InputSourceCycle.next(
            after: repository.currentInputSourceID(),
            in: inputSources
        ) else {
            completion(.unavailable)
            return
        }

        activator.activateInputSource(id: nextSource.id) { result in
            completion(result.succeeded ? .switched(nextSource) : .failed)
        }
    }
}
