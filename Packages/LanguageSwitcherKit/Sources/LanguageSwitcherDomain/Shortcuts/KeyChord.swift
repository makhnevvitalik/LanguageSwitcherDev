// SPDX-FileCopyrightText: 2026 Vitalik Makhnev
// SPDX-License-Identifier: MIT AND LicenseRef-Commons-Clause-1.0

public struct KeyModifiers: OptionSet, Codable, Hashable, Sendable {
    public let rawValue: UInt64

    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    public static let command = KeyModifiers(rawValue: 1 << 0)
    public static let option = KeyModifiers(rawValue: 1 << 1)
    public static let control = KeyModifiers(rawValue: 1 << 2)
    public static let shift = KeyModifiers(rawValue: 1 << 3)
    public static let function = KeyModifiers(rawValue: 1 << 4)
}

public enum ShortcutModifier: String, Codable, CaseIterable, Hashable, Sendable {
    case shift
    case control
    case option
    case command

    public var mask: KeyModifiers {
        switch self {
        case .shift: .shift
        case .control: .control
        case .option: .option
        case .command: .command
        }
    }
}

public struct ShortcutFunctionKey: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: Int

    public init?(rawValue: Int) {
        guard (1...20).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

public enum TextShortcutKey: Codable, Hashable, Sendable {
    case modifier(ShortcutModifier)
    case function(ShortcutFunctionKey)

    public var modifierMask: KeyModifiers? {
        guard case let .modifier(modifier) = self else { return nil }
        return modifier.mask
    }
}

public struct TextShortcutChord: Codable, Hashable, Sendable {
    public let modifiers: KeyModifiers
    public let functionKey: ShortcutFunctionKey?

    public init(modifiers: KeyModifiers, functionKey: ShortcutFunctionKey?) {
        self.modifiers = modifiers
        self.functionKey = functionKey
    }

    public var isValid: Bool {
        modifiers.subtracting(.textShortcutModifiers).isEmpty
            && (!modifiers.isEmpty || functionKey != nil)
    }

    public var keys: Set<TextShortcutKey> {
        var result = Set(
            ShortcutModifier.allCases.compactMap {
                modifiers.contains($0.mask) ? TextShortcutKey.modifier($0) : nil
            }
        )
        if let functionKey {
            result.insert(.function(functionKey))
        }
        return result
    }
}

public extension KeyModifiers {
    static let textShortcutModifiers: KeyModifiers = [
        .shift, .control, .option, .command
    ]
}
