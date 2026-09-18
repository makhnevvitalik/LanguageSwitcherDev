// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Foundation
import LanguageSwitcherDomain

enum TextShortcutRecognition: Equatable {
    case trigger(TextAction)
    case wait(TextShortcutChord)
    case none
}

struct TextShortcutGestureRecognizer {
    private struct PendingClassic {
        let completedAt: TimeInterval
    }

    private struct HoldGesture: Hashable {
        let heldModifiers: KeyModifiers
        let tapKey: TextShortcutKey
    }

    private struct HoldState {
        var tapIsDown = false
        var completedTaps = 0
        var lastCompletedAt: TimeInterval?
    }

    private let onceActions: [TextShortcutChord: TextAction]
    private let repeatActions: [TextShortcutChord: TextAction]
    private let holdActions: [HoldGesture: TextAction]
    private let maximumInterval: TimeInterval

    private var activeFunctionKeys: Set<ShortcutFunctionKey> = []
    private var activeKeys: Set<TextShortcutKey> = []
    private var cycleKeys: Set<TextShortcutKey> = []
    private var cycleIsInvalid = false
    private var cycleIsConsumed = false
    private var pendingClassic: [TextShortcutChord: PendingClassic] = [:]
    private var holdStates: [HoldGesture: HoldState] = [:]
    private var contextGeneration: UInt64?

    init(
        shortcuts: [TextAction: TextActionShortcut],
        maximumInterval: TimeInterval
    ) {
        var onceActions: [TextShortcutChord: TextAction] = [:]
        var repeatActions: [TextShortcutChord: TextAction] = [:]
        var holdActions: [HoldGesture: TextAction] = [:]
        for (action, shortcut) in shortcuts where shortcut.isValidGlobalShortcut {
            switch shortcut {
            case let .once(chord):
                onceActions[chord] = action
            case let .repeatTwice(chord):
                repeatActions[chord] = action
            case let .holdAndTapTwice(heldModifiers, tapKey):
                holdActions[HoldGesture(
                    heldModifiers: heldModifiers,
                    tapKey: tapKey
                )] = action
            }
        }
        self.onceActions = onceActions
        self.repeatActions = repeatActions
        self.holdActions = holdActions
        self.maximumInterval = maximumInterval
    }

    mutating func handle(
        _ event: TextShortcutInputEvent,
        contextGeneration: UInt64 = 0
    ) -> TextShortcutRecognition {
        if self.contextGeneration != contextGeneration {
            resetAll()
            self.contextGeneration = contextGeneration
        }

        switch event {
        case let .keyDown(key, modifiers, timestamp, isRepeat):
            guard !isRepeat else { return .none }
            synchronizeActiveKeys(key: key, isDown: true, modifiers: modifiers)
            beginOrExtendCycle()
            handleHoldKeyDown(key, at: timestamp)
            return .none

        case let .keyUp(key, modifiers, timestamp):
            synchronizeActiveKeys(key: key, isDown: false, modifiers: modifiers)
            if let action = handleHoldKeyUp(key, at: timestamp) {
                consumeCurrentCycle()
                return .trigger(action)
            }
            return completeClassicCycleIfNeeded(at: timestamp)

        case .unrelatedInput:
            cycleIsInvalid = !activeKeys.isEmpty
            holdStates.removeAll()
            pendingClassic.removeAll()
            return .none
        }
    }

    mutating func handleTimeout(
        chord: TextShortcutChord,
        at timestamp: TimeInterval,
        contextGeneration: UInt64 = 0
    ) -> TextAction? {
        guard self.contextGeneration == contextGeneration,
              let pending = pendingClassic[chord],
              timestamp - pending.completedAt >= maximumInterval - 1e-9 else {
            return nil
        }
        pendingClassic[chord] = nil
        return onceActions[chord]
    }

    private mutating func synchronizeActiveKeys(
        key: TextShortcutKey,
        isDown: Bool,
        modifiers: KeyModifiers
    ) {
        if case let .function(functionKey) = key {
            if isDown {
                activeFunctionKeys.insert(functionKey)
            } else {
                activeFunctionKeys.remove(functionKey)
            }
        }
        activeKeys = Set(
            ShortcutModifier.allCases.compactMap {
                modifiers.contains($0.mask) ? TextShortcutKey.modifier($0) : nil
            }
        )
        activeKeys.formUnion(activeFunctionKeys.map(TextShortcutKey.function))
    }

    private mutating func beginOrExtendCycle() {
        if cycleKeys.isEmpty && activeKeys.isEmpty { return }
        cycleKeys.formUnion(activeKeys)
    }

