// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public enum InputSourceSelectionUpdateResult: Equatable {
    case updated
    case minimumRequired
    case notFound
}

public final class UpdateInputSourceSelection {
    private let repository: any InputSourceRepository
    private let selectionStore: any InputSourceSelectionStore

    public init(
        repository: any InputSourceRepository,
        selectionStore: any InputSourceSelectionStore
    ) {
        self.repository = repository
        self.selectionStore = selectionStore
    }

    public func setSelected(_ isSelected: Bool, inputSourceID: String) -> InputSourceSelectionUpdateResult {
        let sources = repository.availableInputSources()
        guard sources.contains(where: { $0.id == inputSourceID }) else {
            return .notFound
        }

        var excludedIDs = selectionStore.excludedInputSourceIDs
        if isSelected {
            excludedIDs.remove(inputSourceID)
        } else {
            let selectedCount = InputSourceSelectionPolicy.selected(
                from: sources,
                excludedIDs: excludedIDs
            ).count
            guard selectedCount > 2 else {
                return .minimumRequired
            }
            excludedIDs.insert(inputSourceID)
        }

        selectionStore.excludedInputSourceIDs = excludedIDs
        return .updated
    }
}
