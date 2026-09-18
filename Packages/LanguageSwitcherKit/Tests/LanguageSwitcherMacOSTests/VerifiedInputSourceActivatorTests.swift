// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherApplication
import LanguageSwitcherDomain
@testable import LanguageSwitcherMacOS
import XCTest

final class VerifiedInputSourceActivatorTests: XCTestCase {
    func testCompletesAfterTargetBecomesCurrent() {
        let repository = InputSourceRepositoryFake(currentID: "en")
        let scheduler = ActivationSchedulerFake()
        let activator = VerifiedInputSourceActivator(
            repository: repository,
            scheduler: scheduler,
            retryInterval: 0.02,
            timeout: 0.10
        )
        var result: InputSourceActivationResult?

        activator.activateInputSource(id: "ru") { result = $0 }
        XCTAssertNil(result)

        repository.currentID = "ru"
        scheduler.runNext()

        XCTAssertEqual(
            result,
            InputSourceActivationResult(
                requestedInputSourceID: "ru",
                activeInputSourceID: "ru",
                succeeded: true
            )
        )
    }

    func testReportsFailureWhenSelectionRequestIsRejected() {
        let repository = InputSourceRepositoryFake(currentID: "en")
        repository.selectionSucceeds = false
        let activator = VerifiedInputSourceActivator(
            repository: repository,
            scheduler: ActivationSchedulerFake(),
            retryInterval: 0.02,
            timeout: 0.10
        )
        var result: InputSourceActivationResult?

        activator.activateInputSource(id: "ru") { result = $0 }

        XCTAssertEqual(result?.activeInputSourceID, "en")
        XCTAssertEqual(result?.succeeded, false)
    }

    func testReportsFailureAfterTimeoutWithoutBlocking() {
        let repository = InputSourceRepositoryFake(currentID: "en")
        let scheduler = ActivationSchedulerFake()
        let activator = VerifiedInputSourceActivator(
            repository: repository,
            scheduler: scheduler,
            retryInterval: 0.02,
            timeout: 0.05
        )
        var result: InputSourceActivationResult?

        activator.activateInputSource(id: "ru") { result = $0 }
        XCTAssertNil(result)

        scheduler.runUntilIdle()

        XCTAssertEqual(result?.activeInputSourceID, "en")
        XCTAssertEqual(result?.succeeded, false)
        XCTAssertLessThanOrEqual(scheduler.maximumScheduledDelay, 0.02)
    }

    func testDiagnosticContainsSourceTargetActiveAndResult() {
        let repository = InputSourceRepositoryFake(currentID: "en")
        repository.selectionSucceeds = false
        var entries: [String] = []
        let activator = VerifiedInputSourceActivator(
            repository: repository,
            scheduler: ActivationSchedulerFake(),
            retryInterval: 0.02,
            timeout: 0.10,
            diagnostics: { entries.append($0) }
        )

        activator.activateInputSource(id: "ru") { _ in }

        XCTAssertEqual(
            entries,
            [
                "sourceInputSourceID=en targetInputSourceID=ru "
                    + "activeInputSourceIDAfterSelection=en selectionSucceeded=false"
            ]
        )
    }
}

private final class InputSourceRepositoryFake: InputSourceRepository {
    var currentID: String?
    var selectionSucceeds = true

    init(currentID: String?) {
        self.currentID = currentID
    }

    func availableInputSources() -> [InputSource] { [] }
    func currentInputSourceID() -> String? { currentID }
    func selectInputSource(id: String) -> Bool { selectionSucceeds }
}

private final class ActivationSchedulerFake: InputSourceActivationScheduling {
    private(set) var now: TimeInterval = 0
    private(set) var maximumScheduledDelay: TimeInterval = 0
    private var pending: [(deadline: TimeInterval, action: () -> Void)] = []

    func schedule(after delay: TimeInterval, _ action: @escaping () -> Void) {
        maximumScheduledDelay = max(maximumScheduledDelay, delay)
        pending.append((now + delay, action))
    }

    func runNext() {
        guard !pending.isEmpty else { return }
        let next = pending.removeFirst()
        now = next.deadline
        next.action()
    }

    func runUntilIdle() {
        while !pending.isEmpty {
            runNext()
        }
    }
}
