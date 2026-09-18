// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherApplication
import LanguageSwitcherDomain
import XCTest

final class PerformTextActionTests: XCTestCase {
    func testTrackedTextHasPriorityForTypedText() {
        let selected = SelectedTextReplacerMock(text: "selected")
        let tracked = TrackedTextReplacerMock(text: "typed")
        let useCase = makeUseCase(selected: selected, tracked: tracked)
        var result: PerformTextActionResult?

        useCase.execute(.changeCase(.uppercase)) { result = $0 }

        XCTAssertEqual(tracked.replacement, "TYPED")
        XCTAssertEqual(selected.callCount, 0)
        XCTAssertEqual(result, .replaced)
    }

    func testNoTrackedTextFallsBackToSelectedText() {
        let selected = SelectedTextReplacerMock(text: "selected")
        let tracked = TrackedTextReplacerMock()
        tracked.result = .noText
        let useCase = makeUseCase(
            selected: selected,
            tracked: tracked,
            scopeStore: TextConversionScopeStoreMock(scope: .typedText)
        )
        var result: PerformTextActionResult?

        useCase.execute(.changeCase(.uppercase)) { result = $0 }

        XCTAssertEqual(tracked.scope, .typedText)
        XCTAssertEqual(selected.replacement, "SELECTED")
        XCTAssertEqual(result, .replaced)
    }

    func testSelectionOnlyDoesNotFallback() {
        let selected = SelectedTextReplacerMock(result: .noText)
        let tracked = TrackedTextReplacerMock()
        let useCase = makeUseCase(selected: selected, tracked: tracked)
        var result: PerformTextActionResult?

        useCase.execute(.changeCase(.uppercase), scope: .selectionOnly) { result = $0 }

        XCTAssertEqual(selected.callCount, 1)
        XCTAssertEqual(tracked.callCount, 0)
        XCTAssertEqual(result, .noText)
    }

    func testTrackedContextChangeDoesNotFallBackToClipboard() {
        let selected = SelectedTextReplacerMock()
        let tracked = TrackedTextReplacerMock()
        tracked.result = .contextChanged
        let useCase = makeUseCase(selected: selected, tracked: tracked)
        var result: PerformTextActionResult?

        useCase.execute(.changeCase(.uppercase)) { result = $0 }

        XCTAssertEqual(selected.callCount, 0)
        XCTAssertEqual(result, .contextChanged)
    }

    func testRejectsSecondActionWhileFirstIsPending() {
        let selected = SelectedTextReplacerMock()
        selected.deferCompletion = true
        let useCase = makeUseCase(selected: selected)
        var secondResult: PerformTextActionResult?

        useCase.execute(.changeCase(.uppercase), scope: .selectionOnly) { _ in }
        useCase.execute(.changeCase(.lowercase)) { secondResult = $0 }

        XCTAssertEqual(secondResult, .busy)
        selected.complete()
        XCTAssertFalse(useCase.isBusy)
    }

    func testRejectedClipboardOperationReportsBusy() {
        let selected = SelectedTextReplacerMock()
        selected.acceptsOperation = false
        let useCase = makeUseCase(selected: selected)
        var result: PerformTextActionResult?

        useCase.execute(.changeCase(.uppercase), scope: .selectionOnly) { result = $0 }

        XCTAssertEqual(result, .busy)
        XCTAssertFalse(useCase.isBusy)
    }

    func testRemainsBusyWhileTrackedReplacementIsPending() {
        let selected = SelectedTextReplacerMock(result: .noText)
        let tracked = TrackedTextReplacerMock(text: "typed")
        tracked.deferCompletion = true
        let useCase = makeUseCase(selected: selected, tracked: tracked)
        var secondResult: PerformTextActionResult?

        useCase.execute(.changeCase(.uppercase)) { _ in }
        useCase.execute(.changeCase(.lowercase)) { secondResult = $0 }

        XCTAssertTrue(useCase.isBusy)
        XCTAssertEqual(secondResult, .busy)
        tracked.complete()
        XCTAssertFalse(useCase.isBusy)
    }