    private mutating func completeClassicCycleIfNeeded(
        at timestamp: TimeInterval
    ) -> TextShortcutRecognition {
        guard activeKeys.isEmpty else { return .none }
        defer { resetPhysicalCycle() }
        guard !cycleIsInvalid, !cycleIsConsumed,
              let chord = matchingClassicChord(for: cycleKeys) else {
            pendingClassic.removeAll()
            return .none
        }

        let previousPending = pendingClassic[chord]
        pendingClassic.removeAll()
        if repeatActions[chord] != nil {
            if let pending = previousPending,
               timestamp - pending.completedAt <= maximumInterval + 1e-9 {
                return repeatActions[chord].map(TextShortcutRecognition.trigger) ?? .none
            }
            pendingClassic[chord] = PendingClassic(completedAt: timestamp)
            return .wait(chord)
        }
        return onceActions[chord].map(TextShortcutRecognition.trigger) ?? .none
    }

    private func matchingClassicChord(
        for keys: Set<TextShortcutKey>
    ) -> TextShortcutChord? {
        let candidates = Set(onceActions.keys).union(repeatActions.keys)
        return candidates.first { $0.keys == keys }
    }

    private mutating func handleHoldKeyDown(
        _ key: TextShortcutKey,
        at timestamp: TimeInterval
    ) {
        var matchedTapKey = false
        for gesture in holdActions.keys where gesture.tapKey == key {
            matchedTapKey = true
            var state = holdStates[gesture] ?? HoldState()
            if let last = state.lastCompletedAt,
               timestamp - last > maximumInterval + 1e-9 {
                state = HoldState()
            }
            guard !state.tapIsDown,
                  activeModifiersExcludingTap(key) == gesture.heldModifiers,
                  activeFunctionKeysExcludingTap(key).isEmpty else {
                holdStates[gesture] = HoldState()
                continue
            }
            state.tapIsDown = true
            holdStates[gesture] = state
        }
        if !matchedTapKey {
            for gesture in Array(holdStates.keys) {
                let state = holdStates[gesture] ?? HoldState()
                if state.completedTaps > 0 || state.tapIsDown {
                    holdStates[gesture] = HoldState()
                }
            }
        }
    }

    private mutating func handleHoldKeyUp(
        _ key: TextShortcutKey,
        at timestamp: TimeInterval
    ) -> TextAction? {
        for (gesture, action) in holdActions where gesture.tapKey == key {
            var state = holdStates[gesture] ?? HoldState()
            guard state.tapIsDown,
                  activeModifierMask == gesture.heldModifiers,
                  activeFunctionKeys.isEmpty else {
                holdStates[gesture] = HoldState()
                continue
            }
            state.tapIsDown = false
            state.completedTaps += 1
            state.lastCompletedAt = timestamp
            if state.completedTaps == 2 {
                holdStates.removeAll()
                pendingClassic.removeAll()
                return action
            }
            holdStates[gesture] = state
        }

        for gesture in Array(holdStates.keys) {
            guard gesture.tapKey != key else { continue }
            var state = holdStates[gesture] ?? HoldState()
            if state.completedTaps > 0 || state.tapIsDown {
                state = HoldState()
                holdStates[gesture] = state
            }
        }
        return nil
    }

    private var activeModifierMask: KeyModifiers {
        activeKeys.reduce(into: KeyModifiers()) { result, key in
            if let modifier = key.modifierMask {
                result.formUnion(modifier)
            }
        }
    }

    private func activeModifiersExcludingTap(
        _ tapKey: TextShortcutKey
    ) -> KeyModifiers {
        guard let tapModifier = tapKey.modifierMask else {
            return activeModifierMask
        }
        return activeModifierMask.subtracting(tapModifier)
    }

    private func activeFunctionKeysExcludingTap(
        _ tapKey: TextShortcutKey
    ) -> Set<ShortcutFunctionKey> {
        guard case let .function(tappedFunction) = tapKey else {
            return activeFunctionKeys
        }
        return activeFunctionKeys.subtracting([tappedFunction])
    }

    private mutating func consumeCurrentCycle() {
        cycleIsConsumed = true
        cycleIsInvalid = false
    }

    private mutating func resetPhysicalCycle() {
        cycleKeys.removeAll()
        cycleIsInvalid = false
        cycleIsConsumed = false
        holdStates.removeAll()
    }

    private mutating func resetAll() {
        activeFunctionKeys.removeAll()
        activeKeys.removeAll()
        resetPhysicalCycle()
        pendingClassic.removeAll()
    }
}
