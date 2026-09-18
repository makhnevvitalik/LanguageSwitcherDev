// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherDomain

public enum PerformTextActionResult: Equatable, Sendable {
    case replaced
    case noText
    case unchanged
    case clipboardChanged
    case contextChanged
    case busy
    case unavailable
    case failed
}

public final class PerformTextAction {
    private let selectedTextReplacer: any SelectedTextReplacing
    private let trackedTextReplacer: any TrackedTextReplacing
    private let inputSourceRepository: any InputSourceRepository
    private let inputSourceSelectionStore: any InputSourceSelectionStore
    private let automaticLayoutConverter: any AutomaticLayoutConverting
    private let inputSourceActivator: any InputSourceActivating
    private let scopeStore: any TextConversionScopeStore
    private let fallbackLocale: Locale
    private var isExecuting = false

    public init(
        selectedTextReplacer: any SelectedTextReplacing,
        trackedTextReplacer: any TrackedTextReplacing,
        inputSourceRepository: any InputSourceRepository,
        inputSourceSelectionStore: any InputSourceSelectionStore,
        automaticLayoutConverter: any AutomaticLayoutConverting,
        inputSourceActivator: any InputSourceActivating,
        scopeStore: any TextConversionScopeStore,
        fallbackLocale: Locale = .current
    ) {
        self.selectedTextReplacer = selectedTextReplacer
        self.trackedTextReplacer = trackedTextReplacer
        self.inputSourceRepository = inputSourceRepository
        self.inputSourceSelectionStore = inputSourceSelectionStore
        self.automaticLayoutConverter = automaticLayoutConverter
        self.inputSourceActivator = inputSourceActivator
        self.scopeStore = scopeStore
        self.fallbackLocale = fallbackLocale
    }

    public var isBusy: Bool {
        isExecuting || selectedTextReplacer.isBusy || trackedTextReplacer.isBusy
    }

    public func isAvailable(_ action: TextAction) -> Bool {
        makeOperation(for: action) != nil
    }

    public func execute(
        _ action: TextAction,
        scope: TextConversionScope? = nil,
        completion: @escaping (PerformTextActionResult) -> Void
    ) {
        guard let operation = makeOperation(for: action) else {
            completion(.unavailable)
            return
        }
        execute(operation, scope: scope ?? scopeStore.scope, completion: completion)
    }

    private func execute(
        _ operation: TextOperation,
        scope: TextConversionScope,
        completion: @escaping (PerformTextActionResult) -> Void
    ) {
        guard !isExecuting else {
            completion(.busy)
            return
        }
        isExecuting = true

        if scope == .selectionOnly {
            replaceSelectedText(operation, completion: completion)
        } else {
            replaceTrackedText(operation, scope: scope, completion: completion)
        }
    }

    private func replaceSelectedText(
        _ operation: TextOperation,
        completion: @escaping (PerformTextActionResult) -> Void
    ) {
        let accepted = selectedTextReplacer.replaceSelectedText(
            transform: operation.transform
        ) { [weak self] result in
            self?.finish(
                result,
                completion: completion
            )
        }
        if !accepted {
            isExecuting = false
            completion(.busy)
        }
    }

    private func replaceTrackedText(
        _ operation: TextOperation,
        scope: TextConversionScope,
        completion: @escaping (PerformTextActionResult) -> Void
    ) {
        let accepted = trackedTextReplacer.replaceTrackedText(
            scope: scope,
            transform: operation.transform
        ) { [weak self] result in
            self?.handleTrackedResult(
                result,
                operation: operation,
                completion: completion
            )
        }
        if !accepted {
            isExecuting = false
            completion(.busy)
        }
    }

    private func handleTrackedResult(
        _ result: TextReplacementResult,
        operation: TextOperation,
        completion: @escaping (PerformTextActionResult) -> Void
    ) {
        if result == .noText {
            replaceSelectedText(operation, completion: completion)
        } else {
            finish(result, completion: completion)
        }
    }

    private func finish(
        _ result: TextReplacementResult,
        completion: @escaping (PerformTextActionResult) -> Void
    ) {
        guard case let .replaced(transformation) = result,
              let targetID = transformation.targetInputSourceID else {
            complete(Self.map(result), completion: completion)
            return
        }

        inputSourceActivator.activateInputSource(id: targetID) { [weak self] activation in
            self?.complete(
                activation.succeeded ? .replaced : .failed,
                completion: completion
            )
        }
    }

    private func complete(
        _ result: PerformTextActionResult,
        completion: (PerformTextActionResult) -> Void
    ) {
        isExecuting = false
        completion(result)
    }

    private func makeOperation(for action: TextAction) -> TextOperation? {
        switch action {
        case let .changeCase(caseAction):
            let locale = activeInputSource()
                .flatMap(\.localeIdentifier)
                .map(Locale.init(identifier:))
                ?? fallbackLocale
            return TextOperation(
                transform: { text in
                    TextTransformation(
                        text: TextCaseTransformer.transform(
                            text,
                            action: caseAction,
                            locale: locale
                        ),
                        targetInputSourceID: nil
                    )
                }
            )

        case .convertToNextLayout:
            let sources = convertibleInputSources()
            guard let current = activeInputSource(in: sources),
                  sources.contains(where: { $0.id != current.id }) else {
                return nil
            }
            return TextOperation { [automaticLayoutConverter] text in
                guard let conversion = automaticLayoutConverter.convert(
                    text,
                    current: current,
                    availableInputSources: sources
                ) else {
                    return nil
                }
                return TextTransformation(
                    text: conversion.text,
                    targetInputSourceID: conversion.targetInputSourceID
                )
            }
        }
    }

    private func convertibleInputSources() -> [InputSource] {
        let excludedIDs = inputSourceSelectionStore.excludedInputSourceIDs
        return InputSourceSelectionPolicy.selectedForTextConversion(
            from: inputSourceRepository.availableInputSources(),
            excludedIDs: excludedIDs
        )
    }

    private func activeInputSource(in sources: [InputSource]? = nil) -> InputSource? {
        guard let currentID = inputSourceRepository.currentInputSourceID() else { return nil }
        return (sources ?? inputSourceRepository.availableInputSources()).first {
            $0.id == currentID
        }
    }

    private static func map(_ result: TextReplacementResult) -> PerformTextActionResult {
        switch result {
        case .replaced: .replaced
        case .noText: .noText
        case .unchanged: .unchanged
        case .clipboardChanged: .clipboardChanged
        case .contextChanged: .contextChanged
        case .unavailable: .unavailable
        case .failed: .failed
        }
    }
}

private struct TextOperation {
    let transform: (String) -> TextTransformation?

    init(transform: @escaping (String) -> TextTransformation?) {
        self.transform = transform
    }
}