    func testCaseActionUsesActiveInputSourceLocale() {
        let repository = InputSourceRepositoryMock()
        repository.sources = [source("tr", locale: "tr_TR"), source("en", locale: "en_US")]
        repository.currentID = "tr"
        let selected = SelectedTextReplacerMock(text: "iı")
        let useCase = makeUseCase(repository: repository, selected: selected)

        useCase.execute(.changeCase(.uppercase), scope: .selectionOnly) { _ in }

        XCTAssertEqual(selected.replacement, "İI")
        XCTAssertTrue(repository.selectedIDs.isEmpty)
    }

    func testLayoutActionSelectsTargetAfterClipboardReplacement() {
        let fixture = layoutFixture()

        fixture.useCase.execute(.convertToNextLayout, scope: .selectionOnly) { _ in }

        XCTAssertEqual(fixture.selected.replacement, "й")
        XCTAssertEqual(fixture.activator.requestedIDs, ["ru"])
    }

    func testLayoutActionSelectsTargetAfterTrackedReplacement() {
        let fixture = layoutFixture(selectedResult: .noText)
        fixture.tracked.text = "q"

        fixture.useCase.execute(.convertToNextLayout) { _ in }

        XCTAssertEqual(fixture.tracked.replacement, "й")
        XCTAssertEqual(fixture.activator.requestedIDs, ["ru"])
    }

    func testAutomaticLayoutActionUsesLanguageAwareCandidate() {
        let repository = InputSourceRepositoryMock()
        repository.sources = [source("en"), source("ru"), source("de")]
        repository.currentID = "en"
        let selected = SelectedTextReplacerMock(text: "q")
        let automaticConverter = AutomaticLayoutConverterMock(
            result: LanguageAwareLayoutConversion(text: "x", targetInputSourceID: "de")
        )
        let activator = InputSourceActivatorMock()
        let useCase = makeUseCase(
            repository: repository,
            selected: selected,
            automaticLayoutConverter: automaticConverter,
            activator: activator
        )

        useCase.execute(.convertToNextLayout, scope: .selectionOnly) { _ in }

        XCTAssertEqual(selected.replacement, "x")
        XCTAssertEqual(automaticConverter.currentIDs, ["en"])
        XCTAssertEqual(automaticConverter.availableIDLists, [["en", "ru", "de"]])
        XCTAssertEqual(activator.requestedIDs, ["de"])
    }

    func testLayoutActionWaitsForVerifiedInputSourceActivation() {
        let fixture = layoutFixture()
        fixture.activator.deferCompletion = true
        var result: PerformTextActionResult?

        fixture.useCase.execute(.convertToNextLayout, scope: .selectionOnly) { result = $0 }

        XCTAssertNil(result)
        XCTAssertTrue(fixture.useCase.isBusy)
        fixture.activator.complete(succeeded: true)
        XCTAssertEqual(result, .replaced)
        XCTAssertFalse(fixture.useCase.isBusy)
    }

    func testLayoutActionReportsFailureWhenTargetDoesNotBecomeActive() {
        let fixture = layoutFixture()
        fixture.activator.succeeds = false
        var result: PerformTextActionResult?

        fixture.useCase.execute(.convertToNextLayout, scope: .selectionOnly) { result = $0 }

        XCTAssertEqual(fixture.selected.replacement, "й")
        XCTAssertEqual(result, .failed)
    }

    func testLayoutDoesNotSwitchWhenBothRoutesFindNoText() {
        let fixture = layoutFixture(selectedResult: .noText)
        fixture.tracked.result = .noText
        var result: PerformTextActionResult?

        fixture.useCase.execute(.convertToNextLayout) { result = $0 }

        XCTAssertTrue(fixture.repository.selectedIDs.isEmpty)
        XCTAssertEqual(result, .noText)
    }

