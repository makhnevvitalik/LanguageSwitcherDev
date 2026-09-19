// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import LanguageSwitcherApplication
import LanguageSwitcherMacOS

public final class AccessibilitySelectedTextEditor: SelectedTextReplacing {
    private let access: any AXSelectedTextReading
    private let eventReplacer: any SelectedTextEventReplacing
    private let onReplacement: () -> Void
    private let diagnostics: ((String) -> Void)?

    public convenience init(
        onReplacement: @escaping () -> Void = {},
        diagnostics: ((String) -> Void)? = nil
    ) {
        self.init(
            access: SystemAXSelectedTextClient(),
            eventReplacer: CGEventTextReplacer(),
            onReplacement: onReplacement,
            diagnostics: diagnostics
        )
    }

    init(
        access: any AXSelectedTextReading,
        eventReplacer: any SelectedTextEventReplacing,
        onReplacement: @escaping () -> Void = {},
        diagnostics: ((String) -> Void)? = nil
    ) {
        self.access = access
        self.eventReplacer = eventReplacer
        self.onReplacement = onReplacement
        self.diagnostics = diagnostics
    }

    public var isBusy: Bool {
        eventReplacer.isBusy
    }

    @discardableResult
    public func replaceSelectedText(
        transform: @escaping (String) -> TextTransformation?,
        completion: @escaping (TextReplacementResult) -> Void
    ) -> Bool {
        guard !isBusy else { return false }

        switch access.readSelection() {
        case .unsupported:
            diagnostics?("read=unsupported")
            completion(.failed)
            return true

        case .noText:
            diagnostics?("read=noText")
            completion(.noText)
            return true

        case let .selection(selectedText):
            diagnostics?("read=selection characters=\(selectedText.count)")
            guard let transformation = transform(selectedText) else {
                diagnostics?("transform=unchanged")
                completion(.unchanged)
                return true
            }
            guard eventReplacer.replaceSelection(
                with: transformation.text,
                completion: { [weak self] succeeded in
                    guard let self else { return }
                    guard succeeded else {
                        self.diagnostics?("event.write=failed")
                        completion(.failed)
                        return
                    }
                    self.diagnostics?("event.write=replaced")
                    self.onReplacement()
                    completion(.replaced(transformation))
                }
            ) else {
                return false
            }
            return true
        }
    }
}
