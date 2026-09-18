// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import XCTest
import LanguageSwitcherDomain
@testable import LanguageSwitcherApplication

final class InputSourceUseCaseTests: XCTestCase {
    private let english = InputSource(
        id: "english",
        displayName: "English",
        localeIdentifier: "en_US",
        supportsTextConversion: true
    )
    private let russian = InputSource(
        id: "russian",
        displayName: "Russian",
        localeIdentifier: "ru_RU",
        supportsTextConversion: true
    )
    private let german = InputSource(
        id: "german",
        displayName: "German",
        localeIdentifier: "de_DE",
        supportsTextConversion: true
    )

    func testSwitchesToNextSelectedInputSource() {
        let repository = InputSourceRepositoryFake()
        repository.sources = [english, russian, german]
        repository.currentID = english.id
        let store = InputSourceSelectionStoreFake(excludedIDs: [russian.id])
        let activator = InputSourceActivatorFake()
        let useCase = SwitchToNextInputSource(
            repository: repository,
            selectionStore: store,
            activator: activator
        )
        var result: InputSourceSwitchResult?

        useCase.execute { result = $0 }

        XCTAssertEqual(result, .switched(german))
        XCTAssertEqual(activator.requestedIDs, [german.id])
    }

    func testReturnsUnavailableWhenFewerThanTwoSourcesRemainSelected() {
        let repository = InputSourceRepositoryFake()
        repository.sources = [english, russian]
        repository.currentID = english.id
        let store = InputSourceSelectionStoreFake(excludedIDs: [russian.id])
        let activator = InputSourceActivatorFake()
        let useCase = SwitchToNextInputSource(
            repository: repository,
            selectionStore: store,
            activator: activator
        )
        var result: InputSourceSwitchResult?

        useCase.execute { result = $0 }

        XCTAssertEqual(result, .unavailable)
        XCTAssertTrue(activator.requestedIDs.isEmpty)
    }

    func testReportsSelectionFailure() {
        let repository = InputSourceRepositoryFake()
        repository.sources = [english, russian]
        repository.currentID = english.id
        let activator = InputSourceActivatorFake()
        activator.succeeds = false
        let useCase = SwitchToNextInputSource(
            repository: repository,
            selectionStore: InputSourceSelectionStoreFake(),
            activator: activator
        )
        var result: InputSourceSwitchResult?

        useCase.execute { result = $0 }

        XCTAssertEqual(result, .failed)
    }

    func testReportsSwitchOnlyAfterActivationIsVerified() {
        let repository = InputSourceRepositoryFake()
        repository.sources = [english, russian]
        repository.currentID = english.id
        let activator = InputSourceActivatorFake()
        activator.defersCompletion = true
        let useCase = SwitchToNextInputSource(
            repository: repository,
            selectionStore: InputSourceSelectionStoreFake(),
            activator: activator
        )
        var result: InputSourceSwitchResult?

        useCase.execute { result = $0 }

        XCTAssertNil(result)
        activator.complete()
        XCTAssertEqual(result, .switched(russian))
    }

    func testExcludingSourcePersistsItsID() {
        let repository = InputSourceRepositoryFake()
        repository.sources = [english, russian, german]
        let store = InputSourceSelectionStoreFake()
        let useCase = UpdateInputSourceSelection(repository: repository, selectionStore: store)

        XCTAssertEqual(useCase.setSelected(false, inputSourceID: german.id), .updated)
        XCTAssertEqual(store.excludedInputSourceIDs, [german.id])
    }

    func testCannotExcludeOneOfLastTwoSelectedSources() {
        let repository = InputSourceRepositoryFake()
        repository.sources = [english, russian, german]
        let store = InputSourceSelectionStoreFake(excludedIDs: [german.id])
        let useCase = UpdateInputSourceSelection(repository: repository, selectionStore: store)

        XCTAssertEqual(useCase.setSelected(false, inputSourceID: russian.id), .minimumRequired)
        XCTAssertEqual(store.excludedInputSourceIDs, [german.id])
    }

    func testSelectingNewlyAvailableSourceRemovesExclusion() {
        let repository = InputSourceRepositoryFake()
        repository.sources = [english, russian, german]
        let store = InputSourceSelectionStoreFake(excludedIDs: [german.id])
        let useCase = UpdateInputSourceSelection(repository: repository, selectionStore: store)

        XCTAssertEqual(useCase.setSelected(true, inputSourceID: german.id), .updated)
        XCTAssertTrue(store.excludedInputSourceIDs.isEmpty)
    }
}

private final class InputSourceRepositoryFake: InputSourceRepository {
    var sources: [InputSource] = []
    var currentID: String?
    var selectionSucceeds = true
    var selectedIDs: [String] = []

    func availableInputSources() -> [InputSource] {
        sources
    }

    func currentInputSourceID() -> String? {
        currentID
    }

    func selectInputSource(id: String) -> Bool {
        selectedIDs.append(id)
        return selectionSucceeds
    }
}

private final class InputSourceSelectionStoreFake: InputSourceSelectionStore {
    var excludedInputSourceIDs: Set<String>

    init(excludedIDs: Set<String> = []) {
        excludedInputSourceIDs = excludedIDs
    }
}

private final class InputSourceActivatorFake: InputSourceActivating {
    var requestedIDs: [String] = []
    var succeeds = true
    var defersCompletion = false
    private var pendingCompletion: ((InputSourceActivationResult) -> Void)?

    func activateInputSource(
        id: String,
        completion: @escaping (InputSourceActivationResult) -> Void
    ) {
        requestedIDs.append(id)
        if defersCompletion {
            pendingCompletion = completion
        } else {
            completion(result(for: id))
        }
    }

    func complete() {
        guard let id = requestedIDs.last else { return }
        let completion = pendingCompletion
        pendingCompletion = nil
        completion?(result(for: id))
    }

    private func result(for id: String) -> InputSourceActivationResult {
        InputSourceActivationResult(
            requestedInputSourceID: id,
            activeInputSourceID: succeeds ? id : "english",
            succeeded: succeeds
        )
    }
}