    func testExcludedLayoutIsUnavailableForAutomaticConversion() {
        let repository = InputSourceRepositoryMock()
        repository.sources = [source("en"), source("ru"), source("de")]
        repository.currentID = "en"
        let selectionStore = InputSourceSelectionStoreMock(excludedInputSourceIDs: ["ru"])
        let automaticConverter = AutomaticLayoutConverterMock(
            result: LanguageAwareLayoutConversion(text: "x", targetInputSourceID: "de")
        )
        let selected = SelectedTextReplacerMock(text: "q")
        let useCase = makeUseCase(
            repository: repository,
            selectionStore: selectionStore,
            selected: selected,
            automaticLayoutConverter: automaticConverter
        )

        useCase.execute(.convertToNextLayout, scope: .selectionOnly) { _ in }

        XCTAssertEqual(automaticConverter.availableIDLists, [["en", "de"]])
    }

    private func layoutFixture(
        selectedResult: TextReplacementResult? = nil
    ) -> LayoutFixture {
        let repository = InputSourceRepositoryMock()
        repository.sources = [source("en"), source("ru")]
        repository.currentID = "en"
        let selected = SelectedTextReplacerMock(result: selectedResult, text: "q")
        let tracked = TrackedTextReplacerMock(text: "q")
        let activator = InputSourceActivatorMock()
        let automaticConverter = AutomaticLayoutConverterMock(
            result: LanguageAwareLayoutConversion(text: "й", targetInputSourceID: "ru")
        )
        return LayoutFixture(
            repository: repository,
            selected: selected,
            tracked: tracked,
            activator: activator,
            useCase: makeUseCase(
                repository: repository,
                selected: selected,
                tracked: tracked,
                automaticLayoutConverter: automaticConverter,
                activator: activator
            )
        )
    }

    private func makeUseCase(
        repository: InputSourceRepositoryMock = InputSourceRepositoryMock(),
        selectionStore: InputSourceSelectionStoreMock = InputSourceSelectionStoreMock(),
        selected: SelectedTextReplacerMock = SelectedTextReplacerMock(),
        tracked: TrackedTextReplacerMock = TrackedTextReplacerMock(),
        scopeStore: TextConversionScopeStoreMock = TextConversionScopeStoreMock(),
        automaticLayoutConverter: AutomaticLayoutConverterMock = AutomaticLayoutConverterMock(),
        activator: InputSourceActivatorMock = InputSourceActivatorMock()
    ) -> PerformTextAction {
        if repository.sources.isEmpty {
            repository.sources = [source("en", locale: "en_US"), source("ru", locale: "ru_RU")]
            repository.currentID = "en"
        }
        return PerformTextAction(
            selectedTextReplacer: selected,
            trackedTextReplacer: tracked,
            inputSourceRepository: repository,
            inputSourceSelectionStore: selectionStore,
            automaticLayoutConverter: automaticLayoutConverter,
            inputSourceActivator: activator,
            scopeStore: scopeStore,
            fallbackLocale: Locale(identifier: "en_US")
        )
    }

    private func source(
        _ id: String,
        locale: String? = "en_US",
        supportsConversion: Bool = true
    ) -> InputSource {
        InputSource(
            id: id,
            displayName: id,
            localeIdentifier: locale,
            supportsTextConversion: supportsConversion
        )
    }
}

private final class InputSourceSelectionStoreMock: InputSourceSelectionStore {
    var excludedInputSourceIDs: Set<String>

    init(excludedInputSourceIDs: Set<String> = []) {
        self.excludedInputSourceIDs = excludedInputSourceIDs
    }
}

private struct LayoutFixture {
    let repository: InputSourceRepositoryMock
    let selected: SelectedTextReplacerMock
    let tracked: TrackedTextReplacerMock
    let activator: InputSourceActivatorMock
    let useCase: PerformTextAction
}

private final class SelectedTextReplacerMock: SelectedTextReplacing {
    var result: TextReplacementResult?
    var text: String
    var replacement: String?
    var acceptsOperation = true
    var deferCompletion = false
    var callCount = 0
    private var pendingCompletion: (() -> Void)?

