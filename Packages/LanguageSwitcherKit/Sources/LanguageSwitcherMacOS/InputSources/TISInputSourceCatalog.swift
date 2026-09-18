// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

import Carbon

enum TISInputSourceCatalog {
    static func selectableInputSources() -> [TISInputSource] {
        allInputSources().filter { source in
            source.stringProperty(kTISPropertyInputSourceCategory)
                == kTISCategoryKeyboardInputSource as String
                && source.boolProperty(kTISPropertyInputSourceIsEnabled)
                && source.boolProperty(kTISPropertyInputSourceIsSelectCapable)
        }
    }

    static func selectableInputSource(id: String) -> TISInputSource? {
        selectableInputSources().first {
            $0.stringProperty(kTISPropertyInputSourceID) == id
        }
    }

    private static func allInputSources() -> [TISInputSource] {
        guard let unmanaged = TISCreateInputSourceList(nil, false) else {
            return []
        }
        let sources = unmanaged.takeRetainedValue() as NSArray
        return sources as? [TISInputSource] ?? []
    }
}

extension TISInputSource {
    func property(_ key: CFString) -> AnyObject? {
        guard let value = TISGetInputSourceProperty(self, key) else {
            return nil
        }
        return Unmanaged<AnyObject>.fromOpaque(value).takeUnretainedValue()
    }

    func stringProperty(_ key: CFString) -> String? {
        property(key) as? String
    }

    func boolProperty(_ key: CFString) -> Bool {
        property(key) as? Bool ?? false
    }
}
