// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Carbon
import LanguageSwitcherApplication
import LanguageSwitcherDomain

public final class TISInputSourceRepository: InputSourceRepository {
    public init() {}

    public func availableInputSources() -> [InputSource] {
        TISInputSourceCatalog.selectableInputSources().compactMap(Self.makeInputSource)
    }

    public func currentInputSourceID() -> String? {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }
        return source.stringProperty(kTISPropertyInputSourceID)
    }

    public func selectInputSource(id: String) -> Bool {
        guard let source = TISInputSourceCatalog.selectableInputSource(id: id) else {
            return false
        }

        return TISSelectInputSource(source) == noErr
    }

    private static func makeInputSource(_ source: TISInputSource) -> InputSource? {
        guard let id = source.stringProperty(kTISPropertyInputSourceID) else {
            return nil
        }

        let displayName = source.stringProperty(kTISPropertyLocalizedName) ?? id
        let languages = source.property(kTISPropertyInputSourceLanguages) as? [String]

        return InputSource(
            id: id,
            displayName: displayName,
            localeIdentifier: languages?.first,
            supportsTextConversion: source.property(kTISPropertyUnicodeKeyLayoutData) != nil
        )
    }
}