    init(result: TextReplacementResult? = nil, text: String = "Text") {
        self.result = result
        self.text = text
    }

    var isBusy: Bool { pendingCompletion != nil }

    func replaceSelectedText(
        transform: @escaping (String) -> TextTransformation?,
        completion: @escaping (TextReplacementResult) -> Void
    ) -> Bool {
        callCount += 1
        guard acceptsOperation else { return false }
        let transformation = transform(text)
        replacement = transformation?.text
        let completionResult = result
            ?? transformation.map(TextReplacementResult.replaced)
            ?? .unchanged
        if deferCompletion {
            pendingCompletion = { completion(completionResult) }
        } else {
            completion(completionResult)
        }
        return true
    }

    func complete() {
        let completion = pendingCompletion
        pendingCompletion = nil
        completion?()
    }
}

private final class TrackedTextReplacerMock: TrackedTextReplacing {
    var result: TextReplacementResult?
    var text: String
    var replacement: String?
    var scope: TextConversionScope?
    var callCount = 0
    var deferCompletion = false
    private var pendingCompletion: (() -> Void)?

    init(text: String = "Text") {
        self.text = text
    }

    var isBusy: Bool { pendingCompletion != nil }

    func replaceTrackedText(
        scope: TextConversionScope,
        transform: @escaping (String) -> TextTransformation?,
        completion: @escaping (TextReplacementResult) -> Void
    ) -> Bool {
        callCount += 1
        self.scope = scope
        let transformation = transform(text)
        replacement = transformation?.text
        let completionResult = result
            ?? transformation.map(TextReplacementResult.replaced)
            ?? .unchanged
        if deferCompletion {
            pendingCompletion = { completion(completionResult) }
        } else {
            completion(completionResult)
        }
        return true
    }

    func complete() {
        let completion = pendingCompletion
        pendingCompletion = nil
        completion?()
    }
}

private final class TextConversionScopeStoreMock: TextConversionScopeStore {
    var scope: TextConversionScope

    init(scope: TextConversionScope = .typedText) {
        self.scope = scope
    }
}

private final class InputSourceRepositoryMock: InputSourceRepository {
    var sources: [InputSource] = []
    var currentID: String?
    var selectedIDs: [String] = []
    var selectionSucceeds = true

    func availableInputSources() -> [InputSource] { sources }
    func currentInputSourceID() -> String? { currentID }
    func selectInputSource(id: String) -> Bool {
        selectedIDs.append(id)
        return selectionSucceeds
    }
}

private final class AutomaticLayoutConverterMock: AutomaticLayoutConverting {
    var result: LanguageAwareLayoutConversion?
    var currentIDs: [String] = []
    var availableIDLists: [[String]] = []

    init(result: LanguageAwareLayoutConversion? = nil) {
        self.result = result
    }

    func convert(
        _ text: String,
        current: InputSource,
        availableInputSources: [InputSource]
    ) -> LanguageAwareLayoutConversion? {
        currentIDs.append(current.id)
        availableIDLists.append(availableInputSources.map(\.id))
        return result
    }
}

private final class InputSourceActivatorMock: InputSourceActivating {
    var requestedIDs: [String] = []
    var succeeds = true
    var deferCompletion = false
    private var pending: ((InputSourceActivationResult) -> Void)?

    func activateInputSource(
        id: String,
        completion: @escaping (InputSourceActivationResult) -> Void
    ) {
        requestedIDs.append(id)
        if deferCompletion {
            pending = completion
        } else {
            completion(result(id: id, succeeded: succeeds))
        }
    }

    func complete(succeeded: Bool) {
        guard let completion = pending, let id = requestedIDs.last else { return }
        pending = nil
        completion(result(id: id, succeeded: succeeded))
    }

    private func result(id: String, succeeded: Bool) -> InputSourceActivationResult {
        InputSourceActivationResult(
            requestedInputSourceID: id,
            activeInputSourceID: succeeded ? id : "en",
            succeeded: succeeded
        )
    }
}
