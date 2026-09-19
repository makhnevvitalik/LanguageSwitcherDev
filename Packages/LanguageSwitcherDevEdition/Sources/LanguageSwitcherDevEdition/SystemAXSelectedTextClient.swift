// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import ApplicationServices

final class SystemAXSelectedTextClient: AXSelectedTextReading {
    private let systemWideElement = AXUIElementCreateSystemWide()

    func readSelection() -> AXSelectedTextReadResult {
        guard let focusedElement = focusedElement() else {
            return .unsupported
        }

        var selectedTextValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            focusedElement,
            kAXSelectedTextAttribute as CFString,
            &selectedTextValue
        ) == .success, let selectedText = selectedTextValue as? String else {
            return .unsupported
        }

        guard !selectedText.isEmpty else {
            return .noText
        }

        return .selection(selectedText)
    }

    private func focusedElement() -> AXUIElement? {
        var focusedElementValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElementValue
        ) == .success,
            let focusedElementValue,
            CFGetTypeID(focusedElementValue) == AXUIElementGetTypeID() else {
            return nil
        }
        return unsafeBitCast(focusedElementValue, to: AXUIElement.self)
    }
}
